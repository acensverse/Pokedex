// Dumps the COMPLETE form-word vocabulary: for every seed row, the leading
// and trailing words relative to the species' plain base name.
const seed = require('../assets/pokedex_seed.json');
const groups = new Map();
for (const p of seed) {
  const sid = p.speciesId ?? p.id;
  if (!groups.has(sid)) groups.set(sid, []);
  groups.get(sid).push(p);
}
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
const leading = new Map(); // word(s) -> example
const trailing = new Map();
for (const [sid, rows] of groups) {
  const plain = commonSuffix(rows.map((r) => String(r.name)));
  for (const r of rows) {
    const name = String(r.name);
    if (!name.endsWith(plain)) continue; // irregular rows already listed
    const head = name.slice(0, name.length - plain.length).trim();
    if (head && !leading.has(head)) leading.set(head, name);
  }
}
// Trailing words: names that START with a known plain-ish base but have extra tail.
// Detect via base row: rows whose name starts with the base row's name + ' '.
for (const [sid, rows] of groups) {
  const base = rows.find((r) => r.id === sid);
  if (!base) continue;
  const baseName = String(base.name);
  for (const r of rows) {
    const name = String(r.name);
    if (r.id === sid) continue;
    if (name.startsWith(baseName + ' ')) {
      const tail = name.slice(baseName.length + 1).trim();
      if (tail && !trailing.has(tail)) trailing.set(tail, name);
    }
  }
}
console.log('=== LEADING form words (relative to plain base) ===');
for (const [w, ex] of [...leading].sort((a, b) => b[0].length - a[0].length)) console.log(JSON.stringify(w), '<-', ex);
console.log('=== TRAILING words (after base row name) ===');
for (const [w, ex] of [...trailing].sort((a, b) => b[0].length - a[0].length)) console.log(JSON.stringify(w), '<-', ex);
