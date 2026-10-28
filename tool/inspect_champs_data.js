// Inspects the extracted champsmeta datasets for the Champions Pokedex tab.
const species = require('../research/data/champsmeta-species.json');
console.log('species count:', species.length);
console.log('species sample:', JSON.stringify(species.slice(0, 5), null, 1));
console.log('species keys:', Object.keys(species[0]).join(','));

const moves = require('../research/data/champsmeta-moves.json');
console.log('\nmoves count:', moves.length);
console.log('moves sample:', JSON.stringify(moves.slice(0, 3), null, 1));
console.log('moves keys:', Object.keys(moves[0]).join(','));

const abilities = require('../research/data/champsmeta-abilities.json');
console.log('\nabilities count:', abilities.length);
console.log('abilities sample:', JSON.stringify(abilities.slice(0, 3), null, 1));

const items = require('../research/data/champsmeta-items.json');
console.log('\nitems count:', items.length);
console.log('items sample:', JSON.stringify(items.slice(0, 3), null, 1));
