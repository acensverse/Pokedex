// Probes play.pokemonshowdown.com cry files for every form derived from the
// seed, so name_forms.json contains VERIFIED cry rules, not guesses.
const seed = require('../assets/pokedex_seed.json');
const baseById = new Map();
for (const p of seed) if (p.id === p.speciesId) baseById.set(p.speciesId, p.name);

function slugify(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

// Build candidate cry ids from form rows
const candidates = new Map(); // cryId -> example display name
for (const p of seed) {
  if (p.id === p.speciesId) continue;
  const baseName = baseById.get(p.speciesId);
  if (!baseName) continue;
  const name = String(p.name);
  if (!name.endsWith(baseName)) continue; // prefix-style rows only
  const prefix = name.slice(0, name.length - baseName.length).trim();
  if (!prefix) continue;
  const base = slugify(baseName);
  let token = slugify(prefix);
  // Lettered megas: "Mega Charizard X" -> charizard-megax ; "Mega Garchomp Z" -> garchomp-megaz
  const letter = token.match(/^(mega-(?:[xyz]))$/);
  if (letter) token = letter[1].replace('-', '');
  const cryId = token === 'gmax' ? base : `${base}-${token}`;
  if (!candidates.has(cryId)) candidates.set(cryId, name);
}
// Alternates for known Showdown quirks
const alternates = new Map();
for (const [id] of candidates) {
  const base = id.split('-')[0];
  const alt = [];
  if (id === 'maushold-family-of-three') alt.push('maushold-three');
  if (id === 'maushold-family-of-four') alt.push('maushold');
  if (id === 'dudunsparce-two-segment') alt.push('dudunsparce');
  if (id === 'dudunsparce-three-segment') alt.push('dudunsparce-three-segment');
  if (id === 'squawkabilly-white-plumage') alt.push('squawkabilly-white');
  if (id === 'squawkabilly-blue-plumage') alt.push('squawkabilly-blue');
  if (id === 'squawkabilly-yellow-plumage') alt.push('squawkabilly-yellow');
  if (id === 'squawkabilly-green-plumage') alt.push('squawkabilly-green');
  if (id === 'indeedee-male') { alt.push('indeedee-m'); alt.push('indeedee-f'); }
  if (id === 'meowstic-male') { alt.push('meowstic-m'); alt.push('meowstic-f'); }
  if (id === 'basculegion-male') alt.push('basculin'); // placeholder, real probe below
  if (id === 'oinkologne-male') { alt.push('oinkologne-m'); }
  if (id === 'zygarde-10-power-construct') alt.push('zygarde-10');
  if (id === 'zygarde-50-power-construct') alt.push('zygarde-50-power-construct');
  if (id === 'tauros-paldean-combat-breed') alt.push('tauros-paldean-combat');
  if (id === 'terapagos-terastal') alt.push('terapagos');
  if (id === 'necrozma-ultra') alt.push('necrozma-ultra');
  if (alt.length) alternates.set(id, alt);
}
// Direct probes for gendered/fusion species the generator can't see
const extra = ['indeedee-m', 'indeedee-f', 'meowstic-m', 'meowstic-f', 'basculegion-m', 'basculegion-f', 'oinkologne-m', 'oinkologne-f', 'zygarde-10', 'zygarde-50-power-construct', 'zygarde-complete', 'maushold', 'maushold-three', 'dudunsparce', 'squawkabilly-white', 'tauros-paldean-combat'];

function probe(url) {
  return new Promise((resolve) => {
    // Uses a global Audio if defined (browser); node falls back to https HEAD
    if (typeof Audio !== 'undefined') {
      const a = new Audio();
      let done = false;
      const finish = (r) => { if (!done) { done = true; a.src = ''; resolve(r); } };
      a.addEventListener('loadeddata', () => finish('OK'));
      a.addEventListener('error', () => finish('MISS'));
      a.src = url;
      setTimeout(() => finish('TIMEOUT'), 5000);
    } else {
      const https = require('https');
      const req = https.request(url, { method: 'HEAD', timeout: 8000 }, (res) => { req.destroy(); resolve(res.statusCode === 200 ? 'OK' : 'MISS' + res.statusCode); });
      req.on('error', () => resolve('ERR'));
      req.on('timeout', () => { req.destroy(); resolve('TIMEOUT'); });
      req.end();
    }
  });
}

(async () => {
  const urls = [...candidates.keys()].map((c) => `https://play.pokemonshowdown.com/audio/cries/${c}.mp3`);
  const ids = [...candidates.keys()];
  const results = await Promise.all(ids.map(async (id, i) => ({ id, status: await probe(urls[i]) })));
  const extraResults = await Promise.all(extra.map(async (id) => ({ id, status: await probe(`https://play.pokemonshowdown.com/audio/cries/${id}.mp3`) })));
  const out = { ...Object.fromEntries(results.map((r) => [r.id, r.status])), ...Object.fromEntries(extraResults.map((r) => [r.id, r.status])) };
  require('fs').writeFileSync(require('path').join(__dirname, 'cry_probe_results.json'), JSON.stringify(out, null, 1));
  const ok = Object.entries(out).filter(([, s]) => s === 'OK');
  const miss = Object.entries(out).filter(([, s]) => s !== 'OK');
  console.log('OK:', ok.length, '/', Object.keys(out).length);
  console.log('\nVERIFIED OK:');
  for (const [id] of ok) console.log('  ', id);
  console.log('\nMISSING:');
  for (const [id, s] of miss) console.log('  ', id, s);
})();
