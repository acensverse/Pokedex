import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pokedex_flutter/features/pokemon_detail/widgets/evolution_tab.dart';
import 'package:pokedex_flutter/models/pokemon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<dynamic> seed;

  setUpAll(() async {
    final raw = await rootBundle.loadString('assets/pokedex_seed.json');
    seed = jsonDecode(raw) as List<dynamic>;
  });

  EvoNode buildTreeFromRaw(List<Map<String, dynamic>> entries) {
    final nodes = <int, EvoNode>{
      for (final e in entries)
        e['id'] as int: EvoNode(
          pokemonId: e['id'] as int,
          condition: (e['condition'] ?? '') as String,
          evolvesTo: [],
        ),
    };

    EvoNode? root;
    for (final e in entries) {
      final node = nodes[e['id'] as int]!;
      final from = e['evolves_from'] as int?;
      if (from == null) {
        root ??= node;
      } else {
        nodes[from]?.evolvesTo.add(node);
      }
    }
    return root!;
  }

  EvoNode getTreeForId(int id) {
    final p = seed.firstWhere((x) => x['id'] == id) as Map;
    final raw = (jsonDecode(p['evolutionInfo'] as String) as List).cast<Map<String, dynamic>>();
    return buildTreeFromRaw(raw);
  }

  group('Evolution Layout Engine - Required Test Families', () {
    test('Bulbasaur (#1) resolves to Linear layout', () {
      final root = getTreeForId(1);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.linear));
      expect(root.evolvesTo.length, equals(1)); // Ivysaur
      expect(root.evolvesTo.first.evolvesTo.length, equals(1)); // Venusaur
    });

    test('Charmander (#4) resolves to Linear layout', () {
      final root = getTreeForId(4);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.linear));
    });

    test('Eevee (#133) resolves to Direct Multi-Branch layout (4x2 grid)', () {
      final root = getTreeForId(133);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.directMultiBranch));
      expect(root.evolvesTo.length, equals(8));
      for (final child in root.evolvesTo) {
        expect(child.evolvesTo.isEmpty, isTrue); // All 8 are leaf evolutions
      }
    });

    test('Wurmple (#265) resolves to Multi-Stage Branching layout', () {
      final root = getTreeForId(265);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.multiStageBranch));
      expect(root.evolvesTo.length, equals(2)); // Silcoon, Cascoon
      expect(root.evolvesTo[0].evolvesTo.length, equals(1)); // Beautifly
      expect(root.evolvesTo[1].evolvesTo.length, equals(1)); // Dustox
    });

    test('Ralts (#280) resolves to Intermediate Branch layout (Kirlia -> Gardevoir / Gallade)', () {
      final root = getTreeForId(280);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.intermediateBranch));
      final kirlia = root.evolvesTo.first;
      expect(kirlia.evolvesTo.length, equals(2)); // Gardevoir & Gallade
    });

    test('Tyrogue (#236) resolves to Direct Multi-Branch layout (3 branches)', () {
      final root = getTreeForId(236);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.directMultiBranch));
      expect(root.evolvesTo.length, equals(3)); // Hitmonlee, Hitmonchan, Hitmontop
    });

    test('Slowpoke (#79) resolves to Intermediate Branch layout (Slowbro / Slowking)', () {
      final root = getTreeForId(79);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.intermediateBranch));
      expect(root.evolvesTo.length, equals(2)); // Slowbro & Slowking
    });

    test('Applin (#840) resolves to Intermediate Branch layout with deep branch (Dipplin -> Hydrapple)', () {
      final root = getTreeForId(840);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.intermediateBranch));
      expect(root.evolvesTo.length, equals(3)); // Flapple, Appletun, Dipplin
      final dipplin = root.evolvesTo.firstWhere((c) => c.pokemonId == 1011);
      expect(dipplin.evolvesTo.first.pokemonId, equals(1019)); // Hydrapple
    });

    test('Oddish (#43) resolves to Intermediate Branch layout (Gloom -> Vileplume / Bellossom)', () {
      final root = getTreeForId(43);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.intermediateBranch));
      final gloom = root.evolvesTo.first;
      expect(gloom.evolvesTo.length, equals(2)); // Vileplume & Bellossom
    });

    test('Poltchageist (#1012) resolves to Linear layout with Teacup condition', () {
      final root = getTreeForId(1012);
      final strategy = EvolutionGraphAnalyzer.determineStrategy(root);
      expect(strategy, equals(EvolutionLayoutStrategy.linear));
      expect(root.evolvesTo.length, equals(1)); // Sinistcha
      expect(root.evolvesTo.first.condition, contains('teacup'));
    });
  });

  group('Evolution Condition Parsing & Formatting', () {
    test('parses level conditions cleanly with proper level up icon', () {
      final c1 = parseEvoCondition('Level 16');
      expect(c1.text, equals('Lv. 16'));
      expect(c1.icon, equals(LucideIcons.chevronsUp));

      final c2 = parseEvoCondition('Level 35 at Night');
      expect(c2.text, equals('Lv. 35'));
      expect(c2.icon, equals(LucideIcons.moon));

      final c3 = parseEvoCondition('Level 50 in Rain');
      expect(c3.text, equals('Lv. 50 (Rain)'));
      expect(c3.icon, equals(LucideIcons.cloudRain));
    });

    test('parses evolution stones and items with gem icon', () {
      final c1 = parseEvoCondition('Use Water stone');
      expect(c1.text, equals('Water Stone'));
      expect(c1.icon, equals(LucideIcons.gem));

      final c2 = parseEvoCondition('Use Thunder stone');
      expect(c2.text, equals('Thunder Stone'));
      expect(c2.icon, equals(LucideIcons.gem));

      final c3 = parseEvoCondition('Use Moon stone');
      expect(c3.text, equals('Moon Stone'));
      expect(c3.icon, equals(LucideIcons.gem));

      final c4 = parseEvoCondition('Use Shiny stone');
      expect(c4.text, equals('Shiny Stone'));
      expect(c4.icon, equals(LucideIcons.gem));

      final c5 = parseEvoCondition('Use Dusk stone');
      expect(c5.text, equals('Dusk Stone'));
      expect(c5.icon, equals(LucideIcons.gem));

      final c6 = parseEvoCondition('Use Dawn stone\nMale');
      expect(c6.text, equals('Dawn Stone'));
      expect(c6.genderIcon, equals(Icons.male));
      expect(c6.icon, equals(LucideIcons.gem));

      final c7 = parseEvoCondition('Use Tart apple');
      expect(c7.text, equals('Tart Apple'));
      expect(c7.icon, equals(LucideIcons.gem));

      final c8 = parseEvoCondition('Use Unremarkable teacup');
      expect(c8.text, equals('Teacup'));
      expect(c8.icon, equals(LucideIcons.gem));

      final c9 = parseEvoCondition('Use Leaf stone');
      expect(c9.text, equals('Leaf Stone'));
      expect(c9.icon, equals(LucideIcons.gem));

      final c10 = parseEvoCondition('Use Ice stone');
      expect(c10.text, equals('Ice Stone'));
      expect(c10.icon, equals(LucideIcons.gem));
    });

    test('parses trade conditions with arrowLeftRight icon', () {
      final c1 = parseEvoCondition('Trade');
      expect(c1.text, equals('Trade'));
      expect(c1.icon, equals(LucideIcons.arrowLeftRight));

      final c2 = parseEvoCondition('Trade\nholding Kings rock');
      expect(c2.text, equals("Trade + King's Rock"));
      expect(c2.icon, equals(LucideIcons.arrowLeftRight));
    });

    test('parses friendship and affection conditions with heart icon', () {
      final c1 = parseEvoCondition('Happiness\nDaytime');
      expect(c1.text, equals('Friendship'));
      expect(c1.icon, equals(LucideIcons.sun));

      final c2 = parseEvoCondition('Happiness\nNighttime');
      expect(c2.text, equals('Friendship'));
      expect(c2.icon, equals(LucideIcons.moon));

      final c3 = parseEvoCondition('Affection\nknowing a Fairy move');
      expect(c3.text, equals('Affection +\nFairy Move'));
      expect(c3.icon, equals(LucideIcons.heart));
    });
  });

  group('Active Path Highlighting Engine', () {
    test('findPathToRoot computes exact ancestral lineage for Gallade', () {
      final root = getTreeForId(280); // Ralts -> Kirlia -> Gallade
      final path = EvolutionGraphAnalyzer.findPathToRoot(root, 475); // Gallade
      expect(path, equals([280, 281, 475]));
    });

    test('findPathToRoot computes exact ancestral lineage for Dustox in Wurmple tree', () {
      final root = getTreeForId(265); // Wurmple -> Cascoon -> Dustox
      final path = EvolutionGraphAnalyzer.findPathToRoot(root, 269); // Dustox
      expect(path, equals([265, 268, 269]));
    });

    test('findPathToRoot computes exact ancestral lineage for Hydrapple in Applin tree', () {
      final root = getTreeForId(840); // Applin -> Dipplin -> Hydrapple
      final path = EvolutionGraphAnalyzer.findPathToRoot(root, 1019); // Hydrapple
      expect(path, equals([840, 1011, 1019]));
    });

    test('findPathToRoot computes direct lineage for Sylveon in Eevee tree', () {
      final root = getTreeForId(133);
      final path = EvolutionGraphAnalyzer.findPathToRoot(root, 700); // Sylveon
      expect(path, equals([133, 700]));
    });
  });

  group('EvolutionPokemonNode Widget Display', () {
    testWidgets('renders node cleanly without CURRENT badge and responds to tap', (tester) async {
      final testPokemon = Pokemon(
        id: 1,
        speciesId: 1,
        name: 'bulbasaur',
        height: 7,
        weight: 69,
        types: const [
          PokemonTypeSlot(slot: 1, type: PokemonType(name: 'grass', url: '')),
          PokemonTypeSlot(slot: 2, type: PokemonType(name: 'poison', url: '')),
        ],
        stats: const [],
        abilities: const [],
        moves: const [],
      );

      final evoNode = EvoNode(
        pokemonId: 1,
        condition: '',
        evolvesTo: [],
      )..pokemon = testPokemon;

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: EvolutionPokemonNode(
                node: evoNode,
                isSelected: true,
                isCurrent: true,
                isPathActive: true,
                width: 90.0,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('#001'), findsOneWidget);
      expect(find.text('Bulbasaur'), findsOneWidget);
      // Type names rendered right next to type icon
      expect(find.text('Grass'), findsOneWidget);
      expect(find.text('Poison'), findsOneWidget);
      // CURRENT tag removed as requested
      expect(find.text('CURRENT'), findsNothing);

      await tester.tap(find.byType(EvolutionPokemonNode));
      expect(tapped, isTrue);
    });
  });

  group('Linear Evolution Layout Orientation & Connectors', () {
    testWidgets('HorizontalEvolutionConnector renders Thunder Stone without clipping', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: HorizontalEvolutionConnector(
                condition: 'Use Thunder stone',
                isActive: true,
                width: 84.0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Thunder Stone'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VerticalEvolutionConnector renders without bottom overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VerticalEvolutionConnector(
                condition: 'Level 16',
                isActive: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Lv. 16'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Radial Evolution Constellation Layout Engine', () {
    Pokemon makeTestPokemon(int id, String name, String type1, [String? type2]) {
      return Pokemon(
        id: id,
        speciesId: id,
        name: name,
        height: 10,
        weight: 100,
        types: [
          PokemonTypeSlot(slot: 1, type: PokemonType(name: type1, url: '')),
          if (type2 != null)
            PokemonTypeSlot(slot: 2, type: PokemonType(name: type2, url: '')),
        ],
        stats: const [],
        abilities: const [],
        moves: const [],
      );
    }

    EvoNode buildEeveeFamily() {
      final root = EvoNode(
        pokemonId: 133,
        condition: '',
        evolvesTo: [
          EvoNode(pokemonId: 134, condition: 'Use Water stone', evolvesTo: [])
            ..pokemon = makeTestPokemon(134, 'vaporeon', 'water'),
          EvoNode(pokemonId: 135, condition: 'Use Thunder stone', evolvesTo: [])
            ..pokemon = makeTestPokemon(135, 'jolteon', 'electric'),
          EvoNode(pokemonId: 136, condition: 'Use Fire stone', evolvesTo: [])
            ..pokemon = makeTestPokemon(136, 'flareon', 'fire'),
          EvoNode(pokemonId: 196, condition: 'Happiness\nDaytime', evolvesTo: [])
            ..pokemon = makeTestPokemon(196, 'espeon', 'psychic'),
          EvoNode(pokemonId: 197, condition: 'Happiness\nNighttime', evolvesTo: [])
            ..pokemon = makeTestPokemon(197, 'umbreon', 'dark'),
          EvoNode(pokemonId: 470, condition: 'Use Leaf stone', evolvesTo: [])
            ..pokemon = makeTestPokemon(470, 'leafeon', 'grass'),
          EvoNode(pokemonId: 471, condition: 'Use Ice stone', evolvesTo: [])
            ..pokemon = makeTestPokemon(471, 'glaceon', 'ice'),
          EvoNode(pokemonId: 700, condition: 'Affection\nknowing a Fairy move', evolvesTo: [])
            ..pokemon = makeTestPokemon(700, 'sylveon', 'fairy'),
        ],
      )..pokemon = makeTestPokemon(133, 'eevee', 'normal');
      return root;
    }

    testWidgets('RadialEvolutionLayout renders Eevee base in center with BASE badge and 8 orbiting evolutions without overflow on 360px screen', (tester) async {
      final eeveeTree = buildEeveeFamily();
      int? selectedId = 133;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RadialEvolutionLayout(
                root: eeveeTree,
                selectedPokemonId: selectedId,
                currentPokemonId: 133,
                activePath: const [133],
                availableWidth: 328.0, // 360px screen minus 32px padding
                onSelect: (id) => selectedId = id,
              ),
            ),
          ),
        ),
      );

      // Verify Center Base Node
      expect(find.text('Eevee'), findsOneWidget);
      expect(find.text('BASE'), findsOneWidget);

      // Verify all 8 orbiting evolutions
      expect(find.text('Vaporeon'), findsOneWidget);
      expect(find.text('Jolteon'), findsOneWidget);
      expect(find.text('Flareon'), findsOneWidget);
      expect(find.text('Espeon'), findsOneWidget);
      expect(find.text('Umbreon'), findsOneWidget);
      expect(find.text('Leafeon'), findsOneWidget);
      expect(find.text('Glaceon'), findsOneWidget);
      expect(find.text('Sylveon'), findsOneWidget);

      // Verify full condition names are present
      expect(find.text('Water Stone'), findsOneWidget);
      expect(find.text('Thunder Stone'), findsOneWidget);
      expect(find.text('Fire Stone'), findsOneWidget);
      expect(find.text('Leaf Stone'), findsOneWidget);
      expect(find.text('Ice Stone'), findsOneWidget);
      expect(find.text('Friendship'), findsNWidgets(2)); // Espeon and Umbreon

      // Verify constellation painter is present
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify pairwise that NO two cards overlap anywhere
      final nodeFinders = find.byType(EvolutionPokemonNode);
      expect(nodeFinders, findsNWidgets(9)); // 1 center + 8 evolutions

      final rects = <Rect>[];
      for (int i = 0; i < 9; i++) {
        rects.add(tester.getRect(nodeFinders.at(i)));
      }

      for (int i = 0; i < rects.length; i++) {
        for (int j = i + 1; j < rects.length; j++) {
          final overlap = rects[i].overlaps(rects[j]);
          expect(overlap, isFalse, reason: 'Card $i at ${rects[i]} overlaps with Card $j at ${rects[j]}');
        }
      }

      // Ensure no exceptions or overflows
      expect(tester.takeException(), isNull);
    });

    testWidgets('RadialEvolutionLayout supports tap-to-select and tap-to-hold (long-press) interaction', (tester) async {
      final eeveeTree = buildEeveeFamily();
      int? selectedId;
      int? longPressedId;
      String? longPressedName;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RadialEvolutionLayout(
                root: eeveeTree,
                selectedPokemonId: 133,
                currentPokemonId: 133,
                activePath: const [133],
                availableWidth: 360.0,
                onSelect: (id) => selectedId = id,
                onLongPress: (id, name) {
                  longPressedId = id;
                  longPressedName = name;
                },
              ),
            ),
          ),
        ),
      );

      // Tap on Jolteon to select
      await tester.tap(find.text('Jolteon'));
      await tester.pump();
      expect(selectedId, equals(135));

      // Tap & Hold (long press) on Sylveon to view
      await tester.longPress(find.text('Sylveon'));
      await tester.pump();
      expect(longPressedId, equals(700));
      expect(longPressedName, equals('sylveon'));
    });

    testWidgets('RadialEvolutionLayout renders cleanly across 360, 375, 390, and 412 px widths without overflow', (tester) async {
      final eeveeTree = buildEeveeFamily();
      const testWidths = [328.0, 343.0, 358.0, 380.0];

      for (final width in testWidths) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: RadialEvolutionLayout(
                  root: eeveeTree,
                  selectedPokemonId: 133,
                  currentPokemonId: 133,
                  activePath: const [133],
                  availableWidth: width,
                  onSelect: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('RadialEvolutionLayout renders Tyrogue 3-branch constellation with Hitmonlee, Hitmonchan, and Hitmontop', (tester) async {
      final tyrogueTree = EvoNode(
        pokemonId: 236,
        condition: '',
        evolvesTo: [
          EvoNode(pokemonId: 106, condition: 'Level 20\nAttack > Defense', evolvesTo: [])
            ..pokemon = makeTestPokemon(106, 'hitmonlee', 'fighting'),
          EvoNode(pokemonId: 107, condition: 'Level 20\nDefense > Attack', evolvesTo: [])
            ..pokemon = makeTestPokemon(107, 'hitmonchan', 'fighting'),
          EvoNode(pokemonId: 237, condition: 'Level 20\nAttack = Defense', evolvesTo: [])
            ..pokemon = makeTestPokemon(237, 'hitmontop', 'fighting'),
        ],
      )..pokemon = makeTestPokemon(236, 'tyrogue', 'fighting');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RadialEvolutionLayout(
                root: tyrogueTree,
                selectedPokemonId: 236,
                currentPokemonId: 236,
                activePath: const [236],
                availableWidth: 328.0,
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tyrogue'), findsOneWidget);
      expect(find.text('Hitmonlee'), findsOneWidget);
      expect(find.text('Hitmonchan'), findsOneWidget);
      expect(find.text('Hitmontop'), findsOneWidget);
      expect(find.text('BASE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Evolution navigation info (i) button opens bottom sheet with instructions', (tester) async {
      final eeveeTree = buildEeveeFamily();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            evolutionChainProvider.overrideWith((ref, param) async => eeveeTree),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EvolutionTab(
                pokemonId: 133,
                speciesId: 133,
                evolutionInfoJson: '[]',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The previous static gesture pill is removed
      expect(find.text('Tap to select  •  Hold to view Pokémon'), findsNothing);

      // The (i) button is present
      final infoButtonFinder = find.byIcon(LucideIcons.info);
      expect(infoButtonFinder, findsOneWidget);

      // Tap on the (i) button
      await tester.tap(infoButtonFinder);
      await tester.pumpAndSettle();

      // Navigation sheet is shown
      expect(find.text('Evolution Navigation'), findsOneWidget);
      expect(find.text('Tap to Select'), findsOneWidget);
      expect(find.text('Hold to View Pokémon'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);

      // Tap Got it to dismiss
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();

      expect(find.text('Evolution Navigation'), findsNothing);
    });
  });
}
