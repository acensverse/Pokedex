// Checks exact seed naming for families whose mega/cap cries need overrides.
const seed = require('../assets/pokedex_seed.json');
const show = (needle) =>
  seed
    .filter((p) => String(p.name).includes(needle))
    .map((p) => ({ id: p.id, name: p.name }));
for (const n of ['Pikachu', 'Meowstic', 'Tatsugiri', 'Magearna', 'Zygarde', 'Gourgeist', 'Slowpoke', 'Indeedee', 'Oinkologne', 'Basculegion', 'Gimmighoul', 'Kommo', 'Necrozma']) {
  console.log(n + ':', JSON.stringify(show(n)));
}
