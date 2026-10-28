import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/utils/name_forms.dart';
import 'package:pokedex_flutter/core/utils/pokemon_helpers.dart';
import 'package:pokedex_flutter/core/utils/type_chart.dart';
import 'package:pokedex_flutter/features/pokemon_detail/pokemon_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // The name/cry rules load from assets; tests resolve against real data.
    await NameForms.load();
  });

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

    test('handles punctuation edge cases', () {
      expect(PokemonHelpers.formatName('mr-mime'), 'Mr. Mime');
      expect(PokemonHelpers.formatName('mr. mime'), 'Mr. Mime');
      expect(PokemonHelpers.formatName('mime-jr'), 'Mime Jr.');
      expect(PokemonHelpers.formatName('nidoran-f'), 'Nidoran F');
      expect(PokemonHelpers.formatName('nidoran-m'), 'Nidoran M');
      expect(PokemonHelpers.formatName('type-null'), 'Type: Null');
      expect(PokemonHelpers.formatName('type: null'), 'Type: Null');
      expect(PokemonHelpers.formatName('ho-oh'), 'Ho-Oh');
      expect(PokemonHelpers.formatName('porygon-z'), 'Porygon-Z');
      expect(PokemonHelpers.formatName('tapu-koko'), 'Tapu Koko');
      expect(PokemonHelpers.formatName('farfetchd'), "Farfetch'd");
      expect(PokemonHelpers.formatName('kommo-o'), 'Kommo-o');
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

    test('resolves forms the old hardcode missed', () {
      expect(PokemonHelpers.formatName('lycanroc-midnight'), 'Midnight Lycanroc');
      expect(PokemonHelpers.formatName('indeedee-m'), 'Male Indeedee');
      expect(PokemonHelpers.formatName('indeedee-f'), 'Female Indeedee');
      expect(PokemonHelpers.formatName('calyrex-ice'), 'Ice Rider Calyrex');
      expect(PokemonHelpers.formatName('pikachu-rock-star'), 'Pikachu Rock Star');
      expect(PokemonHelpers.formatName('mr-mime-galar'), 'Galarian Mr. Mime');
      expect(PokemonHelpers.formatName('deoxys-attack'), 'Attack Deoxys');
      expect(PokemonHelpers.formatName('maushold-family-of-three'),
          'Family Of Three Maushold');
    });

    test('passes display-style names through unchanged', () {
      expect(PokemonHelpers.formatName('Mega Delphox'), 'Mega Delphox');
      expect(PokemonHelpers.formatName('Ice Rider Calyrex'), 'Ice Rider Calyrex');
    });
  });

  group('NameForms.toCryId', () {
    test('megas use the verified {base}-mega files', () {
      expect(NameForms.toCryId('Mega Delphox'), 'delphox-mega');
      expect(NameForms.toCryId('Mega Venusaur'), 'venusaur-mega');
      expect(NameForms.toCryId('Mega Magearna'), 'magearna-mega');
    });

    test('lettered megas join without a hyphen', () {
      expect(NameForms.toCryId('Mega Charizard X'), 'charizard-megax');
      expect(NameForms.toCryId('Mega Mewtwo Y'), 'mewtwo-megay');
      expect(NameForms.toCryId('Mega Garchomp Z'), 'garchomp-megaz');
      expect(NameForms.toCryId('charizard-mega-x'), 'charizard-megax');
    });

    test('compound megas resolve to the base mega cry', () {
      expect(NameForms.toCryId('Mega Meowstic Male'), 'meowstic-mega');
      expect(NameForms.toCryId('Mega Tatsugiri Droopy'), 'tatsugiri-mega');
      expect(NameForms.toCryId('Mega Magearna Original'), 'magearna-mega');
    });

    test('forms without cry files drop to the base cry', () {
      expect(NameForms.toCryId('Gigantamax Venusaur'), 'venusaur');
      expect(NameForms.toCryId('Alolan Rattata'), 'rattata');
      expect(NameForms.toCryId('Attack Deoxys'), 'deoxys');
      expect(NameForms.toCryId('Heat Rotom'), 'rotom');
      expect(NameForms.toCryId('Average Gourgeist'), 'gourgeist');
      expect(NameForms.toCryId('Mega Zygarde'), 'zygarde');
    });

    test('verified form files are used exactly', () {
      expect(NameForms.toCryId('Midnight Lycanroc'), 'lycanroc-midnight');
      expect(NameForms.toCryId('Dusk Lycanroc'), 'lycanroc-dusk');
      expect(NameForms.toCryId('Galarian Slowpoke'), 'slowpoke-galar');
      expect(NameForms.toCryId('Super Gourgeist'), 'gourgeist-super');
      expect(NameForms.toCryId('Female Indeedee'), 'indeedee-f');
      expect(NameForms.toCryId('Male Indeedee'), 'indeedee');
      expect(NameForms.toCryId('Ice Rider Calyrex'), 'calyrex-ice');
      expect(NameForms.toCryId('Noice Eiscue'), 'eiscue-noice');
      expect(NameForms.toCryId('Roaming Gimmighoul'), 'gimmighoul-roaming');
      expect(NameForms.toCryId('Starter Eevee'), 'eevee-starter');
      expect(NameForms.toCryId('10 Zygarde'), 'zygarde-10');
      expect(NameForms.toCryId('Complete Zygarde'), 'zygarde-complete');
    });

    test('pikachu cosmetics play the base cry (except Starter)', () {
      expect(NameForms.toCryId('Pikachu Rock Star'), 'pikachu');
      expect(NameForms.toCryId('Pikachu Original Cap'), 'pikachu');
      expect(NameForms.toCryId('Pikachu Starter'), 'pikachu-starter');
    });

    test('punctuation names sanitize to concatenated cry ids', () {
      expect(NameForms.toCryId('Mr. Mime'), 'mrmime');
      expect(NameForms.toCryId('Kommo-o'), 'kommoo');
      expect(NameForms.toCryId('Ho-Oh'), 'hooh');
      expect(NameForms.toCryId("Farfetch'd"), 'farfetchd');
      expect(NameForms.toCryId('Flabébé'), 'flabebe');
    });

    test('slug inputs resolve like display names', () {
      expect(NameForms.toCryId('slowpoke-galar'), 'slowpoke-galar');
      expect(NameForms.toCryId('lycanroc-dusk'), 'lycanroc-dusk');
      expect(NameForms.toCryId('toxtricity-amped-gmax'), 'toxtricity');
      expect(NameForms.toCryId('zygarde-10-power-construct'), 'zygarde-10');
      expect(NameForms.toCryId('urshifu-single-strike-gmax'), 'urshifu');
    });

    test('lastResortCryId mirrors the legacy retry behavior', () {
      expect(NameForms.lastResortCryId('Mega Delphox'), 'delphox');
      expect(NameForms.lastResortCryId('Mr. Mime'), 'mime');
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

  group('PokemonHelpers.pickLatestFlavorText', () {
    Map<String, dynamic> entry(String version, String text) => {
          'flavor_text': text,
          'language': {'name': 'en'},
          'version': {'name': version},
        };

    test('prefers the newest game even when array order is scrambled', () {
      // Mirrors the real Charizard response: a Black entry sits FIRST.
      final picked = PokemonHelpers.pickLatestFlavorText([
        entry('black', 'old black-era text'),
        entry('red', 'oldest text'),
        entry('sword', 'swsh text'),
        entry('lets-go-pikachu', 'lets-go text'),
      ]);
      expect(picked, 'swsh text');
    });

    test('falls back to the newest game that features the species', () {
      final picked = PokemonHelpers.pickLatestFlavorText([
        entry('yellow', 'yellow text'),
        entry('lets-go-eevee', 'lets-go text'),
      ]);
      expect(picked, 'lets-go text');
    });

    test('generation ties resolve to the later array entry (Violet > Scarlet)', () {
      final picked = PokemonHelpers.pickLatestFlavorText([
        entry('scarlet', 'scarlet text'),
        entry('violet', 'violet text'),
      ]);
      expect(picked, 'violet text');
    });

    test('cleans soft hyphens, line breaks and collapsed whitespace', () {
      final picked = PokemonHelpers.pickLatestFlavorText([
        entry('shield', 'If CHARIZard be\u00ADcomes furious,\n\nthe flame  wavers.'),
      ]);
      expect(picked, 'If CHARIZard becomes furious, the flame wavers.');
    });

    test('ignores non-English and malformed entries entirely', () {
      final picked = PokemonHelpers.pickLatestFlavorText([
        {
          'flavor_text': 'texte fran\u00e7ais',
          'language': {'name': 'fr'},
          'version': {'name': 'sword'},
        },
        {'nope': true},
      ]);
      expect(picked, isNull);
    });
  });
}
