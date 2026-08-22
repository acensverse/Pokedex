import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex_flutter/data/api/dio_client.dart';
import 'package:pokedex_flutter/data/api/poke_api.dart';
import 'package:pokedex_flutter/data/database/app_database.dart';
import 'package:pokedex_flutter/data/repositories/pokemon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late PokemonRepository repo;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(executor: NativeDatabase.memory());
    repo = PokemonRepository(PokeApi(Dio()), db, DioClient().dio);
    // Seeds the real asset through the production batch path.
    await repo.getLocalPokemonList();
  });

  tearDownAll(() async {
    await db.close();
  });

  group('getLocalPokemonList (DB -> model mapping)', () {
    test('returns the full seeded dex ordered by species', () async {
      final list = await repo.getLocalPokemonList();
      expect(list.length, greaterThanOrEqualTo(1025));
      expect(list.first.name, 'Bulbasaur');
    });

    test('converts metres/kg from seed to decimetres/hectograms', () async {
      final list = await repo.getLocalPokemonList();
      final pikachu = list.firstWhere((p) => p.id == 25);
      // Seed stores 0.4 m / 6.0 kg; the model expects API units x10
      expect(pikachu.height, 4);
      expect(pikachu.weight, 60);
      expect(pikachu.types.map((t) => t.type.name), contains('electric'));
    });

    test('legacy comma ability strings carry no fabricated hidden flag', () async {
      final list = await repo.getLocalPokemonList();
      final pikachu = list.firstWhere((p) => p.id == 25);
      expect(pikachu.abilities, isNotEmpty);
      expect(pikachu.abilities.every((a) => !a.isHidden), isTrue,
          reason: 'seed rows cannot know hidden flags - none may be invented');
    });

    test('ignores stale jsonData blobs and trusts typed columns (E1)', () async {
      await db.cachePokemon(PokemonCacheData(
        id: 9999,
        speciesId: 9999,
        name: 'Testmon',
        types: 'fire,flying',
        hp: 70,
        attack: 80,
        defense: 90,
        spAttack: 60,
        spDefense: 65,
        speed: 100,
        height: 1.1,
        weight: 9.9,
        abilities: '[{"n":"flame-body","h":true},{"n":"drought","h":false}]',
        isFavorite: false,
        jsonData: '{"id":123,"name":"JUNK-DATA"}',
      ));

      final list = await repo.getLocalPokemonList();
      final testmon = list.firstWhere((p) => p.id == 9999);

      expect(testmon.name, 'Testmon', reason: 'jsonData must not override typed columns');
      expect(testmon.height, 11); // 1.1 m -> 11 dm
      expect(testmon.weight, 99); // 9.9 kg -> 99 hg
      expect(testmon.types.map((t) => t.type.name), ['fire', 'flying']);
      expect(testmon.abilities[0].ability.name, 'flame-body');
      expect(testmon.abilities[0].isHidden, isTrue);
      expect(testmon.abilities[1].isHidden, isFalse);
    });
  });

  group('cacheAllPokemon (seeding)', () {
    test('preserves user favorites when re-seeding (E2)', () async {
      await repo.toggleFavorite(25, true);
      expect((await db.getPokemonById(25))!.isFavorite, isTrue);

      // Simulate a full re-seed that writes isFavorite:false for everything
      final freshRows =
          (await db.searchPokemon('', '')).map((row) => row.copyWith(isFavorite: false)).toList();
      await db.cacheAllPokemon(freshRows);

      expect((await db.getPokemonById(25))!.isFavorite, isTrue,
          reason: 're-seeding must never wipe favorites');
    });
  });

  group('getPokemonDetails (cache-first)', () {
    // Any accidental network attempt dies instantly against this dead Dio.
    PokemonRepository offlineRepo() {
      final deadDio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:1',
        connectTimeout: const Duration(milliseconds: 250),
        receiveTimeout: const Duration(milliseconds: 250),
      ));
      return PokemonRepository(PokeApi(deadDio), db, deadDio);
    }

    test('serves seeded base species without touching the network', () async {
      final bulbasaur = await offlineRepo().getPokemonDetails(1);
      expect(bulbasaur.name, 'Bulbasaur');
      expect(bulbasaur.types.map((t) => t.type.name), containsAll(['grass', 'poison']));
      expect(bulbasaur.stats[0].baseStat, greaterThan(0));
      expect(bulbasaur.abilities, isNotEmpty);
    });

    test('serves seeded form ids (>10000) without touching the network', () async {
      final megaVenusaur = await offlineRepo().getPokemonDetails(10033);
      expect(megaVenusaur.types, isNotEmpty);
    });

    test('cached models intentionally carry no move slots', () async {
      final bulbasaur = await offlineRepo().getPokemonDetails(1);
      expect(bulbasaur.moves, isEmpty,
          reason: 'moves stream in via getPokemonMoves and must never block the page');
    });

    test('getCachedSpeciesInfo serves the seeded category offline', () async {
      final info = await offlineRepo().getCachedSpeciesInfo(1);
      expect(info.category, 'Seed Pok\u00e9mon');
      expect(info.flavorText, isNull,
          reason: 'seed ships no flavor text - it streams via getSpeciesInfo');
    });
  });
}
