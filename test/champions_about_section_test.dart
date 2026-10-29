import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/core/app_preferences.dart';
import 'package:pokedex_flutter/core/champions.dart';
import 'package:pokedex_flutter/core/providers.dart';
import 'package:pokedex_flutter/core/remote_data.dart';
import 'package:pokedex_flutter/data/api/dio_client.dart';
import 'package:pokedex_flutter/data/api/poke_api.dart';
import 'package:pokedex_flutter/data/database/app_database.dart';
import 'package:pokedex_flutter/data/repositories/pokemon_repository.dart';
import 'package:pokedex_flutter/features/pokemon_detail/pokemon_detail_screen.dart';
import 'package:pokedex_flutter/features/tools/abilities_screen.dart'
    as tools_abilities;
import 'package:pokedex_flutter/features/tools/moves_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PokemonRepository repo;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await AppPreferences.init();
    db = AppDatabase(executor: NativeDatabase.memory());
    repo = PokemonRepository(PokeApi(Dio()), db, DioClient().dio);
    await repo.checkAndSeedDatabase();
  });

  tearDownAll(() async {
    await db.close();
  });

  group('Champions abilities & moves in About section regression guards', () {
    test('every champion roster form in champions_seed has abilities defined', () async {
      final raw = await rootBundle.loadString(kChampionsAssetPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final pokemon = (json['pokemon'] as List<dynamic>).cast<Map<String, dynamic>>();

      for (final p in pokemon) {
        final abilities = p['abilities'];
        expect(abilities, isA<List<dynamic>>(),
            reason: '${p['name']} (#${p['id']}) must have abilities list in champions_seed');
        expect(abilities as List, isNotEmpty,
            reason: '${p['name']} (#${p['id']}) abilities list should not be empty');
      }
    });

    test('Mega Lucario Z (#10310) has aura-guard in champions seed and abilities seed', () async {
      final rawChamps = await rootBundle.loadString(kChampionsAssetPath);
      final champsJson = jsonDecode(rawChamps) as Map<String, dynamic>;
      final roster = (champsJson['pokemon'] as List<dynamic>).cast<Map<String, dynamic>>();
      final lucarioZ = roster.firstWhere((p) => p['id'] == 10310);
      expect(lucarioZ['abilities'], contains('aura-guard'));

      final rawAbs = await rootBundle.loadString(kAbilitiesAssetPath);
      final absList = (jsonDecode(rawAbs) as List<dynamic>).cast<Map<String, dynamic>>();
      final auraGuard = absList.firstWhere((a) => a['name'] == 'aura-guard', orElse: () => {});
      expect(auraGuard, isNotEmpty);
      expect(auraGuard['pokemon'], contains(10310));
    });

    test('pokemonDetailProvider applies champions abilities for champion forms', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          pokemonRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Mega Lucario Z (#10310)
      final pokemon = await container.read(pokemonDetailProvider(10310).future);
      expect(pokemon.id, equals(10310));
      expect(pokemon.abilities.map((a) => a.ability.name), contains('aura-guard'),
          reason: 'pokemonDetailProvider must serve aura-guard for Mega Lucario Z in About section');
    });

    test('tools abilitiesSeedProvider and movesSeedProvider load champion data', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          pokemonRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final abilities = await container.read(tools_abilities.abilitiesSeedProvider.future);
      final auraGuard = abilities.firstWhere((a) => a.name == 'aura-guard', orElse: () => throw 'Missing');
      expect(auraGuard.pokemon, contains(10310));

      final moves = await container.read(movesSeedProvider.future);
      final lucarioZMoves = moves.where((m) => m.learnDetails.any((ld) => ld[0] == 10310));
      expect(lucarioZMoves, isNotEmpty,
          reason: 'Mega Lucario Z must have moves in movesSeedProvider');
    });

    test('syncChampionsAbilities updates SQLite database cache', () async {
      await repo.syncChampionsAbilities([
        {
          'id': 10310,
          'abilities': ['aura-guard'],
        }
      ]);
      final cached = await db.getPokemonById(10310);
      expect(cached, isNotNull);
      expect(cached!.abilities, contains('aura-guard'));
    });
  });

  group('Default Pokédex preference settings tests', () {
    test('default pokedex mode is national by default', () async {
      SharedPreferences.setMockInitialValues({});
      await AppPreferences.init();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(defaultPokedexModeProvider), equals(DefaultPokedexMode.national));
      expect(container.read(championsModeProvider), isFalse);
    });

    test('setting default pokedex to champions updates provider and prefs', () async {
      SharedPreferences.setMockInitialValues({});
      await AppPreferences.init();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await DefaultPokedexHelper.setDefaultPokedex(
        container,
        DefaultPokedexMode.champions,
      );

      expect(container.read(defaultPokedexModeProvider), equals(DefaultPokedexMode.champions));
      expect(container.read(championsModeProvider), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(DefaultPokedexHelper.prefKey), equals('champions'));
    });

    test('initializes champions mode from saved prefs on launch', () async {
      SharedPreferences.setMockInitialValues({
        DefaultPokedexHelper.prefKey: 'champions',
      });
      await AppPreferences.init();
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify that on app launch, reading championsModeProvider FIRST immediately
      // reflects the saved preference without needing to touch defaultPokedexModeProvider or Settings.
      expect(container.read(championsModeProvider), isTrue);
      expect(container.read(defaultPokedexModeProvider), equals(DefaultPokedexMode.champions));
    });
  });
}
