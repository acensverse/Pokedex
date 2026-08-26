import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/tools/team_detail_screen.dart';

void main() {
  // Charizard (fire/flying) hand-computed matchups:
  //  electric 2x -> DI -1 | water 2x -> -1 | ice 0.5x*2x = 1x -> 0
  //  rock 2x*2x = 4x (the famous Stealth Rock weakness) -> -3
  //  ground 0x (flying immune) -> +1 | fighting 0.5x -> +0.5
  final charizard = [
    ['fire', 'flying'],
  ];

  // Blastoise (water): water resisted 0.5x -> +0.5, electric weak 2x -> -1,
  // rock neutral 1x -> 0.
  final blastoise = [
    ['water'],
  ];

  group('teamDefenseIndex', () {
    test('single member: known Charizard matchups', () {
      expect(teamDefenseIndex(charizard, 'electric'), -1.0);
      expect(teamDefenseIndex(charizard, 'water'), -1.0);
      expect(teamDefenseIndex(charizard, 'ice'), 0.0);
      expect(teamDefenseIndex(charizard, 'rock'), -3.0); // 4x weakness
      expect(teamDefenseIndex(charizard, 'ground'), 1.0);
      expect(teamDefenseIndex(charizard, 'fighting'), 0.5);
    });

    test('party average: Charizard + Blastoise', () {
      final party = [...charizard, ...blastoise];
      expect(teamDefenseIndex(party, 'electric'), -1.0); // both weak
      expect(teamDefenseIndex(party, 'water'), -0.25); // (-1 + 0.5) / 2
      expect(teamDefenseIndex(party, 'ground'), 0.5); // (+1 + 0) / 2
      expect(teamDefenseIndex(party, 'rock'), -1.5); // (-3 + 0) / 2
      expect(teamDefenseIndex(party, 'fire'), 0.5); // (0.5 + 0.5) / 2
    });

    test('immunities count as maximum resistance (+1)', () {
      // Ghost is immune to normal and fighting.
      expect(teamDefenseIndex([['ghost']], 'normal'), 1.0);
      expect(teamDefenseIndex([['ghost']], 'fighting'), 1.0);
    });

    test('4x weakness produces -3', () {
      // Water vs fire/rock: 2x * 2x = 4x -> 1 - 4 = -3.
      expect(teamDefenseIndex([['fire', 'rock']], 'water'), -3.0);
    });

    test('1/4x resist produces +0.75', () {
      // Electric vs grass/dragon: 0.5x * 0.5x = 0.25x -> 1 - 0.25 = +0.75.
      expect(teamDefenseIndex([['grass', 'dragon']], 'electric'), 0.75);
    });

    test('balanced party sums to exactly 0 (one 2x-weak + two 0.5x-resist)',
        () {
      // Fire attacker: grass member -1, each water member +0.5 -> sum 0.
      final party = [
        ['grass'],
        ['water'],
        ['water'],
      ];
      expect(teamDefenseIndex(party, 'fire'), 0.0);
    });

    test('empty party returns 0', () {
      expect(teamDefenseIndex([], 'fire'), 0.0);
    });
  });
}
