// Inspects seed name conventions: display vs slug styles, form coverage.
const seed = require('../assets/pokedex_seed.json');
const first5 = seed.slice(0, 5).map((p) => ({ id: p.id, speciesId: p.speciesId, name: p.name, species: p.species }));
console.log('first5:', JSON.stringify(first5));
const contains = (s) => seed.filter((p) => String(p.name).includes(s)).map((p) => ({ id: p.id, name: p.name }));
console.log('Mega rows:', contains('Mega').length, JSON.stringify(contains('Mega').slice(0, 12)));
console.log('Delphox:', JSON.stringify(contains('Delphox')));
console.log('Lycanroc:', JSON.stringify(contains('Lycanroc')));
console.log('Pikachu caps:', JSON.stringify(contains('Pikachu (').slice(0, 6)));
console.log('Deoxys:', JSON.stringify(contains('Deoxys')));
console.log('Gourgeist:', JSON.stringify(contains('Gourgeist')));
console.log('Zacian/Calyrex:', JSON.stringify([...contains('Zacian'), ...contains('Calyrex')]));
const parens = seed.filter((p) => String(p.name).includes('(')).length;
console.log('names containing parentheses:', parens);
