// Builds assets/name_forms.json from pokedex_seed.json + VERIFIED Showdown
// cry probes (tool/probe_cries*.js + browser audio probes).
//
// Seed naming shapes (relative to a species' plain base name):
//   prefix-style:  "Mega Venusaur"          -> head "Mega"
//   suffix-style:  "Pikachu Rock Star"      -> tail "Rock Star"
//   compound:      "Mega Meowstic Male"     -> head "Mega" + tail "Male"
// Every head word becomes a cry rule (verified token or drop-to-base); every
// rule was verified against play.pokemonshowdown.com file existence.
// Add new forms HERE (data) - never in Dart code.
const fs = require('fs');
const path = require('path');

const seed = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'assets', 'pokedex_seed.json'), 'utf8'));

function slugify(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

// ---- 0. Plain base name per species -----------------------------------------
// Groups whose rows carry trailing words (lettered megas, gender/style words)
// defeat common-suffix derivation; curated plain bases fix those.
const CURATED_PLAIN_BASE = {
  6: 'Charizard', 25: 'Pikachu', 26: 'Raichu', 150: 'Mewtwo',
  359: 'Absol', 445: 'Garchomp', 448: 'Lucario', 678: 'Meowstic',
  801: 'Magearna', 849: 'Toxtricity', 978: 'Tatsugiri',
};
// Official punctuation spellings; a group containing one of these uses it as
// the plain base (fixes "Galarian Mr. Mime" -> base "Mr. Mime", not "Mime").
const PUNCTUATION_NAMES = {
  'ho-oh': 'Ho-Oh', 'porygon-z': 'Porygon-Z', 'mr-mime': 'Mr. Mime',
  'mr-rime': 'Mr. Rime', 'mime-jr': 'Mime Jr.', 'type-null': 'Type: Null',
  'nidoran-m': 'Nidoran M', 'nidoran-f': 'Nidoran F',
  'tapu-koko': 'Tapu Koko', 'tapu-lele': 'Tapu Lele', 'tapu-bulu': 'Tapu Bulu',
  'tapu-fini': 'Tapu Fini', 'farfetchd': "Farfetch'd", 'sirfetchd': "Sirfetch'd",
  'flabebe': 'Flabébé', 'jangmo-o': 'Jangmo-o', 'hakamo-o': 'Hakamo-o',
  'kommo-o': 'Kommo-o', 'wo-chien': 'Wo-Chien', 'chi-yu': 'Chi-Yu',
  'ting-lu': 'Ting-Lu', 'chien-pao': 'Chien-Pao',
};

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

const punctValues = new Set(Object.values(PUNCTUATION_NAMES));
const plainBase = new Map(); // speciesId -> plain display base
const warnings = [];
for (const [sid, rows] of groups) {
  const names = rows.map((r) => String(r.name));
  let plain = CURATED_PLAIN_BASE[sid] ?? commonSuffix(names);
  const punctHit = names.find((n) => punctValues.has(n));
  if (punctHit && !CURATED_PLAIN_BASE[sid]) {
    if (plain === punctHit || punctHit.endsWith(' ' + plain)) plain = punctHit;
  }
  plainBase.set(sid, plain);
}

// ---- 1. Verified cry rules ---------------------------------------------------
// Head word -> Showdown cry token where the generic "{base}-{token}" file
// EXISTS (browser-verified). Everything not listed here drops to the base cry.
const VERIFIED_TOKENS = {
  Mega: 'mega', Primal: 'primal', Crowned: 'crowned',
  'Ice Rider': 'ice', 'Shadow Rider': 'shadow', Therian: 'therian',
  Sky: 'sky', Unbound: 'unbound', Eternal: 'eternal', Eternamax: 'eternamax',
  Ultra: 'ultra', Black: 'black', White: 'white', Starter: 'starter',
  Gulping: 'gulping', Gorging: 'gorging', Roaming: 'roaming',
  Midnight: 'midnight', School: 'school', Noice: 'noice', Hangry: 'hangry',
  Hero: 'hero', Stretchy: 'stretchy', Droopy: 'droopy',
  Complete: 'complete', 10: '10',
};
// Exact display-name/slug -> cry file, for species-specific irregularities
// the generic rules cannot express (all verified against Showdown).
const cryFileOverrides = {
  'galarian slowpoke': 'slowpoke-galar',
  'slowpoke-galar': 'slowpoke-galar',
  'super gourgeist': 'gourgeist-super',
  'gourgeist-super': 'gourgeist-super',
  'female indeedee': 'indeedee-f',
  'indeedee-f': 'indeedee-f',
  'female oinkologne': 'oinkologne-f',
  'oinkologne-f': 'oinkologne-f',
  '10 power construct zygarde': 'zygarde-10',
  'zygarde-10-power-construct': 'zygarde-10',
  '50 power construct zygarde': 'zygarde',
  'dusk lycanroc': 'lycanroc-dusk',
  'lycanroc-dusk': 'lycanroc-dusk',
  'mega zygarde': 'zygarde', // the only mega whose "-mega" file is missing
  'zygarde-mega': 'zygarde',
  // Pikachu cosmetics: only "pikachu-starter" exists on Showdown.
  'pikachu starter': 'pikachu-starter',
  'pikachu-starter': 'pikachu-starter',
  'pikachu rock star': 'pikachu',
  'pikachu belle': 'pikachu',
  'pikachu pop star': 'pikachu',
  'pikachu phd': 'pikachu',
  'pikachu libre': 'pikachu',
  'pikachu cosplay': 'pikachu',
  'pikachu original cap': 'pikachu',
  'pikachu hoenn cap': 'pikachu',
  'pikachu sinnoh cap': 'pikachu',
  'pikachu unova cap': 'pikachu',
  'pikachu kalos cap': 'pikachu',
  'pikachu partner cap': 'pikachu',
  'pikachu world cap': 'pikachu',
};

// ---- 2. Derive head/tail vocabulary from every row ---------------------------
const heads = new Map(); // head word -> example row name
const tails = new Map(); // tail phrase -> example row name (suffix-style rows)
let compoundCount = 0;
for (const [sid, rows] of groups) {
  const plain = plainBase.get(sid);
  for (const r of rows) {
    const name = String(r.name);
    if (name === plain) continue; // plain base row: cry = sanitized base
    if (name.endsWith(plain)) {
      const head = name.slice(0, name.length - plain.length).trim();
      if (head) heads.set(head, name);
      continue;
    }
    if (name.startsWith(plain + ' ')) {
      const tail = name.slice(plain.length + 1).trim();
      if (tail) tails.set(tail, name);
      continue;
    }
    // compound: "{head} {plain} {tail}"
    const idx = name.indexOf(plain);
    if (idx > 0 && idx + plain.length < name.length) {
      const head = name.slice(0, idx).trim();
      const tail = name.slice(idx + plain.length).trim();
      if (head && tail) {
        heads.set(head, name);
        tails.set(tail, name);
        compoundCount++;
        continue;
      }
    }
    warnings.push(`uncapturable row: id ${r.id} ${JSON.stringify(name)} (plain base ${JSON.stringify(plain)})`);
  }
}

// ---- 3. displayForms: head word -> cry rule ----------------------------------
const displayForms = {};
for (const head of [...heads.keys()].sort((a, b) => b.length - a.length)) {
  if (VERIFIED_TOKENS[head] !== undefined) {
    displayForms[head] = { token: VERIFIED_TOKENS[head] };
  } else {
    displayForms[head] = { token: slugify(head), cry: 'drop' };
  }
}
// Lettered megas: "Mega Charizard X" -> cry "charizard-megax".
displayForms.Mega.letterTrailing = true;

// ---- 4. slugForms: slug token -> display rule --------------------------------
const slugForms = {};
for (const head of heads.keys()) {
  slugForms[slugify(head)] = { display: head };
}
// Lettered mega tokens (both PokeAPI "mega-x" and Showdown "megax" styles).
for (const letter of ['x', 'y', 'z']) {
  slugForms[`mega-${letter}`] = { display: 'Mega', letterAfter: letter.toUpperCase() };
  slugForms[`mega${letter}`] = { display: 'Mega', letterAfter: letter.toUpperCase() };
}
// Curated slug-side entries: PokeAPI slug vocabulary that differs from the
// seed's display words. These override any auto-derived entry.
const CURATED_SLUG_FORMS = {
  alola: { display: 'Alolan' },
  galar: { display: 'Galarian' },
  hisui: { display: 'Hisuian' },
  paldea: { display: 'Paldean' },
  gmax: { display: 'Gigantamax' },
  m: { display: 'Male' },
  f: { display: 'Female' },
  male: { display: 'Male' },
  female: { display: 'Female' },
  ice: { display: 'Ice Rider' },
  shadow: { display: 'Shadow Rider' },
  '10-power-construct': { display: '10 Power Construct' },
  '50-power-construct': { display: '50 Power Construct' },
  'galar-standard': { display: 'Galarian' },
  'galar-standard-mode': { display: 'Galarian' },
  'galar-zen-mode': { display: 'Galarian Zen Mode' },
  'standard-mode': { display: 'Standard' },
  'paldean-combat-breed': { display: 'Combat Breed Paldean' },
  'paldean-blaze-breed': { display: 'Blaze Breed Paldean' },
  'paldean-aqua-breed': { display: 'Aqua Breed Paldean' },
};
for (const [token, entry] of Object.entries(CURATED_SLUG_FORMS)) {
  slugForms[token] = { ...entry };
}
// Whole-slug entries for suffix-style rows ("pikachu-rock-star" etc.).
function plainSlugForTail(tail) {
  for (const [sid, rows] of groups) {
    if (rows.some((r) => String(r.name) === `${plainBase.get(sid)} ${tail}`)) {
      return slugify(plainBase.get(sid));
    }
  }
  return '';
}
for (const tail of tails.keys()) {
  const baseSlug = plainSlugForTail(tail);
  if (!baseSlug) continue;
  const example = tails.get(tail);
  slugForms[`${baseSlug}-${slugify(tail)}`] = { display: example, whole: true };
}

// ---- 5. Base-name fixups (space-separated inputs) -----------------------------
const baseNameFixups = {
  'ho oh': 'Ho-Oh', 'porygon z': 'Porygon-Z', 'mr mime': 'Mr. Mime',
  'mr rime': 'Mr. Rime', 'mime jr': 'Mime Jr.', 'type null': 'Type: Null',
  'nidoran m': 'Nidoran M', 'nidoran f': 'Nidoran F', 'tapu koko': 'Tapu Koko',
  'tapu lele': 'Tapu Lele', 'tapu bulu': 'Tapu Bulu', 'tapu fini': 'Tapu Fini',
  farfetchd: "Farfetch'd", sirfetchd: "Sirfetch'd", flabebe: 'Flabébé',
  'jangmo o': 'Jangmo-o', 'hakamo o': 'Hakamo-o', 'kommo o': 'Kommo-o',
  'wo chien': 'Wo-Chien', 'chi yu': 'Chi-Yu', 'ting lu': 'Ting-Lu',
  'chien pao': 'Chien-Pao',
};
const displayAliases = { 'o kommo': 'Kommo-o' };

const out = {
  version: 2,
  comment: 'Generated by tool/build_name_forms.js from pokedex_seed.json + verified Showdown cry probes. Add new forms HERE (data), not in Dart.',
  displayForms,
  slugForms,
  cryFileOverrides,
  punctuationNames: PUNCTUATION_NAMES,
  baseNameFixups,
  displayAliases,
};
fs.writeFileSync(path.join(__dirname, '..', 'assets', 'name_forms.json'), JSON.stringify(out, null, 1) + '\n');
console.log(`Wrote assets/name_forms.json | heads: ${Object.keys(displayForms).length} | slugForms: ${Object.keys(slugForms).length} | overrides: ${Object.keys(cryFileOverrides).length} | compounds: ${compoundCount}`);
if (warnings.length) {
  console.log('\nWARNINGS (rows no rule covers):');
  for (const w of warnings) console.log('  ' + w);
} else {
  console.log('All seed rows covered by rules.');
}
