// Builds assets/champions_seed.json — the Champions Pokédex roster mapped to
// the app's pokedex_seed.json row ids — from the champsmeta.com extracts in
// research/data/.
//
// champsmeta species names mostly match the seed's display names already
// ("Mega Venusaur", "Ice Rider Calyrex"). The rest are resolved by a
// parenthetical rule ("Rotom (Heat)" -> "Heat Rotom", "Raichu (Alolan)" ->
// "Alolan Raichu") plus explicit overrides for names no rule can produce.
// Unresolved entries fail the build so new upstream names get mapped instead
// of silently dropping out of the roster.
//
// Run: node tool/build_champions_seed.js

const fs = require('fs');
const path = require('path');

const seed = require('../assets/pokedex_seed.json');
const champs = require('../research/data/champsmeta-species.json');
const champItems = require('../research/data/champsmeta-items.json');
const itemsSeed = require('../assets/items_seed.json');

// Lowercase, fold accents, drop every non-alphanumeric character — must stay
// in sync with NameForms.normalizeKey (lib/core/utils/name_forms.dart), which
// the app uses to match item names at runtime.
function normalizeName(s) {
  return s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]/g, '');
}

// champsmeta name -> seed display name(s). Multi-target entries expand into
// every matching seed row (gendered forms share one upstream entry).
const overrides = {
  'Tauros (Paldean)': ['Combat Breed Paldean Tauros'],
  'Tauros (Paldean Fire Breed)': ['Blaze Breed Paldean Tauros'],
  'Tauros (Paldean Water Breed)': ['Aqua Breed Paldean Tauros'],
  Meowstic: ['Male Meowstic'],
  'Mega Meowstic': ['Mega Meowstic Male', 'Mega Meowstic Female'],
  Aegislash: ['Shield Aegislash'],
  Gourgeist: ['Average Gourgeist'],
  Lycanroc: ['Midday Lycanroc'],
  Mimikyu: ['Disguised Mimikyu'],
  Morpeko: ['Full Belly Morpeko'],
  Basculegion: ['Male Basculegion'],
  Maushold: ['Family Of Four Maushold'],
  Squawkabilly: ['Green Plumage Squawkabilly'],
  Palafin: ['Zero Palafin'],
};

// Seed indexes: normalized name -> rows, speciesId -> rows.
const byNormName = new Map();
const bySpecies = new Map();
for (const row of seed) {
  const key = normalizeName(row.name);
  if (!byNormName.has(key)) byNormName.set(key, []);
  byNormName.get(key).push(row);
  if (!bySpecies.has(row.speciesId)) bySpecies.set(row.speciesId, []);
  bySpecies.get(row.speciesId).push(row);
}

function resolveEntry(entry) {
  // 1. Explicit override.
  const override = overrides[entry.name];
  if (override) {
    const rows = [];
    for (const target of override) {
      const match = byNormName.get(normalizeName(target));
      if (!match) {
        throw new Error(
          `Override target "${target}" (for champsmeta "${entry.name}") not found in pokedex_seed.json`,
        );
      }
      rows.push(...match);
    }
    return rows;
  }

  // 2. Direct display-name match.
  const direct = byNormName.get(normalizeName(entry.name));
  if (direct) return direct;

  // 3. Parenthetical form: "Base (Adj)" -> "Adj Base" or "Base Adj" within
  //    the same species, e.g. "Rotom (Heat)" -> "Heat Rotom",
  //    "Raichu (Alolan)" -> "Alolan Raichu".
  const paren = entry.name.match(/^(.+?)\s*\((.+)\)$/);
  if (paren) {
    const base = paren[1].trim();
    const adj = paren[2].trim();
    const candidates = bySpecies.get(entry.dexNumber) ?? [];
    const a = normalizeName(`${adj} ${base}`);
    const b = normalizeName(`${base} ${adj}`);
    const rows = candidates.filter(
      (r) => normalizeName(r.name) === a || normalizeName(r.name) === b,
    );
    if (rows.length > 0) return rows;
  }

  return null;
}

// ---- resolve the roster -----------------------------------------------------

const resolved = [];
const unresolved = [];
const seenIds = new Map(); // seed row id -> champsmeta name (dupe detection)

for (const entry of champs) {
  const rows = resolveEntry(entry);
  if (!rows) {
    unresolved.push(entry.name);
    continue;
  }
  for (const row of rows) {
    const previous = seenIds.get(row.id);
    if (previous !== undefined && previous !== entry.name) {
      console.warn(
        `WARNING: seed row ${row.id} (${row.name}) claimed by both "${previous}" and "${entry.name}"`,
      );
    }
    seenIds.set(row.id, entry.name);
    resolved.push({ id: row.id, name: row.name, dex: row.speciesId });
  }
}

// Sort by dex number, then id, and dedupe (multi-target overrides can push
// the same row twice when two champsmeta entries collapse onto one row).
resolved.sort((a, b) => a.dex - b.dex || a.id - b.id || a.name.localeCompare(b.name));
const roster = [];
let lastKey = '';
for (const p of resolved) {
  const key = `${p.id}`;
  if (key === lastKey) continue;
  lastKey = key;
  roster.push(p);
}

// ---- resolve the legal held items -------------------------------------------

const itemSeedNames = new Set(itemsSeed.map((i) => normalizeName(i.name)));
const items = champItems.map((i) => i.name).sort((a, b) => a.localeCompare(b));
const unmatchedItems = items.filter((n) => !itemSeedNames.has(normalizeName(n)));

// ---- write ------------------------------------------------------------------

const out = { pokemon: roster, items };
const outFile = path.join(__dirname, '..', 'assets', 'champions_seed.json');
fs.writeFileSync(outFile, JSON.stringify(out, null, 1) + '\n');

console.log(`champsmeta species entries: ${champs.length}`);
console.log(`resolved to seed rows:      ${roster.length}`);
console.log(`unresolved species:         ${unresolved.length}`);
if (unresolved.length > 0) console.log('  ' + unresolved.join(' | '));
console.log(`champsmeta items:           ${items.length}`);
console.log(`items not in items_seed:    ${unmatchedItems.length}`);
if (unmatchedItems.length > 0) console.log('  ' + unmatchedItems.join(' | '));
console.log(`wrote ${outFile} (${roster.length} pokemon, ${items.length} items)`);

if (unresolved.length > 0) {
  console.error('\nFAIL: unresolved champsmeta species — add overrides or extend the parenthetical rule.');
  process.exit(1);
}
