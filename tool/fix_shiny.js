// Fixes home_shiny: re-downloads from the SHINY home sprites URL
// (the previous pass accidentally used the normal artwork URL for both).
// Run from project root:  node tool/fix_shiny.js
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const CONCURRENCY = 24;
const ROOT = path.resolve(__dirname, '..');

async function download(url, dest, attempt = 1) {
  try {
    const res = await fetch(url);
    if (res.status === 404) return false;
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    fs.writeFileSync(dest, Buffer.from(await res.arrayBuffer()));
    return true;
  } catch (e) {
    if (attempt >= 4) throw new Error(`${url}: ${e.message}`);
    await new Promise(r => setTimeout(r, 400 * attempt));
    return download(url, dest, attempt + 1);
  }
}

async function pool(items, worker) {
  let next = 0;
  async function run() {
    while (next < items.length) {
      const i = next++;
      await worker(items[i]);
    }
  }
  await Promise.all(Array.from({ length: CONCURRENCY }, run));
}

async function main() {
  const dir = path.join(ROOT, 'assets', 'home_shiny');
  const ids = fs.readdirSync(dir)
    .filter(f => f.endsWith('.webp'))
    .map(f => path.basename(f, '.webp'));
  console.log(`home_shiny: ${ids.length} ids (shiny URL this time)`);

  const tmp = path.join(ROOT, 'tool', 'tmp_shiny');
  fs.mkdirSync(tmp, { recursive: true });

  let missing = 0, done = 0;
  await pool(ids, async (id) => {
    const tmpPng = path.join(tmp, `${id}.png`);
    const ok = await download(
      `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/${id}.png`,
      tmpPng);
    if (ok) {
      const out = path.join(dir, `${id}.webp`);
      const tmpOut = out + '.tmp';
      await sharp(tmpPng)
        .resize(512, 512, { fit: 'inside', withoutEnlargement: true })
        .webp({ quality: 82 })
        .toFile(tmpOut);
      fs.renameSync(tmpOut, out);
      fs.unlinkSync(tmpPng);
    } else {
      // No shiny artwork exists for this id: drop the wrong normal-colored file
      // so the app's fallback chain (shiny -> normal -> thumbnail) kicks in.
      const out = path.join(dir, `${id}.webp`);
      if (fs.existsSync(out)) fs.unlinkSync(out);
      missing++;
    }
    done++;
    if (done % 200 === 0) console.log(`  ${done}/${ids.length} (missing: ${missing})`);
  });

  fs.rmSync(tmp, { recursive: true, force: true });

  // Sanity: shiny must differ from normal for ids present in both.
  const homeDir = path.join(ROOT, 'assets', 'home');
  let identical = 0, compared = 0;
  for (const id of ids.slice(0, 300)) {
    const n = path.join(homeDir, `${id}.webp`);
    const s = path.join(dir, `${id}.webp`);
    if (fs.existsSync(n) && fs.existsSync(s)) {
      compared++;
      if (fs.statSync(n).size === fs.statSync(s).size) identical++;
    }
  }
  console.log(`done. missing: ${missing}`);
  console.log(`sanity: ${identical}/${compared} shiny files byte-identical to normal (should be ~0)`);
  const total = fs.readdirSync(dir).reduce((s, f) => s + fs.statSync(path.join(dir, f)).size, 0);
  console.log(`home_shiny total: ${(total / 1048576).toFixed(0)} MB`);
}

main().catch(e => { console.error(e); process.exit(1); });
