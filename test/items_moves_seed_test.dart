import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<dynamic> moves;
  late List<dynamic> items;
  late List<dynamic> abilities;
  late List<dynamic> natures;

  setUpAll(() async {
    moves = jsonDecode(await rootBundle.loadString('assets/moves_seed.json'))
        as List<dynamic>;
    items = jsonDecode(await rootBundle.loadString('assets/items_seed.json'))
        as List<dynamic>;
    abilities =
        jsonDecode(await rootBundle.loadString('assets/abilities_seed.json'))
            as List<dynamic>;
    natures =
        jsonDecode(await rootBundle.loadString('assets/natures_seed.json'))
            as List<dynamic>;
  });

  void expectNoMojibake(List<dynamic> list, String file) {
    for (final entry in list.cast<Map>()) {
      for (final key in entry.keys) {
        final value = entry[key];
        if (value is String) {
          expect(value.contains('\uFFFD'), isFalse,
              reason: '$file ${entry['id']} field "$key" contains U+FFFD');
        }
      }
    }
  }

  group('moves_seed.json integrity', () {
    test('contains the full mainline move dex', () {
      expect(moves.length, greaterThanOrEqualTo(900));
    });

    test('no duplicate ids and no GameCube-only shadow entries', () {
      final seenIds = <int>{};
      for (final m in moves.cast<Map>()) {
        final id = m['id'] as int;
        expect(seenIds.add(id), isTrue, reason: 'duplicate move id $id');
        expect(id, lessThan(10001),
            reason: 'shadow move $id leaked into the seed');
      }
    });

    test('every move has valid required schema', () {
      const knownTypes = {
        'normal', 'fire', 'water', 'electric', 'grass', 'ice', 'fighting',
        'poison', 'ground', 'flying', 'psychic', 'bug', 'rock', 'ghost',
        'dragon', 'dark', 'steel', 'fairy',
      };
      const knownClasses = {'physical', 'special', 'status'};
      for (final m in moves.cast<Map>()) {
        final id = m['id'];
        expect(m['name'], isA<String>(), reason: 'move $id name');
        expect((m['name'] as String).isNotEmpty, isTrue, reason: 'move $id empty name');
        expect(knownTypes.contains(m['type']), isTrue,
            reason: 'move $id (${m['name']}) unknown type ${m['type']}');
        expect(knownClasses.contains(m['cls']), isTrue,
            reason: 'move $id (${m['name']}) unknown class ${m['cls']}');
        expect(m['pp'], isA<int>(), reason: 'move $id pp');
        expect(m['pp'] as int, inInclusiveRange(1, 40), reason: 'move $id pp range');
        final power = m['power'];
        if (power != null) {
          expect(power, isA<int>(), reason: 'move $id power type');
          expect(power as int, inInclusiveRange(1, 250), reason: 'move $id power range');
        }
        final acc = m['acc'];
        if (acc != null) {
          expect(acc, isA<int>(), reason: 'move $id acc type');
          expect(acc as int, inInclusiveRange(1, 100), reason: 'move $id acc range');
        }
        expect(m['gen'], isA<String>(), reason: 'move $id gen');
        // Learner list: base + alternate-form IDs, sorted, unique.
        expect(m['learn'], isA<List>(), reason: 'move $id learn list');
        final learn = (m['learn'] as List).cast<int>();
        expect(learn.toSet().length, learn.length,
            reason: 'move $id has duplicate learner ids');
        expect(learn.every((e) => e >= 1 && e <= 20000), isTrue,
            reason: 'move $id has out-of-range learner ids');
        final sorted = List.of(learn)..sort();
        expect(learn, orderedEquals(sorted),
            reason: 'move $id learner ids not sorted');
      }
    });

    test('most learnable moves ship learner data', () {
      // Struggle, event-only and Z-/Max-moves legitimately have none, but the
      // vast majority of the dex must have baked learner lists.
      final withLearners = moves
          .cast<Map>()
          .where((m) => (m['learn'] as List).isNotEmpty)
          .length;
      expect(withLearners, greaterThan(moves.length * 0.8));
    });

    test('has no mojibake', () => expectNoMojibake(moves, 'move'));
  });

  group('items_seed.json integrity', () {
    test('contains the full item catalog', () {
      expect(items.length, greaterThanOrEqualTo(2000));
    });

    test('no duplicate ids', () {
      final seenIds = <int>{};
      for (final i in items.cast<Map>()) {
        expect(seenIds.add(i['id'] as int), isTrue,
            reason: 'duplicate item id ${i['id']}');
      }
    });

    test('every item has valid required schema', () {
      for (final i in items.cast<Map>()) {
        final id = i['id'];
        expect(i['name'], isA<String>(), reason: 'item $id name');
        expect((i['name'] as String).isNotEmpty, isTrue, reason: 'item $id empty name');
        expect(i['cost'], isA<int>(), reason: 'item $id cost type');
        expect(i['cost'] as int, inInclusiveRange(0, 100000), reason: 'item $id cost range');
        expect(i['cat'], isA<String>(), reason: 'item $id category');
        expect((i['cat'] as String).isNotEmpty, isTrue, reason: 'item $id empty category');
        // Sprite may be null: many Legends Arceus / SV items have no icon
        // on PokeAPI. The UI falls back to a placeholder icon.
        if (i['sprite'] != null) {
          expect(i['sprite'], isA<String>(), reason: 'item $id sprite type');
        }
      }
    });

    test('has no mojibake', () => expectNoMojibake(items, 'item'));
  });

  group('abilities_seed.json integrity', () {
    test('contains the full ability catalog', () {
      expect(abilities.length, greaterThanOrEqualTo(350));
    });

    test('no duplicate ids', () {
      final seenIds = <int>{};
      for (final a in abilities.cast<Map>()) {
        expect(seenIds.add(a['id'] as int), isTrue,
            reason: 'duplicate ability id ${a['id']}');
      }
    });

    test('every ability has valid required schema', () {
      for (final a in abilities.cast<Map>()) {
        final id = a['id'];
        expect(a['name'], isA<String>(), reason: 'ability $id name');
        expect((a['name'] as String).isNotEmpty, isTrue,
            reason: 'ability $id empty name');
        expect(a['gen'], isA<String>(), reason: 'ability $id gen');
        expect(a['pokemon'], isA<List>(), reason: 'ability $id pokemon list');
        final pokemon = (a['pokemon'] as List).cast<int>();
        expect(pokemon.toSet().length, pokemon.length,
            reason: 'ability $id has duplicate pokemon ids');
        expect(pokemon.every((e) => e >= 1 && e <= 20000), isTrue,
            reason: 'ability $id has out-of-range pokemon ids');
        final sorted = List.of(pokemon)..sort();
        expect(pokemon, orderedEquals(sorted),
            reason: 'ability $id pokemon ids not sorted');
        final hidden = (a['hidden'] as List).cast<int>();
        expect(hidden.every(pokemon.contains), isTrue,
            reason: 'ability $id hidden ids not a subset of pokemon ids');
      }
    });

    test('most abilities ship pokemon data', () {
      final withPokemon = abilities
          .cast<Map>()
          .where((a) => (a['pokemon'] as List).isNotEmpty)
          .length;
      expect(withPokemon, greaterThan(abilities.length * 0.8));
    });

    test('has no mojibake', () => expectNoMojibake(abilities, 'ability'));
  });

  group('natures_seed.json integrity', () {
    test('contains exactly the 25 natures', () {
      expect(natures.length, 25);
    });

    test('no duplicate ids and valid schema', () {
      final seenIds = <int>{};
      final knownStats = {
        'attack', 'defense', 'speed', 'special-attack', 'special-defense',
      };
      const knownFlavors = {'sour', 'spicy', 'sweet', 'bitter', 'dry'};
      for (final n in natures.cast<Map>()) {
        final id = n['id'] as int;
        expect(seenIds.add(id), isTrue, reason: 'duplicate nature id $id');
        expect(n['name'], isA<String>(), reason: 'nature $id name');
        expect((n['name'] as String).isNotEmpty, isTrue,
            reason: 'nature $id empty name');
        final inc = n['inc'] as String?;
        final dec = n['dec'] as String?;
        // A nature either changes both stats or is fully neutral.
        expect((inc == null) == (dec == null), isTrue,
            reason: 'nature $id has only one of inc/dec');
        if (inc != null) {
          expect(knownStats.contains(inc), isTrue,
              reason: 'nature $id unknown inc stat $inc');
          expect(knownStats.contains(dec), isTrue,
              reason: 'nature $id unknown dec stat $dec');
          expect(inc, isNot(dec), reason: 'nature $id raises and lowers $inc');
        }
        final likes = n['likes'] as String?;
        final hates = n['hates'] as String?;
        if (likes != null) {
          expect(knownFlavors.contains(likes), isTrue,
              reason: 'nature $id unknown likes flavor $likes');
        }
        if (hates != null) {
          expect(knownFlavors.contains(hates), isTrue,
              reason: 'nature $id unknown hates flavor $hates');
        }
      }
    });

    test('exactly 5 neutral natures', () {
      final neutral = natures
          .cast<Map>()
          .where((n) => n['inc'] == null && n['dec'] == null)
          .length;
      expect(neutral, 5);
    });
  });
}
