// Re-downloads original 512px Pokemon Home art (the bulk converter deleted
// the PNG sources) and re-encodes as LOSSY webp q82 via sharp.
// Also lossy-recompresses thumbnails in place (192px, q80).
// Run from project root:  node tool/redownload_home.js
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
    const buf = Buffer.from(await res.arrayBuffer());
    fs.writeFileSync(dest, buf);
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
      await worker(items[i], i);
    }
  }
  await Promise.all(Array.from({ length: CONCURRENCY }, run));
}

async function main() {
  const tmp = path.join(ROOT, 'tool', 'tmp_png');
  fs.mkdirSync(tmp, { recursive: true });

  for (const [dir, size, quality] of [
    ['assets/home', 512, 82],
    ['assets/home_shiny', 512, 82],
  ]) {
    const ids = fs.readdirSync(path.join(ROOT, dir))
      .filter(f => f.endsWith('.webp'))
      .map(f => path.basename(f, '.webp'));
    console.log(`${dir}: ${ids.length} ids to fetch at ${size}px q${quality}`);

    let missing = 0, done = 0;
    await pool(ids, async (id) => {
      const tmpPng = path.join(tmp, `${dir.replace(/[\\/]/g, '_')}_${id}.png`);
      const ok = await download(
        `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/${id}.png`,
        tmpPng);
      const out = path.join(ROOT, dir, `${id}.webp`);
      if (ok) {
        await sharp(tmpPng)
          .resize(size, size, { fit: 'inside', withoutEnlargement: true })
          .webp({ quality })
          .toFile(out);
        fs.unlinkSync(tmpPng);
      } else {
        missing++;
      }
      done++;
      if (done % 200 === 0) console.log(`  ${done}/${ids.length} (missing: ${missing})`);
    });
    console.log(`${dir} done. missing: ${missing}`);
  }

  // Thumbnails: recompress the existing 192px webps in place (lossy q80).
  const thumbDir = path.join(ROOT, 'assets/thumbnails');
  const thumbs = fs.readdirSync(thumbDir).filter(f => f.endsWith('.webp'));
  console.log(`thumbnails: recompressing ${thumbs.length} in place`);
  let t = 0;
  for (const f of thumbs) {
    const p = path.join(thumbDir, f);
    const buf = await sharp(p).webp({ quality: 80 }).toBuffer();
    fs.writeFileSync(p, buf);
    t++;
    if (t % 300 === 0) console.log(`  ${t}/${thumbs.length}`);
  }

  fs.rmSync(tmp, { recursive: true, force: true });

  const total = ['assets/home', 'assets/home_shiny', 'assets/thumbnails']
    .map(d => fs.readdirSync(path.join(ROOT, d)).reduce((s, f) => s + fs.statSync(path.join(ROOT, d, f)).size, 0))
    .reduce((a, b) => a + b, 0);
  console.log(`DONE. Asset images total: ${(total / 1048576).toFixed(0)} MB`);
}

main().catch(e => { console.error(e); process.exit(1); });
