// Standalone verifier: compares TypeChart against an independently written
// reference chart (gen 6+). Run: dart run tool/verify_chart.dart
// ignore_for_file: avoid_print
import 'package:pokedex_flutter/core/utils/type_chart.dart';

// Reference: rows = DEFENDING type, values = multiplier for each ATTACKING type.
// Written independently from the official gen-6+ chart.
const reference = <String, Map<String, double>>{
  'normal': {
    'fighting': 2, 'ghost': 0,
  },
  'fire': {
    'fire': 0.5, 'water': 2, 'grass': 0.5, 'ice': 0.5, 'ground': 2,
    'bug': 0.5, 'rock': 2, 'steel': 0.5, 'fairy': 0.5,
  },
  'water': {
    'fire': 0.5, 'water': 0.5, 'electric': 2, 'grass': 2, 'ice': 0.5, 'steel': 0.5,
  },
  'electric': {
    'electric': 0.5, 'ground': 2, 'flying': 0.5, 'steel': 0.5,
  },
  'grass': {
    'fire': 2, 'water': 0.5, 'electric': 0.5, 'grass': 0.5, 'ice': 2,
    'poison': 2, 'ground': 0.5, 'flying': 2, 'bug': 2,
  },
  'ice': {
    'fire': 2, 'ice': 0.5, 'fighting': 2, 'rock': 2, 'steel': 2,
  },
  'fighting': {
    'flying': 2, 'psychic': 2, 'bug': 0.5, 'rock': 0.5, 'dark': 0.5, 'fairy': 2,
  },
  'poison': {
    'grass': 0.5, 'fighting': 0.5, 'poison': 0.5, 'ground': 2,
    'psychic': 2, 'bug': 0.5, 'fairy': 0.5,
  },
  'ground': {
    'water': 2, 'electric': 0, 'grass': 2, 'ice': 2, 'poison': 0.5, 'rock': 0.5,
  },
  'flying': {
    'electric': 2, 'grass': 0.5, 'ice': 2, 'fighting': 0.5,
    'ground': 0, 'bug': 0.5, 'rock': 2,
  },
  'psychic': {
    'fighting': 0.5, 'poison': 0.5, 'bug': 2, 'ghost': 2, 'dark': 2, 'psychic': 0.5,
  },
  'bug': {
    'fire': 2, 'grass': 0.5, 'fighting': 0.5, 'ground': 0.5,
    'flying': 2, 'rock': 2,
  },
  'rock': {
    'normal': 0.5, 'fire': 0.5, 'water': 2, 'grass': 2, 'fighting': 2,
    'poison': 0.5, 'ground': 2, 'flying': 0.5, 'steel': 2,
  },
  'ghost': {
    'normal': 0, 'fighting': 0, 'poison': 0.5, 'bug': 0.5, 'ghost': 2, 'dark': 2,
  },
  'dragon': {
    'fire': 0.5, 'water': 0.5, 'electric': 0.5, 'grass': 0.5,
    'ice': 2, 'dragon': 2, 'fairy': 2,
  },
  'dark': {
    'fighting': 2, 'psychic': 0, 'bug': 2, 'ghost': 0.5, 'dark': 0.5, 'fairy': 2,
  },
  'steel': {
    'normal': 0.5, 'fire': 2, 'grass': 0.5, 'ice': 0.5, 'fighting': 2,
    'poison': 0, 'ground': 2, 'flying': 0.5, 'psychic': 0.5, 'bug': 0.5,
    'rock': 0.5, 'dragon': 0.5, 'steel': 0.5, 'fairy': 0.5,
  },
  'fairy': {
    'fighting': 0.5, 'poison': 2, 'bug': 0.5, 'dragon': 0, 'dark': 0.5, 'steel': 2,
  },
};

void main() {
  var errors = 0;
  final allTypes = reference.keys.toList()..sort();

  for (final defender in allTypes) {
    for (final attacker in allTypes) {
      final expected = reference[defender]![attacker] ?? 1.0;
      final actual = TypeChart.getEffectiveness([defender])[attacker]!;
      if (expected != actual) {
        errors++;
        print('MISMATCH $attacker vs $defender: expected $expected, got $actual');
      }
    }
  }

  // Spot-check famous dual types.
  void check(String desc, double actual, double expected) {
    if (actual != expected) {
      errors++;
      print('DUAL MISMATCH $desc: expected $expected, got $actual');
    }
  }

  check('Water vs Fire/Rock (4x)', TypeChart.getEffectiveness(['fire', 'rock'])['water']!, 4.0);
  check('Electric vs Water/Ground (0x)', TypeChart.getEffectiveness(['water', 'ground'])['electric']!, 0.0);
  check('Ice vs Dragon/Flying (4x)', TypeChart.getEffectiveness(['dragon', 'flying'])['ice']!, 4.0);
  check('Rock vs Fire/Flying (4x)', TypeChart.getEffectiveness(['fire', 'flying'])['rock']!, 4.0);
  check('Grass vs Fire/Poison (Bulbasaur 2x... actually 1/4x?)', TypeChart.getEffectiveness(['grass', 'poison'])['grass']!, 0.25);

  print(errors == 0 ? 'ALL ${allTypes.length * allTypes.length} cells + dual checks PASS' : '$errors ERRORS FOUND');
}
