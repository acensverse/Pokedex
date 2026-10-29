import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, compute;
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/poke_api.dart';
import '../database/app_database.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../models/pokemon.dart';

List<PokemonCacheData> _parsePokedexSeed(String jsonString) {
  final List<dynamic> jsonList = jsonDecode(jsonString);
  return [
    for (final item in jsonList)
      PokemonCacheData(
        id: item['id'] as int,
        speciesId: item['speciesId'] as int?,
        name: item['name'] as String,
        types: item['types'] as String,
        species: item['species'] as String?,
        generation: item['generation'] as int?,
        hp: item['hp'] as int?,
        attack: item['attack'] as int?,
        defense: item['defense'] as int?,
        spAttack: item['spAttack'] as int?,
        spDefense: item['spDefense'] as int?,
        speed: item['speed'] as int?,
        height: (item['height'] as num?)?.toDouble(),
        weight: (item['weight'] as num?)?.toDouble(),
        abilities: item['abilities'] as String?,
        forms: item['forms'] as String?,
        evolutionInfo: item['evolutionInfo'] as String?,
        flavorText: item['flavorText'] as String?,
        isFavorite: false,
      ),
  ];
}

class PokemonRepository {
  final PokeApi _api;
  final AppDatabase _db;
  final Dio _dio;

  /// Lazy-loaded map: pokemonId → set of ability names that are hidden for
  /// that Pokemon, built from assets/abilities_seed.json at first use.
  Map<int, Set<String>>? _hiddenAbilityMap;

  // The shared, timeout-configured Dio from dioClientProvider is always
  // injected; no ad-hoc Dio instances are created anywhere.
  PokemonRepository(this._api, this._db, this._dio);

  /// Bump this whenever seed logic or the asset changes so installs
  /// re-run the (cheap) integrity check once more.
  static const _seedDoneFlag = 'seed_v14_complete';
  static const _seedRevKey = 'seed_asset_rev';

  /// Bumped alongside [_seedDoneFlag] whenever baked asset CONTENT changes.
  /// Lets a healthy-looking database (rows pass the sniff test below) still
  /// be recognized as pre-rebake, forcing exactly one re-seed.
  static const _seedAssetRev =
      9; // 9 = champout ability corrections (5 megas) + Z-mega learnsets

  // Seed SQLite from local JSON asset once per install/seed-version
  Future<void> checkAndSeedDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    if ((prefs.getBool(_seedDoneFlag) ?? false) &&
        (prefs.getInt(_seedRevKey) ?? 0) >= _seedAssetRev) {
      return;
    }

    final cachedCount = await _db.searchPokemon('', '');

    bool needsUpdate = false;
    if (cachedCount.isNotEmpty) {
      final first = await _db.getPokemonById(1);
      // Stale seed = missing category/flavor text or mojibake rows from the
      // corrupted asset era (flavor text shipped starting with seed v9)
      if (first != null &&
          (first.species == null ||
              first.species!.isEmpty ||
              first.species!.contains('\uFFFD') ||
              first.flavorText == null ||
              first.flavorText!.isEmpty)) {
        needsUpdate = true;
      }
    }

    // Healthy database AND current asset revision -> nothing to do.
    if (!needsUpdate &&
        cachedCount.length >= 1329 &&
        (prefs.getInt(_seedRevKey) ?? 0) >= _seedAssetRev) {
      await prefs.setBool(_seedDoneFlag, true);
      return;
    }

