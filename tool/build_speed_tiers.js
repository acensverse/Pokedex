// Builds assets/speed_tiers.json — Pokémon Champions Level-50 speed tiers
// keyed to the app's pokedex_seed.json row ids — from the pokemon-zone.com
// extract in research/data/pokemon-zone-speed-tiers.json.
//
// pokemon-zone names are display-style with bracketed forms ("Persian [Alolan
// Form]", "Tauros [Paldean Form (Combat Breed)]"). A bracket rule converts
// them to the seed's adjective-first style ("Alolan Persian", "Combat Breed
// Paldean Tauros"); names no rule can produce are handled by explicit
// overrides. Unresolved entries fail the build so new upstream names get
// mapped instead of silently dropping out.
//
// Two integrity checks fail the build:
//   1. every row's computed columns must match the Level-50 formulas the
//      site uses (they are pure functions of base Speed) — this is what makes
//      the app's seed-speed fallback exact;
//   2. every mapped row's base Speed must equal the pokedex seed's speed stat.
//
// Run: node tool/build_speed_tiers.js

const fs = require('fs');
const path = require('path');

const seed = require('../assets/pokedex_seed.json');
const rosterSeed = require('../assets/champions_seed.json');
const site = require('../research/data/pokemon-zone-speed-tiers.json');

// Lowercase, fold accents, drop every non-alphanumeric character — must stay
// in sync with NameForms.normalizeKey (lib/core/utils/name_forms.dart).
function normalizeName(s) {
  return s
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]/g, '');
}

// pokemon-zone name -> seed display name(s). Multi-target entries expand into
// every matching seed row (gendered forms share one upstream row). Same
// conventions as tool/build_champions_seed.js.
const overrides = {
  Meowstic: ['Male Meowstic'],
  'Mega Meowstic': ['Mega Meowstic Male', 'Mega Meowstic Female'],
  Indeedee: ['Male Indeedee'],
  Aegislash: ['Shield Aegislash'],
  Gourgeist: ['Average Gourgeist'],
  Lycanroc: ['Midday Lycanroc'],
  Mimikyu: ['Disguised Mimikyu'],
  Morpeko: ['Full Belly Morpeko'],
  Maushold: ['Family Of Four Maushold'],
  Toxtricity: ['Amped Toxtricity'],
  'Aegislash [Blade Forme]': ['Blade Aegislash'],
  'Gourgeist [Jumbo Variety]': ['Super Gourgeist'],
  Squawkabilly: ['Green Plumage Squawkabilly'],
  Palafin: ['Zero Palafin'],
  Basculegion: ['Male Basculegion'],
};

// "Base [Adj Form]" -> "Adj Base" (seed style). "Base [Region Form (Breed)]"
// -> "Breed Region Base". Returns every candidate worth trying, in order.
function bracketCandidates(name) {
  const m = name.match(/^(.+?)\s*\[([^\]]+)\]$/);
  if (!m) return [];
  const base = m[1].trim();
  const inner = m[2]
    .replace(/\s*\bForm\b\s*/gi, ' ')
    .replace(/\s*\bVariety\b\s*/gi, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  const paren = inner.match(/^(.*?)\s*\((.+)\)\s*$/);
  if (paren) {
    const region = paren[1].trim();
    const breed = paren[2].trim();
    return [`${breed} ${region} ${base}`, `${region} ${breed} ${base}`];
  }
  if (inner.length === 0) return [];
  return [`${inner} ${base}`];
}

// Seed indexes: normalized name -> rows.
const byNormName = new Map();
for (const row of seed) {
  const key = normalizeName(row.name);
  if (!byNormName.has(key)) byNormName.set(key, []);
  byNormName.get(key).push(row);
}

function resolveEntry(name) {
  // 1. Explicit override.
  const override = overrides[name];
  if (override) {
    const rows = [];
    for (const target of override) {
      const match = byNormName.get(normalizeName(target));
      if (!match) {
        throw new Error(
          `Override target "${target}" (for pokemon-zone "${name}") not found in pokedex_seed.json`,
        );
      }
      rows.push(...match);
    }
    return rows;
  }

  // 2. Direct display-name match.
  const direct = byNormName.get(normalizeName(name));
  if (direct) return direct;

  // 3. Bracketed form rule.
  for (const candidate of bracketCandidates(name)) {
    const match = byNormName.get(normalizeName(candidate));
    if (match) return match;
  }

  return null;
}

// ---- Level-50 formulas (verified against every site row below) --------------
// Level 50, max IVs (31): stat = floor((2*base + IV + floor(EV/4)) * 50/100) + 5.
const noInvestOf = (b) => b + 20; // 0 EVs, neutral nature
const maxOf = (b) => b + 52; // full EVs (floor(252/4)=63), neutral nature
const maxPlusOf = (b) => Math.floor(maxOf(b) * 1.1); // + positive nature
const minOf = (b) => Math.floor(noInvestOf(b) * 0.9); // 0 EVs, negative nature
const scarfOf = (b) => Math.floor(maxPlusOf(b) * 1.5); // Choice Scarf / +1
const tailwindOf = (b) => maxPlusOf(b) * 2; // Tailwind / +2
const paralyzedOf = (b) => Math.floor(maxPlusOf(b) * 0.5); // paralysis halves

