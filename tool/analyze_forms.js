// Finds every form row whose display name does NOT end with the species'
// common base name, so the generator can be fixed to cover them all.
const seed = require('../assets/pokedex_seed.json');

// Group rows by speciesId
const groups = new Map();
for (const p of seed) {
  const sid = p.speciesId ?? p.id;
  if (!groups.has(sid)) groups.set(sid, []);
  groups.get(sid).push(p);
}

// Plain base display name = longest suffix shared by ALL names in the group.
function commonSuffix(names) {
  if (names.length === 1) return names[0];
  let best = '';
  const first = names[0];
  for (let len = 1; len <= first.length; len++) {
    const candidate = first.slice(first.length - len);
    if (candidate.startsWith(' ')) break;
    if (names.every((n) => n.endsWith(candidate))) best = candidate;
  }
  return best.trim() || first;
}

const missed = [];
for (const [sid, rows] of groups) {
  const base = rows.find((r) => r.id === sid) ?? rows[0];
  const plain = commonSuffix(rows.map((r) => String(r.name)));
  for (const r of rows) {
    const name = String(r.name);
    if (!name.endsWith(plain) && name !== plain) {
      missed.push({ id: r.id, name, base: base.name, plain });
    }
  }
}
console.log('uncaptured form rows:', missed.length);
for (const m of missed) console.log(' ', `id ${m.id}`, JSON.stringify(m.name), '| group plain base:', JSON.stringify(m.plain), '| base row:', JSON.stringify(m.base));
