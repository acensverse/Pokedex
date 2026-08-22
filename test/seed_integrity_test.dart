import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/app/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<dynamic> seed;

  setUpAll(() async {
    final raw = await rootBundle.loadString('assets/pokedex_seed.json');
    seed = jsonDecode(raw) as List<dynamic>;
  });

  group('pokedex_seed.json integrity', () {
    test('contains the full national dex', () {
      expect(seed.length, greaterThanOrEqualTo(1025));
    });

    test('has no mojibake/replacement characters (B2 regression guard)', () {
      for (final item in seed.cast<Map>()) {
        for (final key in item.keys) {
          final value = item[key];
          if (value is String) {
            expect(value.contains('\uFFFD'), isFalse,
                reason: 'entry ${item['id']} field "$key" contains U+FFFD');
          }
        }
      }
    });

    test('every entry has a valid required schema', () {
      final seenIds = <int>{};
      for (final item in seed.cast<Map>()) {
        final id = item['id'];
        expect(id, isA<int>(), reason: 'id must be int');
        expect(seenIds.add(id as int), isTrue, reason: 'duplicate id $id');
        // IDs above 10000 are legitimate alternate-form entries
        expect(id, inExclusiveRange(0, 20000));

        expect(item['name'], isA<String>());
        expect((item['name'] as String).isNotEmpty, isTrue,
            reason: 'entry $id has empty name');

        // Types must be a comma-separated list of known types
        expect(item['types'], isA<String>());
        final types = (item['types'] as String).split(',');
        for (final type in types) {
          expect(AppColors.typeColors.containsKey(type.trim()), isTrue,
              reason: 'entry $id has unknown type "$type"');
        }

        // Base stats must be plausible
        for (final statKey in ['hp', 'attack', 'defense', 'spAttack', 'spDefense', 'speed']) {
          final value = item[statKey];
          expect(value, isA<int>(),
              reason: 'entry $id field "$statKey" must be int');
          expect(value as int, inInclusiveRange(1, 255),
              reason: 'entry $id field "$statKey" out of range');
        }

        // Physical stats in metres/kg. Base species must be positive;
        // alternate forms (id >= 10001) may legitimately be 0, e.g. the
        // "???" weight of Eternamax Eternatus (form of #890).
        expect(item['height'], isA<double>());
        expect(item['weight'], isA<double>());
        if (id < 10001) {
          expect(item['height'] as double, greaterThan(0),
              reason: 'base species $id has non-positive height');
          expect(item['weight'] as double, greaterThan(0),
              reason: 'base species $id has non-positive weight');
        } else {
          expect(item['height'] as double, greaterThanOrEqualTo(0));
          expect(item['weight'] as double, greaterThanOrEqualTo(0));
        }

        // Abilities: non-empty comma-separated slugs
        expect(item['abilities'], isA<String>());
        expect((item['abilities'] as String).isNotEmpty, isTrue,
            reason: 'entry $id has no abilities');
      }
    });

    test('species categories look like real genera (contain "Pok\u00e9mon")', () {
      for (final item in seed.cast<Map>()) {
        final species = item['species'];
        if (species is String && species.isNotEmpty) {
          expect(species.endsWith('Pok\u00e9mon'), isTrue,
              reason: 'entry ${item['id']} category "$species" looks wrong');
        }
      }
    });

    test('every entry ships a non-empty flavorText (seed v9)', () {
      for (final item in seed.cast<Map>()) {
        final flavor = item['flavorText'];
        expect(flavor, isA<String>(),
            reason: 'entry ${item['id']} is missing flavorText');
        expect(flavor as String, isNotEmpty,
            reason: 'entry ${item['id']} has empty flavorText');
        expect(flavor.contains('\n') || flavor.contains('\f'), isFalse,
            reason: 'entry ${item['id']} flavorText has uncleaned line breaks');
      }
    });

    test('evolutionInfo entries are valid JSON arrays when present', () {
      for (final item in seed.cast<Map>()) {
        final info = item['evolutionInfo'];
        if (info is String && info.isNotEmpty) {
          Object? decoded;
          expect(() => decoded = jsonDecode(info), returnsNormally,
              reason: 'entry ${item['id']} evolutionInfo is not valid JSON');
          expect(decoded, isA<List>(),
              reason: 'entry ${item['id']} evolutionInfo must be a JSON array');
        }
      }
    });
  });
}
