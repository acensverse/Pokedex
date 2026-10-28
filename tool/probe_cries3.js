// Probe round 3: PokeAPI-style regional tokens (alola/galar/hisui/paldea),
// Tauros breeds, and base punctuation names (farfetchd/sirfetchd).
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

const toProbe = [
  'rattata-alola', 'raticate-alola', 'raichu-alola', 'sandshrew-alola', 'sandslash-alola',
  'vulpix-alola', 'ninetales-alola', 'diglett-alola', 'dugtrio-alola', 'meowth-alola',
  'meowth-galar', 'persian-alola', 'geodude-alola', 'graveler-alola', 'golem-alola',
  'ponyta-galar', 'rapidash-galar', 'slowpoke-galar', 'slowbro-galar', 'slowking-galar',
  'farfetchd-galar', 'grimer-alola', 'muk-alola', 'exeggutor-alola', 'marowak-alola',
  'weezing-galar', 'mr-mime-galar', 'articuno-galar', 'zapdos-galar', 'moltres-galar',
  'typhlosion-hisui', 'wooper-paldea', 'qwilfish-hisui', 'sneasel-hisui', 'corsola-galar',
  'zigzagoon-galar', 'linoone-galar', 'voltorb-hisui', 'electrode-hisui', 'stunfisk-galar',
  'braviary-hisui', 'samurott-hisui', 'lilligant-hisui', 'zorua-hisui', 'zoroark-hisui',
  'sliggoo-hisui', 'goodra-hisui', 'avalugg-hisui', 'decidueye-hisui', 'growlithe-hisui',
  'arcanine-hisui', 'darumaka-galar', 'yamask-galar',
  'tauros-combat-breed', 'tauros-blaze-breed', 'tauros-aqua-breed', 'tauros-paldean-combat-breed',
  'farfetchd', 'sirfetchd', 'flabebe', 'kommo-o', 'pikachu-original-cap', 'pikachu-hoenn-cap',
  'deoxys-normal', 'deoxys-attack', 'giratina-origin', 'giratina-altered', 'shaymin-sky',
  'tornadus-therian', 'tornadus-incarnate', 'landorus-therian', 'keldeo-resolute', 'keldeo-ordinary',
  'meloetta-pirouette', 'meloetta-aria', 'aegislash-blade', 'aegislash-shield', 'wishiwashi-school',
  'wishiwashi-solo', 'minior-orange', 'minior-red', 'basculin-blue-striped', 'basculin-red-striped',
  'toxtricity-low-key', 'toxtricity-amped', 'eiscue-noice', 'eiscue-ice', 'morpeko-hangry',
  'morpeko-full-belly', 'urshifu-rapid-strike', 'urshifu-single-strike', 'tatsugiri-curly',
  'tatsugiri-droopy', 'palafin-hero', 'palafin-zero', 'dudunsparce-two-segment', 'dudunsparce-three-segment',
  'maushold-family-of-three', 'maushold-family-of-four', 'squawkabilly-white-plumage',
  'oogerpon', 'ogerpon-wellspring-mask', 'ogerpon-cornerstone', 'ogerpon-hearthflame',
  'zygarde-50', 'zygarde-10-power-construct', 'eternatus-eternamax',
];

(async () => {
  const out = {};
  await Promise.all(toProbe.map(async (id) => { out[id] = (await probe(id)) ? 'OK' : 'MISS'; }));
  fs.writeFileSync(path.join(__dirname, 'cry_probe_results3.json'), JSON.stringify(out, null, 1));
  const ok = Object.entries(out).filter(([, s]) => s === 'OK').map(([id]) => id);
  const miss = Object.entries(out).filter(([, s]) => s !== 'OK').map(([id]) => id);
  console.log('OK (' + ok.length + '):', ok.join(' '));
  console.log('\nMISS (' + miss.length + '):', miss.join(' '));
})();
