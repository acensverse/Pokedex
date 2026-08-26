// Thumbnails only: lossy q80 recompress via temp+rename (Windows lock-safe).
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

async function main() {
  const dir = path.resolve(__dirname, '..', 'assets', 'thumbnails');
  const thumbs = fs.readdirSync(dir).filter(f => f.endsWith('.webp'));
  console.log(`recompressing ${thumbs.length}`);
  let before = 0, after = 0, t = 0;
  for (const f of thumbs) {
    const p = path.join(dir, f);
    const size = fs.statSync(p).size;
    // Read fully into a Buffer first so sharp never holds a file handle.
    const input = fs.readFileSync(p);
    const buf = await sharp(input).webp({ quality: 80 }).toBuffer();
    const tmp = p + '.tmp';
    fs.writeFileSync(tmp, buf);
    // Defender can briefly lock fresh files; retry the rename.
    for (let attempt = 1; ; attempt++) {
      try {
        fs.renameSync(tmp, p);
        break;
      } catch (e) {
        if (attempt >= 5) throw e;
        await new Promise(r => setTimeout(r, 150 * attempt));
      }
    }
    before += size; after += buf.length;
    t++;
    if (t % 300 === 0) console.log(`  ${t}/${thumbs.length}`);
  }
  console.log(`done: ${(before / 1048576).toFixed(1)} MB -> ${(after / 1048576).toFixed(1)} MB`);

  const total = ['assets/home', 'assets/home_shiny', 'assets/thumbnails']
    .map(d => fs.readdirSync(path.resolve(__dirname, '..', d))
      .reduce((s, f) => s + fs.statSync(path.resolve(__dirname, '..', d, f)).size, 0))
    .reduce((a, b) => a + b, 0);
  console.log(`Asset images total: ${(total / 1048576).toFixed(0)} MB`);
}
main().catch(e => { console.error(e); process.exit(1); });
