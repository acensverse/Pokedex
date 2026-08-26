// One-off: bakes `ld` (learn details) into moves_seed.json.
// For each move: ld = [[pokemonId, level, methodIdx], ...] deduped across
// game versions. Methods: 0=level-up, 1=machine, 2=egg, 3=tutor, 4=other.
// Source: every seeded Pokemon's /pokemon/{id} moves array (the ONLY place
// PokeAPI exposes per-Pokemon levels/methods).
// Run: node tool/bake_learn_details.js
const fs = require('fs');
const CONCURRENCY = 20;

const METHOD_IDX = { 'level-up': 0, 'machine': 1, 'egg': 2, 'tutor': 3 };

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

(async () => {
  const seed = JSON.parse(fs.readFileSync('assets/pokedex_seed.json', 'utf8'));
  const moves = JSON.parse(fs.readFileSync('assets/moves_seed.json', 'utf8'));

  // move slug -> move id
  const moveIdByName = new Map(moves.map(m => [m.name, m.id]));

  // Every seeded Pokemon id (base + forms) — ld must cover forms too.
  const ids = seed.map(e => e.id);
  console.log(`Pokemon to fetch: ${ids.length}, moves: ${moves.length}`);

  // Accumulate: moveId -> Map("pid|lvl|m" -> [pid, lvl, m])
  const ldByMove = new Map(moves.map(m => [m.id, new Map()]));
  let done = 0;

  await pool(ids, async (pid) => {
    const p = await getJson(`https://pokeapi.co/api/v2/pokemon/${pid}`);
    for (const slot of p.moves ?? []) {
      const moveId = moveIdByName.get(slot.move?.name);
      if (!moveId) continue; // move outside our seed (shouldn't happen)
      const seen = new Set();
      for (const d of slot.version_group_details ?? []) {
        const methodRaw = d.move_learn_method?.name ?? 'other';
        const m = METHOD_IDX[methodRaw] ?? 4;
        const lvl = d.level_learned_at ?? 0;
        const key = `${lvl}|${m}`;
        if (seen.has(key)) continue; // dedupe across game versions
        seen.add(key);
        ldByMove.get(moveId).set(`${pid}|${key}`, [pid, m === 0 ? lvl : 0, m]);
      }
    }
    done++;
    if (done % 150 === 0) {
      const total = [...ldByMove.values()].reduce((s, m) => s + m.size, 0);
      console.log(`  ${done}/${ids.length} pokemon, learn entries so far: ${total}`);
    }
  });

  for (const m of moves) {
    const map = ldByMove.get(m.id);
    const entries = [...map.values()];
    entries.sort((a, b) => a[0] - b[0] || a[1] - b[1] || a[2] - b[2]);
    m.ld = entries;
  }

  fs.writeFileSync('assets/moves_seed.json', JSON.stringify(moves));

  const totalLd = moves.reduce((s, m) => s + m.ld.length, 0);
  const size = (fs.statSync('assets/moves_seed.json').size / 1048576).toFixed(1);
  console.log(`Wrote moves_seed.json (${size} MB), total ld entries: ${totalLd}`);

  // Sample: Pikachu (25) level-up moves
  const pikachu = moves
    .filter(m => m.ld.some(e => e[0] === 25 && e[2] === 0))
    .map(m => `${m.name}@${m.ld.find(e => e[0] === 25 && e[2] === 0)[1]}`);
  console.log('Pikachu level-up sample:', pikachu.slice(0, 8).join(', '));
})();
