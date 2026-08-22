import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import '../api/poke_api.dart';
import '../database/app_database.dart';
import '../../models/pokemon.dart';

class PokemonRepository {
  final PokeApi _api;
  final AppDatabase _db;
  final Dio _dio;

  // The shared, timeout-configured Dio from dioClientProvider is always
  // injected; no ad-hoc Dio instances are created anywhere.
  PokemonRepository(this._api, this._db, this._dio);

  // Seed SQLite from local JSON asset on first startup if empty
  Future<void> checkAndSeedDatabase() async {
    final cachedCount = await _db.searchPokemon('', '');
    
    bool needsUpdate = false;
    if (cachedCount.isNotEmpty) {
      final first = await _db.getPokemonById(1);
      // Stale seed = missing category or mojibake rows from the corrupted asset era
      if (first != null && (first.species == null || first.species!.isEmpty || first.species!.contains('\uFFFD'))) {
        needsUpdate = true;
      }
    }

    if (!needsUpdate && cachedCount.length >= 1025) return;

    try {
      final jsonString = await rootBundle.loadString('assets/pokedex_seed.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      // Batch insert in a single transaction instead of 1291 row-by-row awaits
      await _db.cacheAllPokemon([
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
            height: item['height'] as double?,
            weight: item['weight'] as double?,
            abilities: item['abilities'] as String?,
            forms: item['forms'] as String?,
            evolutionInfo: item['evolutionInfo'] as String?,
            isFavorite: false,
          ),
      ]);
    } catch (e, st) {
      debugPrint('Seeding the local database failed: $e\n$st');
      // Surface the failure: PokedexNotifier catches this and flips hasError,
      // which the grid renders as an error view with a retry button.
      rethrow;
    }
  }

  // Get Pokemon list from local database (offline-first, no network dependency).
  // Search/type filtering happens client-side in filteredPokemonProvider.
  Future<List<Pokemon>> getLocalPokemonList() async {
    await checkAndSeedDatabase(); // Ensure seeded on list fetch

    final dbList = await _db.searchPokemon('', '');
    return dbList.map((dbData) => _mapDbToModel(dbData)).toList();
  }

  // Fetch detailed Pokemon (checks DB first, downloads and caches if missing)
  Future<Pokemon> getPokemonDetails(int id) async {
    final cached = await _db.getPokemonById(id);
    
    // Always fetch from API directly to get the latest models with versionGroupDetails
    final pokemon = await _api.fetchPokemonDetails(id.toString());
    
    // Cache the updated fields back into SQLite
    final typesString = pokemon.types.map((t) => t.type.name).join(',');
    // Cache abilities incl. real hidden flags as JSON: [{"n":name,"h":hidden}, ...]
    final abilitiesCache = jsonEncode(
      pokemon.abilities.map((a) => {'n': a.ability.name, 'h': a.isHidden}).toList(),
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

  /// Returns the English category ("genus") and Pok\u00e9dex flavor text for a
  /// Pok\u00e9mon. A single species fetch populates both; results are cached.
  Future<({String category, String? flavorText})> getSpeciesInfo(int id) async {
    final cached = await _db.getPokemonById(id);
    final speciesId = cached?.speciesId ?? id;

    final cachedCategory = _trustworthyCategory(cached?.species);
    final cachedFlavor = (cached?.flavorText?.isNotEmpty ?? false) ? cached!.flavorText : null;

    if (cachedCategory != null && cachedFlavor != null) {
      return (category: cachedCategory, flavorText: cachedFlavor);
    }

    var category = cachedCategory ?? '';
    String? flavorText = cachedFlavor;

    try {
      final response = await _dio.get('https://pokeapi.co/api/v2/pokemon-species/$speciesId');
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
        if (flavorText == null && data['flavor_text_entries'] is List) {
          final entries = (data['flavor_text_entries'] as List)
              .whereType<Map>()
              .where((e) => e['language']?['name'] == 'en' && e['flavor_text'] is String)
              .toList();
          if (entries.isNotEmpty) {
            // The last English entry comes from the most recent game version
            flavorText = (entries.last['flavor_text'] as String)
                .replaceAll('\n', ' ')
                .replaceAll('\f', ' ')
                .trim();
          }
        }
      }
      if (cached != null && (category.isNotEmpty || flavorText != null)) {
        await _db.cachePokemon(cached.copyWith(
          species: category.isNotEmpty ? Value(category) : const Value.absent(),
          flavorText: flavorText != null ? Value(flavorText) : const Value.absent(),
        ));
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
    if (species == 'Pok\u00e9mon' || species == 'Unknown Pok\u00e9mon') return null;
    if (species.contains('Bulbasaur Pok')) return null;
    if (species.contains('\uFFFD')) return null;
    return species;
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
    final typesList = dbData.types.split(',').map((typeName) => PokemonTypeSlot(
      slot: 1,
      type: PokemonType(name: typeName, url: ''),
    )).toList();

    final statsList = [
      PokemonStatSlot(baseStat: dbData.hp ?? 0, effort: 0, stat: const PokemonStat(name: 'hp', url: '')),
      PokemonStatSlot(baseStat: dbData.attack ?? 0, effort: 0, stat: const PokemonStat(name: 'attack', url: '')),
      PokemonStatSlot(baseStat: dbData.defense ?? 0, effort: 0, stat: const PokemonStat(name: 'defense', url: '')),
      PokemonStatSlot(baseStat: dbData.spAttack ?? 0, effort: 0, stat: const PokemonStat(name: 'special-attack', url: '')),
      PokemonStatSlot(baseStat: dbData.spDefense ?? 0, effort: 0, stat: const PokemonStat(name: 'special-defense', url: '')),
      PokemonStatSlot(baseStat: dbData.speed ?? 0, effort: 0, stat: const PokemonStat(name: 'speed', url: '')),
    ];

    final abilitiesList = _parseAbilities(dbData.abilities);

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
  /// with the real hidden flags; legacy rows hold plain comma-separated names,
  /// which carry no hidden info (so none is fabricated).
  List<PokemonAbilitySlot> _parseAbilities(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final slots = <PokemonAbilitySlot>[];
        for (var i = 0; i < decoded.length; i++) {
          final e = decoded[i];
          if (e is Map && e['n'] is String) {
            slots.add(PokemonAbilitySlot(
              slot: i + 1,
              isHidden: e['h'] == true,
              ability: PokemonAbilityInfo(name: e['n'] as String, url: ''),
            ));
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
        .map((entry) => PokemonAbilitySlot(
              slot: entry.key + 1,
              isHidden: false,
              ability: PokemonAbilityInfo(name: entry.value, url: ''),
            ))
        .toList();
  }
}