    try {
      final jsonString = await rootBundle.loadString(
        'assets/pokedex_seed.json',
      );
      final parsed = await compute(_parsePokedexSeed, jsonString);

      // Batch insert in a single transaction instead of 1291 row-by-row awaits
      await _db.cacheAllPokemon(parsed);
      await prefs.setInt(_seedRevKey, _seedAssetRev);
      await prefs.setBool(_seedDoneFlag, true);
    } catch (e, st) {
      debugPrint('Seeding the local database failed: $e\n$st');
      // Surface the failure: PokedexNotifier catches this and flips hasError,
      // which the grid renders as an error view with a retry button.
      rethrow;
    }
  }

  /// Force re-seeding the SQLite database from local JSON assets.
  Future<void> forceReseedDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seedDoneFlag, false);
    await checkAndSeedDatabase();
  }

  // Get Pokemon list from local database (offline-first, no network dependency).
  // Search/type filtering happens client-side in filteredPokemonProvider.
  Future<List<Pokemon>> getLocalPokemonList() async {
    await _ensureHiddenAbilityMap();
    await checkAndSeedDatabase(); // Ensure seeded on list fetch

    final dbList = await _db.searchPokemon('', '');
    return dbList.map((dbData) => _mapDbToModel(dbData)).toList();
  }

  // Fetch detailed Pokemon. Cache-first: the seeded database already holds
  // every field the profile needs except moves, so this returns instantly
  // and never blocks the UI on a network round-trip.
  Future<Pokemon> getPokemonDetails(int id) async {
    await _ensureHiddenAbilityMap();
    final cached = await _db.getPokemonById(id);
    if (cached != null) {
      return _mapDbToModel(cached);
    }

    // Slow path: id unknown to SQLite (should not happen post-seed).
    debugPrint('Cache miss for pokemon $id; fetching from PokeAPI');
    final pokemon = await _api.fetchPokemonDetails(id.toString());

    // Cache the updated fields back into SQLite
    final typesString = pokemon.types.map((t) => t.type.name).join(',');
    // Cache abilities incl. real hidden flags as JSON: [{"n":name,"h":hidden}, ...]
    final abilitiesCache = jsonEncode(
      pokemon.abilities
          .map((a) => {'n': a.ability.name, 'h': a.isHidden})
          .toList(),
    );
    final hpVal = _statValue(pokemon.stats, 'hp');
    final attackVal = _statValue(pokemon.stats, 'attack');
    final defenseVal = _statValue(pokemon.stats, 'defense');
    final spAttackVal = _statValue(pokemon.stats, 'special-attack');
    final spDefenseVal = _statValue(pokemon.stats, 'special-defense');
    final speedVal = _statValue(pokemon.stats, 'speed');

    final dbData = PokemonCacheData(
      id: pokemon.id,
      speciesId: pokemon.speciesId,
      name: cached?.name ?? pokemon.name,
      types: typesString,
      species: cached?.species,
      generation: cached?.generation,
      hp: hpVal,
      attack: attackVal,
      defense: defenseVal,
      spAttack: spAttackVal,
      spDefense: spDefenseVal,
      speed: speedVal,
      // API returns decimetres/hectograms; store metres/kg to match the seed asset
      height: pokemon.height / 10.0,
      weight: pokemon.weight / 10.0,
      abilities: abilitiesCache,
      // Preserve seed/cached metadata instead of destroying it
      forms: cached?.forms,
      evolutionInfo: cached?.evolutionInfo,
      flavorText: cached?.flavorText,
      isFavorite: cached?.isFavorite ?? false,
      // No jsonData: the full API payload (100-400 KB per visit) is not stored;
      // the typed columns above are the single source of truth.
    );

    await _db.cachePokemon(dbData);

    return pokemon.copyWith(name: cached?.name ?? pokemon.name);
  }

  /// The move list (with version-group details) is the only profile data not
  /// Category + any previously cached flavor text read straight from SQLite.
  /// Resolves in milliseconds, letting the header paint instantly while
  /// getSpeciesInfo streams the (network-only) flavor text in the background.
  Future<({String? category, String? flavorText})> getCachedSpeciesInfo(
    int id,
  ) async {
    final cached = await _db.getPokemonById(id);
    return (
      category: _trustworthyCategory(cached?.species),
      flavorText: (cached?.flavorText?.isNotEmpty ?? false)
          ? cached!.flavorText
          : null,
    );
  }

  /// Returns the English category ("genus") and Pok\u00e9dex flavor text for a
  /// Pok\u00e9mon. A single species fetch populates both; results are cached.
  Future<({String category, String? flavorText})> getSpeciesInfo(int id) async {
    final cached = await _db.getPokemonById(id);
    final speciesId = cached?.speciesId ?? id;

    final cachedCategory = _trustworthyCategory(cached?.species);
    final cachedFlavor = (cached?.flavorText?.isNotEmpty ?? false)
        ? cached!.flavorText
        : null;

    if (cachedCategory != null && cachedFlavor != null) {
      return (category: cachedCategory, flavorText: cachedFlavor);
    }

    var category = cachedCategory ?? '';
    String? flavorText = cachedFlavor;

    try {
      final response = await _dio.get(
        'https://pokeapi.co/api/v2/pokemon-species/$speciesId',
      );
      final data = response.data;
      if (data is Map) {
        if (category.isEmpty && data['genera'] is List) {
          final enGenus = (data['genera'] as List).whereType<Map>().firstWhere(
            (g) => g['language']?['name'] == 'en',
            orElse: () => const {},
          );
          if (enGenus.isNotEmpty && enGenus['genus'] is String) {
            category = enGenus['genus'] as String;
          }
        }
        // Real genera all end in "Pok\u00e9mon", so the old !contains('Pok') check
        // never trusted the cache. Only placeholders/corruption are invalid now.
        // Pick the newest-game entry by explicit version ranking - the API
        // array order is not strictly chronological.
        if (flavorText == null && data['flavor_text_entries'] is List) {
          flavorText = PokemonHelpers.pickLatestFlavorText(
            data['flavor_text_entries'] as List,
          );
        }
      }
      if (cached != null && (category.isNotEmpty || flavorText != null)) {
        await _db.cachePokemon(
          cached.copyWith(
            species: category.isNotEmpty
                ? Value(category)
                : const Value.absent(),
            flavorText: flavorText != null
                ? Value(flavorText)
                : const Value.absent(),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('Failed to load species info for $speciesId: $e\n$st');
      // Network failure: fall back to whatever the cache had
    }

    return (
      category: category.isNotEmpty ? category : 'Unknown Pok\u00e9mon',
      flavorText: flavorText,
    );
  }

  /// A cached category is usable unless it is a placeholder or legacy mojibake
  String? _trustworthyCategory(String? species) {
    if (species == null || species.isEmpty) return null;
    if (species == 'Pok\u00e9mon' || species == 'Unknown Pok\u00e9mon') {
      return null;
    }
    if (species.contains('Bulbasaur Pok')) return null;
    if (species.contains('\uFFFD')) return null;
    return species;
  }

  /// Returns breeding information: egg groups, gender rate, and hatch counter.
  Future<({List<String> eggGroups, int genderRate, int hatchCounter})>
  getBreedingInfo(int speciesId) async {
    try {
      final response = await _dio.get(
        'https://pokeapi.co/api/v2/pokemon-species/$speciesId',
      );
      final data = response.data;
      if (data is Map) {
        final eggGroupsList = data['egg_groups'] as List?;
        final eggGroups =
            eggGroupsList
                ?.whereType<Map>()
                .map((e) => e['name'] as String)
                .toList() ??
            [];
        final genderRate = data['gender_rate'] as int? ?? -1;
        final hatchCounter = data['hatch_counter'] as int? ?? 0;
        return (
          eggGroups: eggGroups,
          genderRate: genderRate,
          hatchCounter: hatchCounter,
        );
      }
    } catch (e, st) {
      debugPrint('Failed to load breeding info for $speciesId: $e\n$st');
    }
    return (eggGroups: <String>[], genderRate: -1, hatchCounter: 0);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await _db.toggleFavorite(id, isFavorite);
  }

  // Safe stat lookup: returns 0 instead of throwing when a stat is missing/malformed
  int _statValue(List<PokemonStatSlot> stats, String name) {
    for (final s in stats) {
      if (s.stat.name == name) return s.baseStat;
    }
    return 0;
  }

  // Helper mapper mapping Drift database object to Model representation.
  // Built purely from the typed columns; the legacy jsonData blob (if still
  // present in old rows) is intentionally ignored so typed columns stay
  // the single source of truth.
  Pokemon _mapDbToModel(PokemonCacheData dbData) {
    final typesList = dbData.types
        .split(',')
        .map(
          (typeName) => PokemonTypeSlot(
            slot: 1,
            type: PokemonType(name: typeName, url: ''),
          ),
        )
        .toList();

    final statsList = [
      PokemonStatSlot(
        baseStat: dbData.hp ?? 0,
        effort: 0,
        stat: const PokemonStat(name: 'hp', url: ''),
      ),
      PokemonStatSlot(
        baseStat: dbData.attack ?? 0,
        effort: 0,
        stat: const PokemonStat(name: 'attack', url: ''),
      ),
      PokemonStatSlot(
        baseStat: dbData.defense ?? 0,
        effort: 0,
        stat: const PokemonStat(name: 'defense', url: ''),
      ),
      PokemonStatSlot(
        baseStat: dbData.spAttack ?? 0,
        effort: 0,
        stat: const PokemonStat(name: 'special-attack', url: ''),
      ),
      PokemonStatSlot(
        baseStat: dbData.spDefense ?? 0,
        effort: 0,
        stat: const PokemonStat(name: 'special-defense', url: ''),
      ),
      PokemonStatSlot(
        baseStat: dbData.speed ?? 0,
        effort: 0,
        stat: const PokemonStat(name: 'speed', url: ''),
      ),
    ];

    final abilitiesList = _parseAbilities(
      dbData.abilities,
      pokemonId: dbData.id,
    );

    return Pokemon(
      id: dbData.id,
      speciesId: dbData.speciesId ?? dbData.id,
      name: dbData.name,
      height: ((dbData.height ?? 0.0) * 10).toInt(),
      weight: ((dbData.weight ?? 0.0) * 10).toInt(),
      baseExperience: 0,
      types: typesList,
      stats: statsList,
      abilities: abilitiesList,
      moves: const [],
      forms: dbData.forms,
      evolutionInfo: dbData.evolutionInfo,
    );
  }

  /// Parses cached abilities. Current format is JSON [{"n":name,"h":hidden}, ...]
  /// with the real hidden flags; legacy rows hold plain comma-separated names.
  /// When [pokemonId] is provided, hidden flags are resolved from the baked
  /// abilities seed (so seed-only Pokemon show hidden abilities correctly).
  List<PokemonAbilitySlot> _parseAbilities(String? raw, {int? pokemonId}) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final slots = <PokemonAbilitySlot>[];
        for (var i = 0; i < decoded.length; i++) {
          final e = decoded[i];
          if (e is Map && e['n'] is String) {
            slots.add(
              PokemonAbilitySlot(
                slot: i + 1,
                isHidden: e['h'] == true,
                ability: PokemonAbilityInfo(name: e['n'] as String, url: ''),
              ),
            );
          }
        }
        if (slots.isNotEmpty) return slots;
      }
    } catch (_) {
      // Fall through to legacy comma-separated parsing
    }
    return raw
        .split(',')
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList()
        .asMap()
        .entries
        .map(
          (entry) => PokemonAbilitySlot(
            slot: entry.key + 1,
            isHidden: _isHiddenAbility(pokemonId, entry.value),
            ability: PokemonAbilityInfo(name: entry.value, url: ''),
          ),
        )
        .toList();
  }

  /// Checks whether [abilityName] is a hidden ability for [pokemonId]
  /// using the baked abilities seed.
  bool _isHiddenAbility(int? pokemonId, String abilityName) {
    if (pokemonId == null) return false;
    final map = _hiddenAbilityMap;
    if (map == null) return false;
    final hiddenNames = map[pokemonId];
    if (hiddenNames == null) return false;
    return hiddenNames.contains(abilityName);
  }

  /// Lazily loads abilities_seed.json and builds the hidden ability lookup.
  Future<void> _ensureHiddenAbilityMap() async {
    if (_hiddenAbilityMap != null) return;
    try {
      final raw = await rootBundle.loadString('assets/abilities_seed.json');
      final list = jsonDecode(raw) as List<dynamic>;
      final map = <int, Set<String>>{};
      for (final entry in list) {
        final name = entry['name'] as String;
        final hiddenIds = (entry['hidden'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList();
        for (final pid in hiddenIds) {
          map.putIfAbsent(pid, () => <String>{});
          map[pid]!.add(name);
        }
      }
      _hiddenAbilityMap = map;
    } catch (_) {
      _hiddenAbilityMap = {};
    }
  }
}
