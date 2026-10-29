// Builds assets/champions_seed.json and assets/speed_tiers.json from the
// projectpokemon/champout datamine (github.com/projectpokemon/champout, MIT) —
// replacing the champsmeta/pokemon-zone manual extracts with a robot-friendly
// upstream so GitHub Actions can regenerate the data unattended.
// champout decides WHICH forms are Champions (the game's own masterdata);
// pokedex_seed.json stays the identity authority (ids, display names, sprites).
// Every champout form is matched to a seed row by dex + stats + types, with
// ability sets used to split same-stat forms (gendered variants). Unmatched
// forms fail the build so a new game patch surfaces as a to-do, never as
// silent data loss.
// Speed tiers are derived, not scraped: Level-50 formulas verified against all
// 347 pokemon-zone.com rows (see research/upstream-data-sources.md).
// Files are cached under research/cache/champout/; delete it (or pass
// --refresh) to re-download. Run: node tool/build_champions_from_champout.js

const fs = require('fs');
const path = require('path');

const REPO = 'projectpokemon/champout';
const BRANCH = 'main';
const BASE = `https://raw.githubusercontent.com/${REPO}/${BRANCH}/`;
const CACHE = path.join(__dirname, '..', 'research', 'cache', 'champout');

const REFRESH = process.argv.includes('--refresh');

// mainline type enum used by personal.json's type1/type2 (verified: Venusaur
// 11/3 = Grass/Poison). Do NOT derive this from typename.json — its label
// indexes drift from the ids for ids >= 9.
const TYPES = [
  'Normal', 'Fighting', 'Flying', 'Poison', 'Ground', 'Rock', 'Bug', 'Ghost',
  'Steel', 'Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Ice', 'Dragon',
  'Dark', 'Fairy',
];

// ---- Level-50 formulas (verified against every pokemon-zone row) ------------
const noInvestOf = (b) => b + 20;
const maxOf = (b) => b + 52;
const maxPlusOf = (b) => Math.floor(maxOf(b) * 1.1);
const minOf = (b) => Math.floor(noInvestOf(b) * 0.9);
const scarfOf = (b) => Math.floor(maxPlusOf(b) * 1.5);
const tailwindOf = (b) => maxPlusOf(b) * 2;
const paralyzedOf = (b) => Math.floor(maxPlusOf(b) * 0.5);

// Lowercase, fold accents, drop every non-alphanumeric character — must stay
// in sync with NameForms.normalizeKey (lib/core/utils/name_forms.dart).
function normalizeName(s) {
  return s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]/g, '');
}

