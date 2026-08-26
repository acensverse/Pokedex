import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/features/pokedex/widgets/pokemon_card.dart';
import 'package:pokedex_flutter/features/tools/comparator_screen.dart';
import 'package:pokedex_flutter/core/providers.dart';
import 'package:pokedex_flutter/models/pokemon.dart';

Pokemon _makePokemon(int id, String name, List<String> types) {
  return Pokemon(
    id: id,
    speciesId: id,
    name: name,
    height: 4,
    weight: 60,
    types: [
      for (var i = 0; i < types.length; i++)
        PokemonTypeSlot(
          slot: i + 1,
          type: PokemonType(name: types[i], url: ''),
        ),
    ],
    stats: [
      PokemonStatSlot(baseStat: 55, effort: 0, stat: const PokemonStat(name: 'hp', url: '')),
      PokemonStatSlot(baseStat: 40, effort: 0, stat: const PokemonStat(name: 'attack', url: '')),
      PokemonStatSlot(baseStat: 50, effort: 0, stat: const PokemonStat(name: 'defense', url: '')),
      PokemonStatSlot(baseStat: 50, effort: 0, stat: const PokemonStat(name: 'special-attack', url: '')),
      PokemonStatSlot(baseStat: 50, effort: 0, stat: const PokemonStat(name: 'special-defense', url: '')),
      PokemonStatSlot(baseStat: 90, effort: 0, stat: const PokemonStat(name: 'speed', url: '')),
    ],
    abilities: const [],
    moves: const [],
  );
}

void main() {
  testWidgets('Comparator shows comparison after picking two Pokemon', (tester) async {
    final dex = [
      _makePokemon(25, 'pikachu', ['electric']),
      _makePokemon(6, 'charizard', ['fire', 'flying']),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localPokemonListProvider.overrideWith((ref) async => dex),
        ],
        child: const MaterialApp(home: ComparatorScreen()),
      ),
    );
    await tester.pump();

    // Pick slot 1.
    await tester.tap(find.text('TAP TO SELECT').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PokemonCard).first);
    await tester.pumpAndSettle();

    // Pick slot 2.
    await tester.tap(find.text('TAP TO SELECT'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PokemonCard).first);
    await tester.pumpAndSettle();

    // The comparison sections must be visible.
    expect(find.text('Species'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Type Effectiveness'), findsOneWidget);
  });
}
