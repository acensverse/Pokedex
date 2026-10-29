import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// Regression guards for the moves seed's learn data: every champion roster
/// form must have learn coverage, and the v1.2.0 Z-megas must match the
/// species forms they inherited from (tool/build_champions_from_champout.js
/// enforces this at build time — these tests keep the baked asset honest).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<dynamic> moves;
  late Map<String, dynamic> champions;

  setUpAll(() async {
    moves =
        jsonDecode(await rootBundle.loadString('assets/moves_seed.json'))
            as List<dynamic>;
    champions =
        jsonDecode(await rootBundle.loadString('assets/champions_seed.json'))
            as Map<String, dynamic>;
  });

  int learnMoveCount(int id) => moves
      .cast<Map<String, dynamic>>()
      .where((m) => (m['learn'] as List<dynamic>? ?? []).contains(id))
      .length;
  int ldMoveCount(int id) => moves
      .cast<Map<String, dynamic>>()
      .where((m) => (m['ld'] as List<dynamic>? ?? [])
          .any((e) => e[0] == id))
      .length;

  group('moves_seed learn coverage', () {
    test('every champion roster form has learn data', () {
      final roster = (champions['pokemon'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final uncovered = roster
          .map((p) => p['id'] as int)
          .where((id) => learnMoveCount(id) == 0 || ldMoveCount(id) == 0)
          .toList();
      expect(uncovered, isEmpty,
          reason: 'roster forms without learn data show empty movesets '
              'on their detail screen');
    });

    test('v1.2.0 Z-megas match the species forms they inherited from', () {
      // The game datamine gives the Z-megas the same flat learnset as their
      // species; the builder inherits the level/method presentation from a
      // covered form with an identical game learnset.
      final expectedCounts = <int, int>{};
      for (final entry in const [
        [10307, 359], // Mega Absol Z <- Absol
        [10309, 445], // Mega Garchomp Z <- Garchomp
        [10310, 448], // Mega Lucario Z <- Lucario
        [10316, 768], // Mega Golisopod <- Golisopod
        [10325, 998], // Mega Baxcalibur <- Baxcalibur
      ]) {
        expectedCounts[entry[0]] = entry[1];
      }
      for (final entry in expectedCounts.entries) {
        expect(ldMoveCount(entry.key), ldMoveCount(entry.value),
            reason: 'form ${entry.key} must cover as many moves as '
                'species form ${entry.value}');
        expect(learnMoveCount(entry.key), learnMoveCount(entry.value),
            reason: 'form ${entry.key} must cover as many moves as '
                'species form ${entry.value}');
      }
    });

    test('unreleased moves (available: 0 in the datamine) stay out', () {
      // Nihil Light (#920) is a v1.2.0 datamine placeholder: no description,
      // no learners, available: 0. It must not leak into the app.
      expect(moves.cast<Map<String, dynamic>>().any((m) => m['id'] == 920),
          isFalse);
    });
  });
}
