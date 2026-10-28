// Inspects assets/pokedex_seed.json row shape + name coverage vs champsmeta.
const seed = require('../assets/pokedex_seed.json');
console.log('seed count:', seed.length);
console.log('seed sample:', JSON.stringify(seed.slice(0, 3), null, 1));
console.log('seed keys:', Object.keys(seed[0]).join(','));

// Form rows? show rows whose name has a space or differs from base naming
const forms = seed.filter((r) => /mega|alola|galar|hisui|paldea|torch|ride/i.test(r.name));
console.log('\nform-ish rows:', forms.length);
console.log(forms.slice(0, 12).map((r) => `${r.id}:${r.name}`).join(' | '));

// champsmeta species names vs seed names: direct match rate
const champs = require('../research/data/champsmeta-species.json');
const byName = new Map(seed.map((r) => [r.name.toLowerCase(), r]));
let direct = 0;
const missing = [];
for (const c of champs) {
  if (byName.has(c.name.toLowerCase())) direct++;
  else missing.push(c.name);
}
console.log('\nchampsmeta species:', champs.length, 'direct name match:', direct);
console.log('unmatched:', missing.length);
console.log(missing.slice(0, 40).join(' | '));

// items
const items = require('../research/data/champsmeta-items.json');
console.log('\nitems type:', Array.isArray(items) ? 'array' : typeof items);
console.log('items sample:', JSON.stringify(Array.isArray(items) ? items.slice(0, 8) : Object.entries(items).slice(0, 8), null, 1));
