// Probe sharp: lossy webp at full 512px vs current 256px lossless.
const sharp = require('sharp');
const fs = require('fs');

async function main() {
  for (const p of ['assets/home/1.webp', 'assets/home/6.webp', 'assets/home_shiny/25.webp']) {
    const cur = fs.statSync(p).size;
    const out512 = await sharp(p)
      .resize(512, 512, { fit: 'inside', withoutEnlargement: true })
      .webp({ quality: 82 })
      .toBuffer();
    console.log(`${p}: current=${cur} -> sharp512q82=${out512.length}`);
  }
}
main();
