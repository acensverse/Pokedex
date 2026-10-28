// For each unmatched champsmeta species, list seed rows sharing its dexNumber
// so we can design explicit name-mapping rules.
const seed = require('../assets/pokedex_seed.json');
const champs = require('../research/data/champsmeta-species.json');

const byName = new Map(seed.map((r) => [r.name.toLowerCase(), r]));
const byDex = new Map();
for (const r of seed) {
  const list = byDex.get(r.speciesId) ?? [];
  list.push(r.name);
  byDex.set(r.speciesId, list);
}

const unmatched = champs.filter((c) => !byName.has(c.name.toLowerCase()));
console.log('unmatched:', unmatched.length);
for (const c of unmatched) {
  const candidates = byDex.get(c.dexNumber) ?? ['<no seed rows>'];
  console.log(`${c.name} (dex ${c.dexNumber}) -> seed: ${candidates.join(' | ')}`);
}
