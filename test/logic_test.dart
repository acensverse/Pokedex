import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/utils/pokemon_helpers.dart';
import 'package:pokedex_flutter/core/utils/type_chart.dart';
import 'package:pokedex_flutter/features/pokemon_detail/pokemon_detail_screen.dart';

void main() {
  group('TypeChart.getEffectiveness', () {
    test('returns an entry for all 18 types', () {
      final result = TypeChart.getEffectiveness(['grass']);
      expect(result.keys.length, 18);
    });

    test('single defender: grass weaknesses and resistances', () {
      final result = TypeChart.getEffectiveness(['grass']);
      expect(result['fire'], 2.0);
      expect(result['ice'], 2.0);
      expect(result['bug'], 2.0);
      expect(result['poison'], 2.0);
      expect(result['flying'], 2.0);
      expect(result['water'], 0.5);
      expect(result['ground'], 0.5);
      expect(result['electric'], 0.5);
      // Untouched types default to neutral
      expect(result['normal'], 1.0);
      expect(result['fairy'], 1.0);
    });

    test('dual defender: multipliers stack (Bulbasaur = grass/poison)', () {
      final result = TypeChart.getEffectiveness(['grass', 'poison']);
      // bug: 2.0 (vs grass) * 0.5 (vs poison) = neutral
      expect(result['bug'], 1.0);
      // ground: 0.5 * 2.0 = neutral
      expect(result['ground'], 1.0);
      // psychic: only poison contributes
      expect(result['psychic'], 2.0);
      // fire: only grass contributes
      expect(result['fire'], 2.0);
    });

    test('immunities are represented as 0.0', () {
      expect(TypeChart.getEffectiveness(['normal'])['ghost'], 0.0);
      expect(TypeChart.getEffectiveness(['ground'])['electric'], 0.0);
    });

    test('unknown type names are ignored without throwing', () {
      final result = TypeChart.getEffectiveness(['not-a-type']);
      expect(result.values.every((v) => v == 1.0), isTrue);
    });
  });

  group('PokemonHelpers.formatName', () {
    test('capitalizes plain names', () {
      expect(PokemonHelpers.formatName('bulbasaur'), 'Bulbasaur');
      expect(PokemonHelpers.formatName('', ), '');
    });

    test('handles hardcoded edge cases', () {
      expect(PokemonHelpers.formatName('mr-mime'), 'Mr. Mime');
      expect(PokemonHelpers.formatName('mime-jr'), 'Mime Jr.');
      expect(PokemonHelpers.formatName('nidoran-f'), 'Nidoran \u2640');
      expect(PokemonHelpers.formatName('nidoran-m'), 'Nidoran \u2642');
      expect(PokemonHelpers.formatName('type-null'), 'Type: Null');
      expect(PokemonHelpers.formatName('ho-oh'), 'Ho-Oh');
      expect(PokemonHelpers.formatName('porygon-z'), 'Porygon-Z');
      expect(PokemonHelpers.formatName('tapu-koko'), 'Tapu Koko');
    });

    test('expands form suffixes', () {
      expect(PokemonHelpers.formatName('venusaur-mega'), 'Mega Venusaur');
      expect(PokemonHelpers.formatName('charizard-mega-x'), 'Mega Charizard X');
      expect(PokemonHelpers.formatName('charizard-mega-y'), 'Mega Charizard Y');
      expect(PokemonHelpers.formatName('charizard-gmax'), 'Gigantamax Charizard');
      expect(PokemonHelpers.formatName('exeggutor-alola'), 'Alolan Exeggutor');
      expect(PokemonHelpers.formatName('growlithe-hisui'), 'Hisuian Growlithe');
      expect(PokemonHelpers.formatName('kyogre-primal'), 'Primal Kyogre');
    });
  });

  group('extractIdFromUrl', () {
    test('extracts trailing numeric segment', () {
      expect(extractIdFromUrl('https://pokeapi.co/api/v2/move/1'), 1);
      expect(extractIdFromUrl('/api/v2/move/123/'), 123);
    });

    test('returns null for malformed URLs instead of throwing', () {
      expect(extractIdFromUrl('https://pokeapi.co/api/v2/move/not-a-number'), isNull);
      expect(extractIdFromUrl(''), isNull);
      expect(extractIdFromUrl('::::not-a-uri'), isNull);
    });
  });
}