// PokeAPI-style ability slug: "Thermal Exchange" -> "thermal-exchange". The
// pokedex seed stores ability slugs in this style.
function slug(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

async function fetchCached(file, binary = false) {
  const local = path.join(CACHE, file.replaceAll('/', '_'));
  if (!REFRESH && fs.existsSync(local)) {
    return binary ? fs.readFileSync(local) : fs.readFileSync(local, 'utf8');
  }
  const res = await fetch(BASE + file);
  if (!res.ok) throw new Error(`fetch ${file}: HTTP ${res.status}`);
  const body = binary ? Buffer.from(await res.arrayBuffer()) : await res.text();
  fs.mkdirSync(CACHE, { recursive: true });
  fs.writeFileSync(local, body);
  return body;
}

async function fetchJson(file) {
  return JSON.parse(await fetchCached(file));
}

// Latest commit that touched masterdata/ — recorded in the outputs so the app
// and the diff can tell data versions apart.
async function fetchUpstreamMeta() {
  const local = path.join(CACHE, '_meta.json');
  if (!REFRESH && fs.existsSync(local)) return JSON.parse(fs.readFileSync(local, 'utf8'));
  try {
    const res = await fetch(
      `https://api.github.com/repos/${REPO}/commits?per_page=1&path=masterdata`,
    );
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const c = (await res.json())[0];
    const meta = { sha: c.sha, date: c.commit.author.date };
    fs.mkdirSync(CACHE, { recursive: true });
    fs.writeFileSync(local, JSON.stringify(meta, null, 1));
    return meta;
  } catch (e) {
    console.warn(`WARNING: could not fetch upstream commit info (${e.message}); using "unknown".`);
    return { sha: 'unknown', date: new Date().toISOString() };
  }
}

// personal_dump.txt: "NNNN - Name" header, stats line, types, abilities, then
// the learnset. Order matches personal.json (verified below via stats).
function parseDump(text) {
  const blocks = text.split(/\n\s*\n/);
  const out = [];
  for (const b of blocks) {
    const lines = b.split('\n').map((s) => s.trim()).filter(Boolean);
    if (!lines.length) continue;
    const m = lines[0].match(/^(\d{4}) - (.+)$/);
    if (!m) continue;
    const si = lines.findIndex((l) => /^\d+\/\d+\/\d+\/\d+\/\d+\/\d+$/.test(l));
    if (si < 0) throw new Error(`dump block "${lines[0]}" has no stats line`);
    out.push({
      dex: parseInt(m[1], 10),
      name: m[2],
      stats: lines[si].split('/').map(Number),
    });
  }
  return out;
}

function labelMap(file) {
  const m = new Map();
  for (const e of file.mSDataSet) {
    m.set(e.LabelName, e.TextInfos?.[0]?.Text ?? '');
  }
  return m;
}

(async () => {
  const meta = await fetchUpstreamMeta();
  const source = `${REPO}@${meta.sha.slice(0, 12)}`;
  console.log(`upstream: ${source} (${meta.date})\n`);

  const [personal, item, dumpText, tokusei, itemname, wazaLearn] =
      await Promise.all([
        fetchJson('masterdata/personal.json'),
        fetchJson('masterdata/item.json'),
        fetchCached('parse/personal_dump.txt'),
        fetchJson('rom-txt/usa/tokusei.json'),
        fetchJson('rom-txt/usa/itemname.json'),
        fetchJson('masterdata/waza_learn.json'),
      ]);
  const abilityNames = labelMap(tokusei);
  const itemNames = labelMap(itemname);

  // ---- champout forms ---------------------------------------------------------
  const dump = parseDump(dumpText);
  if (dump.length !== personal.length) {
    throw new Error(
      `personal_dump.txt has ${dump.length} blocks but personal.json has ${personal.length} entries — upstream layout changed`,
    );
  }
  const forms = personal.map((p, i) => {
    const d = dump[i];
    const stats = [p.hp, p.atk, p.def, p.spatk, p.spdef, p.agi].map(Number);
    if (stats.join(',') !== d.stats.join(',')) {
      throw new Error(
        `personal.json[${i}] stats ${stats} disagree with dump "${d.name}" ${d.stats} — order changed upstream`,
      );
    }
    // Mono types are encoded by duplication (Absol 16/16 = Dark), and 0 is a
    // real type (Normal: Persian 0/0, Pyroar 9/0 = Fire/Normal). The dump's
    // types text is unreliable here — always derive from these numeric ids.
    const t1 = Number(p.type1);
    const t2 = Number(p.type2);
    if (!(t1 >= 0 && t1 < TYPES.length) || !(t2 >= 0 && t2 < TYPES.length)) {
      throw new Error(`"${d.name}": out-of-range type id in [${p.type1}, ${p.type2}]`);
    }
    const types = t1 === t2 ? [TYPES[t1]] : [TYPES[t1], TYPES[t2]];
    const abilityIds = [...new Set([p.toku0, p.toku1, p.toku2].map(Number).filter((t) => t > 0))];
    const abilities = abilityIds.map((id) => {
      const name = abilityNames.get(`TOKUSEI_${String(id).padStart(3, '0')}`);
      if (!name) throw new Error(`"${d.name}": ability id ${id} has no TOKUSEI label`);
      return name;
    });
    return {
      dex: Number(p.no),
      formIndex: Number(p.fo),
      name: d.name,
      stats,
      types,
      abilities,
      regNo: p.reg_no,
    };
  });

  // ---- seed indexes -----------------------------------------------------------
  const seed = require('../assets/pokedex_seed.json');
  let prevChampions = { pokemon: [], items: [] };
  const championsFilePath = path.join(__dirname, '..', 'assets', 'champions_seed.json');
  if (fs.existsSync(championsFilePath)) {
    prevChampions = JSON.parse(fs.readFileSync(championsFilePath, 'utf8'));
  }
  const rowsByDex = new Map();
  for (const row of seed) {
    const dex = row.speciesId ?? row.id;
    if (!rowsByDex.has(dex)) rowsByDex.set(dex, []);
    rowsByDex.get(dex).push(row);
  }
  // Champions has no Gigantamax (champout has zero Gmax entries), and Gmax
  // rows share their species' base stats, so they would shadow real pairings.
  for (const [dex, rows] of rowsByDex) {
    const kept = rows.filter((r) => !/gigantamax|gmax/i.test(r.name));
    if (kept.length > 0 && kept.length !== rows.length) {
      rowsByDex.set(dex, kept);
    }
  }
  for (const rows of rowsByDex.values()) rows.sort((a, b) => a.id - b.id);

  const statsOf = (row) => [row.hp, row.attack, row.defense, row.spAttack, row.spDefense, row.speed];
  const typesOf = (row) => row.types.split(',').map((t) => t.trim()).filter(Boolean);
  const abilitySlugsOf = (row) =>
    [...new Set(row.abilities.split(',').map((t) => t.trim()).filter(Boolean))].sort();

  // stats + types signature; ability sets split same-stat forms (gendered variants)
  const champSig = (f) => `${f.stats.join(',')}|${f.types.map((t) => t.toLowerCase()).sort().join('/')}`;
  const seedSig = (row) => `${statsOf(row).join(',')}|${typesOf(row).map((t) => t.toLowerCase()).sort().join('/')}`;

  // ---- match champout forms to seed rows --------------------------------------
  const matched = new Map(); // champout form -> seed row
  const failed = [];
  const abilityDrift = [];
  const collapsed = [];

  const dexes = [...new Set(forms.map((f) => f.dex))].sort((a, b) => a - b);
  for (const dex of dexes) {
    const champForms = forms.filter((f) => f.dex === dex);
    const seedRows = rowsByDex.get(dex) ?? [];
    if (seedRows.length === 0) {
      for (const f of champForms) failed.push(`${f.name}: dex ${dex} has no pokedex_seed rows — add the species to the seed`);
      continue;
    }
    const champGroups = new Map();
    for (const f of champForms) {
      if (!champGroups.has(champSig(f))) champGroups.set(champSig(f), []);
      champGroups.get(champSig(f)).push(f);
    }
    const seedGroups = new Map();
    for (const row of seedRows) {
      if (!seedGroups.has(seedSig(row))) seedGroups.set(seedSig(row), []);
      seedGroups.get(seedSig(row)).push(row);
    }
    for (const [sig, cForms] of champGroups) {
      const sRows = seedGroups.get(sig) ?? [];
      if (sRows.length === 0) {
        for (const f of cForms) {
          failed.push(
            `${f.name}: no seed row with stats ${sig} (seed dex ${dex} rows: ${seedRows.map((r) => r.name).join(', ')})`,
          );
        }
        continue;
      }
      // The game datamine enumerates every cosmetic variant (Vivillon
      // patterns, Florges colors, Furfrou trims, ...) while the seed models
      // one row per look. Collapse the extras onto the base form, visibly.
      if (cForms.length > sRows.length) {
        for (const f of cForms.slice(sRows.length)) {
          collapsed.push(`${f.name}: identical stats/types/abilities to ${cForms[0].name} — seed models ${sRows.length} row(s)`);
        }
      }
      const cUse = cForms.slice(0, sRows.length);
      // pair by ability set first (splits gendered variants), then in order
      const pool = [...sRows];
      const left = [];
      for (const f of cUse) {
        const want = [...new Set(f.abilities.map(slug))].sort().join(',');
        const idx = pool.findIndex((r) => abilitySlugsOf(r).join(',') === want);
        if (idx >= 0) {
          matched.set(f, pool[idx]);
          pool.splice(idx, 1);
        } else {
          left.push(f);
        }
      }
      if (left.length === pool.length) {
        left.forEach((f, i) => {
          matched.set(f, pool[i]);
          const want = [...new Set(f.abilities.map(slug))].sort().join(',');
          if (abilitySlugsOf(pool[i]).join(',') !== want) {
            abilityDrift.push(
              `${f.name}: abilities champout=[${f.abilities.join('/')}] seed=[${pool[i].abilities}]`,
            );
          }
        });
      } else {
        for (const f of left) {
          failed.push(
            `${f.name}: dex ${dex} ability sets cannot pair champout forms with seed rows for stats ${sig}`,
          );
        }
      }
    }
  }

  if (failed.length > 0) {
    console.error(`\nFAIL: ${failed.length} champout form(s) could not be mapped to pokedex_seed rows:\n`);
    console.error(failed.map((s) => '  - ' + s).join('\n'));
    console.error('\nAdd the missing forms/species to pokedex_seed.json, or extend the overrides table.');
    process.exit(1);
  }

  // ---- moves_seed learn inheritance -------------------------------------------
  // The moves seed's learn data (`learn` id lists + `ld` [id, level, method]
  // entries) predates the newest forms: a brand-new champion form (e.g. the
  // v1.2.0 Z-megas) has zero coverage, so its detail screen shows no moves.
  // The game's own learnsets (masterdata/waza_learn.json, one flat move list
  // per form) say which forms share a learnset — inherit from a covered
  // species form with an IDENTICAL game learnset; fail loud if none exists.
  const gameLearnsets = new Map(); // "dddefff" (champout id) -> Set<moveId>
  for (const e of Array.isArray(wazaLearn) ? wazaLearn : Object.values(wazaLearn)) {
    gameLearnsets.set(String(e.id), new Set(String(e.waza).split(',').map(Number)));
  }
  const gameLearnsetOf = (f) => {
    const key = `${String(f.dex).padStart(4, '0')}${String(f.formIndex).padStart(3, '0')}`;
    const set = gameLearnsets.get(key);
    if (!set) throw new Error(`"${f.name}": no waza_learn entry for id ${key}`);
    return set;
  };

  const movesSeed = require('../assets/moves_seed.json');
  const coveredRows = new Set();
  for (const m of movesSeed) {
    for (const id of m.learn ?? []) coveredRows.add(id);
    for (const e of m.ld ?? []) coveredRows.add(e[0]);
  }

  const learnInherited = [];
  for (const [f, row] of matched) {
    if (coveredRows.has(row.id)) continue;
    const want = gameLearnsetOf(f);
    if (want.size === 0) {
      console.log(`learn: "${f.name}" has an empty game learnset — nothing to inherit`);
      continue;
    }
    // Source: a covered seed row of the same species whose matched champout
    // form has the identical game learnset. Prefer the lowest seed id.
    const candidates = [...matched.entries()]
      .filter(([f2, row2]) => row2.speciesId === (row.speciesId ?? row.id) && coveredRows.has(row2.id))
      .filter(([f2]) => {
        const s2 = gameLearnsetOf(f2);
        return s2.size === want.size && [...want].every((w) => s2.has(w));
      })
      .sort((a, b) => a[1].id - b[1].id);
    if (candidates.length === 0) {
      console.error(
        `FAIL: "${f.name}" (#${row.id}) has no learn data and no covered species form shares its game learnset (${want.size} moves) — extend the moves seed manually.`,
      );
      process.exit(1);
    }
    const [, sourceRow] = candidates[0];
    let added = 0;
    for (const m of movesSeed) {
      if ((m.learn ?? []).includes(sourceRow.id)) {
        const list = m.learn;
        if (list.every((x, i) => i === 0 || x > list[i - 1])) {
          const at = list.findIndex((x) => x > row.id);
          list.splice(at < 0 ? list.length : at, 0, row.id);
        } else {
          list.push(row.id);
        }
        added++;
      }
      for (const e of m.ld ?? []) {
        if (e[0] === sourceRow.id) {
          m.ld.push([row.id, e[1], e[2]]);
          added++;
        }
      }
    }
    if (added === 0) {
      console.error(`FAIL: "${f.name}" inheritance from #${sourceRow.id} found no entries to copy — moves seed data is inconsistent.`);
      process.exit(1);
    }
    learnInherited.push(`${f.name} (#${row.id}) <- ${sourceRow.name} (#${sourceRow.id}): ${added} entries`);
  }

  const movesSeedFile = path.join(__dirname, '..', 'assets', 'moves_seed.json');
  const movesBefore = fs.readFileSync(movesSeedFile, 'utf8');
  const movesAfter = JSON.stringify(movesSeed);
  if (movesBefore !== movesAfter) {
    fs.writeFileSync(movesSeedFile, movesAfter);
  }

  // ---- champions_seed.json ------------------------------------------------------
  const pokemon = [...matched.entries()]
    .map(([f, row]) => ({ id: row.id, name: row.name, dex: row.speciesId ?? row.id }))
    .sort((a, b) => a.dex - b.dex || a.id - b.id);

  const items = item
    .map((it) => itemNames.get(it.ms_lbl))
    .filter(Boolean)
    .sort((a, b) => a.localeCompare(b));

  const championsOut = {
    // The upstream commit date, not "now": repeated runs over the same
    // champout version must be byte-identical so CI only commits real changes.
    generatedAt: meta.date,
    source,
    pokemon,
    items,
  };
  const championsFile = path.join(__dirname, '..', 'assets', 'champions_seed.json');
  fs.writeFileSync(championsFile, JSON.stringify(championsOut, null, 1) + '\n');

  // ---- speed_tiers.json ---------------------------------------------------------
  const tiers = pokemon
    .map((p) => {
      const seedRow = seed.find((r) => r.id === p.id);
      const b = seedRow.speed;
      return {
        id: p.id,
        name: p.name,
        base: b,
        noInvest: noInvestOf(b),
        maxPlus: maxPlusOf(b),
        max: maxOf(b),
        min: minOf(b),
        scarf: scarfOf(b),
        tailwind: tailwindOf(b),
        paralyzed: paralyzedOf(b),
      };
    })
    .sort((a, b) => b.base - a.base || a.id - b.id || a.name.localeCompare(b.name));
  let lastBase = -1;
  let lastRank = 0;
  for (let i = 0; i < tiers.length; i++) {
    if (tiers[i].base !== lastBase) {
      lastBase = tiers[i].base;
      lastRank = i + 1;
    }
    tiers[i].rank = lastRank;
  }

  const tiersOut = { updatedAt: meta.date, source, tiers };
  const tiersFile = path.join(__dirname, '..', 'assets', 'speed_tiers.json');
  fs.writeFileSync(tiersFile, JSON.stringify(tiersOut, null, 1) + '\n');

  // ---- report -------------------------------------------------------------------
  const prevById = new Map(prevChampions.pokemon.map((p) => [p.id, p.name]));
  const nowIds = new Set(pokemon.map((p) => p.id));
  const added = pokemon.filter((p) => !prevById.has(p.id));
  const removed = [...prevById.entries()].filter(([id]) => !nowIds.has(id));

  console.log(`champout forms:        ${forms.length}`);
  console.log(`roster written:        ${pokemon.length} (was ${prevChampions.pokemon.length})`);
  console.log(`ability drift warned:  ${abilityDrift.length}`);
  for (const d of abilityDrift) console.log('  ~ ' + d);
  console.log(`cosmetic collapsed:    ${collapsed.length}`);
  for (const d of collapsed) console.log('  = ' + d);
  console.log(`learn inherited:       ${learnInherited.length}`);
  for (const d of learnInherited) console.log('  + ' + d);
  console.log(`roster added:          ${added.length}`);
  for (const p of added) console.log('  + ' + p.name + ' (#' + p.id + ')');
  console.log(`roster removed:        ${removed.length}`);
  for (const [id, name] of removed) console.log('  - ' + name + ' (#' + id + ')');
  console.log(`items written:         ${items.length} (was ${prevChampions.items.length})`);
  console.log(`tiers written:         ${tiers.length}`);
  console.log(`wrote ${championsFile}`);
  console.log(`wrote ${tiersFile}`);
})().catch((e) => {
  console.error('FAILED:', e);
  process.exit(1);
});
