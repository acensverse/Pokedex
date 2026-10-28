// Extracts all form-suffix tokens from pokedex_seed.json so the name rules
// file can be verified against the real data. Run: node tool/extract_form_tokens.js
const fs = require('fs');
const path = require('path');
const seed = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'assets', 'pokedex_seed.json'), 'utf8'));
const tokenCounts = new Map();
for (const p of seed) {
  const name = String(p.name || '');
  if (!name.includes('-')) continue;
  const parts = name.split('-');
  const baseLen = Math.max(1, parts.length - 1);
  const token = parts.slice(baseLen).join('-');
  tokenCounts.set(token, (tokenCounts.get(token) || 0) + 1);
}
const sorted = [...tokenCounts.entries()].sort((a, b) => b[1] - a[1]);
console.log('total rows:', seed.length, '| names with suffix:', sorted.reduce((n, [, c]) => n + c, 0));
for (const [token, count] of sorted) console.log(String(count).padStart(3), token);