// ---- resolve every site row ---------------------------------------------------

const rosterById = new Map(rosterSeed.pokemon.map((p) => [p.id, p]));
const tiersById = new Map(); // seed row id -> tier
const unresolved = [];
const outsideRoster = [];
const baseMismatches = [];
const formulaMismatches = [];
const duplicateClaims = new Map(); // seed row id -> first site name

for (const row of site.rows) {
  // Formula check first: the fallback path depends on these being exact.
  const b = row.base;
  const expected = {
    noInvest: noInvestOf(b),
    max: maxOf(b),
    maxPlus: maxPlusOf(b),
    min: minOf(b),
    scarf: scarfOf(b),
    tailwind: tailwindOf(b),
    paralyzed: paralyzedOf(b),
  };
  for (const [key, value] of Object.entries(expected)) {
    if (row[key] !== value) {
      formulaMismatches.push(`${row.name}: ${key} ${row[key]} != ${value}`);
    }
  }

  const rows = resolveEntry(row.name);
  if (!rows) {
    unresolved.push(row.name);
    continue;
  }
  for (const seedRow of rows) {
    if (!rosterById.has(seedRow.id)) {
      outsideRoster.push(`${row.name} -> ${seedRow.name} (#${seedRow.id})`);
      continue;
    }
    if (seedRow.speed !== row.base) {
      baseMismatches.push(
        `${row.name} (site base ${row.base}) -> ${seedRow.name} (#${seedRow.id}) seed speed ${seedRow.speed}`,
      );
    }
    const previous = duplicateClaims.get(seedRow.id);
    if (previous !== undefined && previous !== row.name) {
      console.warn(
        `WARNING: seed row ${seedRow.id} (${seedRow.name}) claimed by both "${previous}" and "${row.name}"`,
      );
    }
    duplicateClaims.set(seedRow.id, row.name);
    tiersById.set(seedRow.id, {
      id: seedRow.id,
      name: seedRow.name,
      base: row.base,
      noInvest: row.noInvest,
      maxPlus: row.maxPlus,
      max: row.max,
      min: row.min,
      scarf: row.scarf,
      tailwind: row.tailwind,
      paralyzed: row.paralyzed,
    });
  }
}

// Roster Pokemon with no site row: fall back to the (verified) formulas so the
// screen never shows gaps. Warned so upstream additions stay visible.
const fallbackNames = [];
for (const p of rosterSeed.pokemon) {
  if (tiersById.has(p.id)) continue;
  const seedRow = seed.find((r) => r.id === p.id);
  const b = seedRow.speed;
  fallbackNames.push(`${p.name} (#${p.id})`);
  tiersById.set(p.id, {
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
  });
}

// ---- rank + write -------------------------------------------------------------
// Competition ranking by base Speed desc (ties share the site's rank style:
// 1, 1, 1, 4, ...), matching the pokemon-zone table.
const tiers = [...tiersById.values()].sort(
  (a, b) => b.base - a.base || a.id - b.id || a.name.localeCompare(b.name),
);
let lastBase = -1;
let lastRank = 0;
for (let i = 0; i < tiers.length; i++) {
  if (tiers[i].base !== lastBase) {
    lastBase = tiers[i].base;
    lastRank = i + 1;
  }
  tiers[i].rank = lastRank;
}

const out = {
  updatedAt: site.scrapedAt,
  source: site.source,
  tiers,
};
const outFile = path.join(__dirname, '..', 'assets', 'speed_tiers.json');
fs.writeFileSync(outFile, JSON.stringify(out, null, 1) + '\n');

// ---- report -------------------------------------------------------------------

console.log(`site rows:                  ${site.rows.length}`);
console.log(`tiers written:              ${tiers.length}`);
console.log(`unresolved site names:      ${unresolved.length}`);
if (unresolved.length > 0) console.log('  ' + unresolved.join(' | '));
console.log(`resolved outside roster:    ${outsideRoster.length}`);
if (outsideRoster.length > 0) console.log('  ' + outsideRoster.join(' | '));
console.log(`base speed mismatches:      ${baseMismatches.length}`);
if (baseMismatches.length > 0) console.log('  ' + baseMismatches.join(' | '));
console.log(`formula mismatches:         ${formulaMismatches.length}`);
if (formulaMismatches.length > 0) console.log('  ' + formulaMismatches.join(' | '));
console.log(`fallback (no site row):     ${fallbackNames.length}`);
if (fallbackNames.length > 0) console.log('  ' + fallbackNames.join(' | '));
console.log(`wrote ${outFile} (${tiers.length} tiers)`);

if (
  unresolved.length > 0 ||
  formulaMismatches.length > 0 ||
  baseMismatches.length > 0
) {
  console.error(
    '\nFAIL: fix the issues above — add overrides for unresolved names, and investigate any speed mismatch before accepting it.',
  );
  process.exit(1);
}
