// One-off: re-bakes evolutionInfo in pokedex_seed.json with CONDITIONS.
// Fetches every species' evolution chain (deduped), builds a human-readable
// condition per link, and stores the full chain per species:
//   [{id, name, evolves_from, condition}, ...]
// Forms (id >= 10001) inherit their base species' chain.
// Run: node tool/bake_evolutions.js
const fs = require('fs');
const CONCURRENCY = 24;

async function getJson(url, attempt = 1) {
  try {
    const res = await fetch(url, { headers: { 'User-Agent': 'pokedex-seed-builder' } });
    if (res.status === 429 || res.status >= 500) throw new Error(`HTTP ${res.status}`);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  } catch (e) {
    if (attempt >= 4) throw new Error(`${url} failed: ${e.message}`);
    await new Promise(r => setTimeout(r, 400 * attempt));
    return getJson(url, attempt + 1);
  }
}

async function pool(items, worker) {
  const results = new Array(items.length);
  let next = 0;
  async function run() {
    while (next < items.length) {
      const i = next++;
      results[i] = await worker(items[i], i);
    }
  }
  await Promise.all(Array.from({ length: CONCURRENCY }, run));
  return results;
}

const cap = (s) => (s ? s[0].toUpperCase() + s.slice(1) : s);

// Human-readable condition from an evolution_details entry.
function conditionFrom(d) {
  if (!d) return '';
  const t = d.trigger?.name;
  let main;
  if (t === 'level-up') {
    if (d.min_level != null) main = `Level ${d.min_level}`;
    else if (d.min_happiness != null) main = 'Happiness';
    else if (d.min_affection != null) main = 'Affection';
    else if (d.min_beauty != null) main = 'Beauty';
    else main = 'Level Up';
  } else if (t === 'use-item') {
    main = `Use ${cap((d.item?.name ?? 'item')).replace(/-/g, ' ')}`;
  } else if (t === 'trade') {
    main = 'Trade';
  } else if (t === 'shed') {
    main = 'Empty slot + Poké Ball';
  } else if (t === 'take-damage') {
    main = 'Take damage';
  } else {
    main = cap((t ?? 'evolve').replace(/-/g, ' '));
  }

  const mods = [];
  if (d.time_of_day) mods.push(cap(d.time_of_day) + 'time');
  if (d.needs_overworld_rain) mods.push('during rain');
  if (d.held_item) mods.push(`holding ${cap(d.held_item.name).replace(/-/g, ' ')}`);
  if (d.known_move) mods.push(`knowing ${cap(d.known_move.name).replace(/-/g, ' ')}`);
  if (d.known_move_type) mods.push(`knowing a ${cap(d.known_move_type.name)} move`);
  if (d.gender === 1) mods.push('Female');
  if (d.gender === 2) mods.push('Male');
  if (d.region) mods.push(`in ${cap(d.region.name)}`);
  if (d.party_species) mods.push(`with ${cap(d.party_species.name).replace(/-/g, ' ')} in party`);
  if (d.needs_full_moon) mods.push('full moon');
  if (d.turn_upside_down) mods.push('upside down');
  return [main, ...mods].join('\n');
}

function extractId(url) {
  const m = /\/(\d+)\/?$/.exec(url ?? '');
  return m ? parseInt(m[1], 10) : -1;
}

(async () => {
  const seed = JSON.parse(fs.readFileSync('assets/pokedex_seed.json', 'utf8'));

  // 1. Which base species (1-1025) exist in the seed?
  const baseIds = seed.filter(e => e.id >= 1 && e.id <= 1025).map(e => e.id);
  console.log(`Base species: ${baseIds.length}`);

  // 2. Fetch each species -> evolution_chain url (dedupe chains).
  const chainUrlOf = new Map();   // speciesId -> chainUrl
  const chainUrls = new Map();    // chainUrl -> true
  await pool(baseIds, async (id) => {
    const sp = await getJson(`https://pokeapi.co/api/v2/pokemon-species/${id}`);
    const url = sp.evolution_chain?.url ?? null;
    if (url) {
      chainUrlOf.set(id, url);
      chainUrls.set(url, true);
    }
  });
  console.log(`Species fetched, unique chains: ${chainUrls.size}`);

  // 3. Fetch each chain and record members: speciesId -> {evolves_from, condition, order}
  const chainOf = new Map(); // speciesId -> [{id, name, evolves_from, condition}]
  const urls = [...chainUrls.keys()];
  await pool(urls, async (url) => {
    const chain = await getJson(url);
    const members = [];
    function walk(node, fromId, condition) {
      const id = extractId(node.species?.url);
      if (id > 0) {
        members.push({
          id,
          name: node.species.name,
          evolves_from: fromId,
          condition: condition ?? '',
        });
      }
      for (const child of node.evolves_to ?? []) {
        walk(child, id, conditionFrom((child.evolution_details ?? [])[0]));
      }
    }
    walk(chain.chain, null, null);
    // Attach to every species that shares this chain.
    for (const [speciesId, u] of chainUrlOf) {
      if (u === url) chainOf.set(speciesId, members);
    }
  });

  // 4. Bake into seed entries. Forms inherit their base species' chain.
  let baked = 0, missing = 0;
  for (const e of seed) {
    const key = e.speciesId ?? e.id;
    const members = chainOf.get(key) ?? chainOf.get(e.id);
    if (members) {
      e.evolutionInfo = JSON.stringify(members);
      baked++;
    } else {
      e.evolutionInfo = '[]';
      missing++;
    }
  }

  fs.writeFileSync('assets/pokedex_seed.json', JSON.stringify(seed, null, 2));
  console.log(`Baked: ${baked}, no-chain: ${missing}`);

  // Samples
  for (const id of [1, 25, 700]) {
    const e = seed.find(x => x.id === id);
    console.log(`\n${id} ${e.name}: ${e.evolutionInfo.slice(0, 300)}`);
  }
})();
