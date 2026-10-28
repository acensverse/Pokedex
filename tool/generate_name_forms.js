// Generates assets/name_forms.json from pokedex_seed.json.
// Every display-form prefix and slug token is DERIVED from the real seed data
// (rows with id != speciesId are forms; their base name is the row with
// id == speciesId). Output is curated cry rules + display templates.
const fs = require('fs');
const path = require('path');

const seed = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'assets', 'pokedex_seed.json'), 'utf8'));
const baseById = new Map();
for (const p of seed) if (p.id === p.speciesId) baseById.set(p.speciesId, p.name);

const forms = [];
for (const p of seed) {
  if (p.id === p.speciesId) continue;
  const baseName = baseById.get(p.speciesId);
  if (!baseName) continue;
  const name = String(p.name);
  if (!name.endsWith(baseName)) continue; // only prefix-style rows
  forms.push({ id: p.id, name, baseName, prefix: name.slice(0, name.length - baseName.length).trim() });
}

// Unique display prefixes (longest first for matching)
const prefixCounts = new Map();
for (const f of forms) prefixCounts.set(f.prefix, (prefixCounts.get(f.prefix) || 0) + 1);
const displayPrefixes = [...prefixCounts.entries()].sort((a, b) => b[0].length - a[0].length);

// Collect suffix tokens from names that do NOT end with their base (suffix-style rows)
const suffixStyle = [];
for (const p of seed) {
  if (p.id === p.speciesId) continue;
  const baseName = baseById.get(p.speciesId);
  if (!baseName) continue;
  const name = String(p.name);
  if (name.endsWith(baseName)) continue;
  suffixStyle.push({ id: p.id, name, baseName, token: slugify(name.slice(0, name.length - baseName.length).trim()) });
}

function slugify(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

console.log('FORM PREFIX VOCABULARY (count | prefix | example):');
const examples = new Map();
for (const f of forms) if (!examples.has(f.prefix)) examples.set(f.prefix, `${f.name} (id ${f.id})`);
for (const [prefix, count] of displayPrefixes) console.log(String(count).padStart(3), '|', JSON.stringify(prefix), '|', examples.get(prefix));
console.log('\nSUFFIX-STYLE ROWS (not ending with base name):');
for (const s of suffixStyle) console.log(' ', `id ${s.id}`, JSON.stringify(s.name), 'base:', JSON.stringify(s.baseName));
