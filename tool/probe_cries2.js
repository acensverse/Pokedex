// Probe round 2: concatenated variants, lettered megas, curated alternates.
const https = require('https');
const fs = require('fs');
const path = require('path');

function probe(id) {
  const url = `https://play.pokemonshowdown.com/audio/cries/${id}.mp3`;
  return new Promise((resolve) => {
    const req = https.request(url, { method: 'HEAD', timeout: 8000 }, (res) => { req.destroy(); resolve(res.statusCode === 200); });
    req.on('error', () => resolve(false));
    req.on('timeout', () => { req.destroy(); resolve(false); });
    req.end();
  });
}

// every MISS from round 1 -> candidate variants
const round1 = JSON.parse(fs.readFileSync(path.join(__dirname, 'cry_probe_results.json'), 'utf8'));
const misses = Object.entries(round1).filter(([, s]) => s !== 'OK').map(([id]) => id);

const variants = new Map();
for (const id of misses) {
  const base = id.split('-')[0];
  const rest = id.split('-').slice(1);
  const v = new Set();
  v.add(base + rest.join('')); // concatenated
  v.add([base, ...rest].join('-')); // original
  variants.set(id, [...v]);
}
// curated alternates
const curated = {
  'calyrex-ice-rider': ['calyrex-ice'],
  'calyrex-shadow-rider': ['calyrex-shadow'],
  'ogerpon-wellspring-mask': ['ogerpon-wellspring'],
  'ogerpon-hearthflame-mask': ['ogerpon-hearthflame'],
  'ogerpon-cornerstone-mask': ['ogerpon-cornerstone'],
  'zygarde-50-power-construct': ['zygarde-50'],
  'zygarde-10-power-construct': ['zygarde-10'],
  'maushold-family-of-three': ['maushold-three', 'mausholdthree'],
  'maushold-family-of-four': ['maushold'],
  'dudunsparce-three-segment': ['dudunsparce-three', 'dudunsparce-three-segment'],
  'dudunsparce-two-segment': ['dudunsparce'],
  'squawkabilly-white-plumage': ['squawkabilly-white', 'squawkabillywhite'],
  'tauros-paldean-combat-breed': ['tauros-paldean-combat', 'tauros-combat-breed'],
  'tauros-blaze-breed-paldean': ['tauros-blaze-breed'],
  'tauros-aqua-breed-paldean': ['tauros-aqua-breed'],
  'single-strike-urshifu-gigantamax': ['urshifu-single-strike', 'urshifu-single-strike-gmax'],
  'greninja-battle-bond': ['greninja-battle-bond'],
  'greninja-ash': ['greninja-ash'],
  'indeedee-male': ['indeedee'],
  'indeedee-female': ['indeedee-f'],
  'meowstic-male': ['meowstic'],
  'meowstic-female': ['meowsticf', 'meowstic-f'],
  'basculegion-male': ['basculegion'],
  'basculegion-female': ['basculegion-f', 'basculegionf'],
  'oinkologne-male': ['oinkologne'],
  'oinkologne-female': ['oinkologne-f'],
  'rockruff-own-tempo': ['rockruffown-tempo', 'rockruff-own-tempo'],
  'rotom-heat': ['rotomheat'],
  'rotom-wash': ['rotomwash'],
  'rotom-frost': ['rotomfrost'],
  'rotom-fan': ['rotomfan'],
  'rotom-mow': ['rotommow'],
  'castform-sunny': ['castformsunny'],
  'castform-rainy': ['castformrainy'],
  'castform-snowy': ['castformsnowy'],
  'dialga-origin': ['dialgaorigin'],
  'palkia-origin': ['palkiaorigin'],
  'necrozma-dusk': ['necrozmadusk'],
  'necrozma-dawn': ['necrozmadawn'],
  'magearna-original': ['magearnaoriginal'],
  'zarude-dada': ['zarudedada'],
  'terapagos-terastal': ['terapagosterastal'],
  'terapagos-stellar': ['terapagosstellar'],
  'tauros-paldean-combat': ['tauroscombat'],
};
for (const [k, v] of Object.entries(curated)) {
  const existing = variants.get(k) || [];
  variants.set(k, [...new Set([...existing, ...v])]);
}
// lettered megas (suffix-style rows excluded from round 1)
const lettered = ['charizard-megax', 'charizard-megay', 'mewtwo-megax', 'mewtwo-megay', 'raichu-megax', 'raichu-megay', 'absol-megaz', 'garchomp-megaz', 'lucario-megaz', 'greninja-battle-bond'];
for (const l of lettered) if (!variants.has(l)) variants.set(l, [l]);

(async () => {
  const out = {};
  for (const [id, cands] of variants) {
    for (const c of cands) {
      if (await probe(c)) { out[id] = c; break; }
    }
    if (!out[id]) out[id] = null;
  }
  fs.writeFileSync(path.join(__dirname, 'cry_probe_results2.json'), JSON.stringify(out, null, 1));
  const ok = Object.entries(out).filter(([, v]) => v);
  console.log('RESOLVED:', ok.length, '/', Object.keys(out).length);
  for (const [id, file] of ok) console.log('  ', id, '->', file);
  console.log('UNRESOLVED (drop to base cry):');
  for (const [id, file] of Object.entries(out)) if (!file) console.log('  ', id);
})();
