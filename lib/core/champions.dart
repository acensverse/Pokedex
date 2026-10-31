import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'app_preferences.dart';
import 'remote_data.dart';
import 'utils/name_forms.dart';

/// Normalizes an item name for Champions-legality comparison: lowercase,
/// accents folded, every non-alphanumeric character removed, so "King's Rock"
/// becomes "kingsrock". Mirrors the normalization used by
/// tool/build_champions_seed.js.
String normalizeItemName(String raw) => NameForms.normalizeKey(raw);

/// The Champions Pokédex roster: which Pokémon and held items are legal in
/// Pokémon Champions. Baked into assets/champions_seed.json by
/// tool/build_champions_seed.js from champsmeta.com data.
class ChampionsData {
  /// Seed row ids of every champion Pokémon (forms included, e.g. Mega
  /// Venusaur's own row id). Matches [Pokemon.id] and the ids baked into the
  /// abilities seed's `pokemon` lists.
  final Set<int> pokemonIds;

  /// Species (dex) ids of every champion Pokémon. Matches the base-form-only
  /// ids baked into the moves seed's `learn` lists.
  final Set<int> speciesIds;

  /// Normalized names of every legal held item.
  final Set<String> itemSlugs;

  /// Form-specific ability overrides for champion forms (e.g. Mega Lucario Z
  /// -> ["aura-guard"]).
  final Map<int, List<String>> pokemonAbilities;

  /// Move legality in Champions: pokemonId -> set of moveIds
  final Map<int, Set<int>> pokemonMoves;

  /// Inverted move legality: moveId -> set of pokemonIds that learn it in Champions
  final Map<int, Set<int>> moveLearners;

  const ChampionsData({
    required this.pokemonIds,
    required this.speciesIds,
    required this.itemSlugs,
    this.pokemonAbilities = const {},
    this.pokemonMoves = const {},
    this.moveLearners = const {},
  });

  /// Set of champion pokemonIds that learn this move in Champions.
  Set<int> learnersForMove(int moveId) =>
      moveLearners[moveId] ?? const <int>{};

  /// Whether this move is legal on any Pokémon in Champions.
  bool isMoveLegal(int moveId) =>
      (moveLearners[moveId]?.isNotEmpty ?? false);
}

/// Loads the Champions roster asset — the downloaded override when one is
/// installed (see remote_data.dart), else the baked asset.
final championsDataProvider = FutureProvider<ChampionsData>((ref) async {
  // Re-evaluates when overrides are installed or reverted.
  ref.watch(remoteDataVersionProvider);
  final raw = await ref
          .read(remoteDataStoreProvider)
          .read(kRemoteChampionsFile) ??
      await rootBundle.loadString(kChampionsAssetPath);
  final data = jsonDecode(raw) as Map<String, dynamic>;
  final pokemon =
      (data['pokemon'] as List<dynamic>).cast<Map<String, dynamic>>();
  final abilitiesMap = <int, List<String>>{};
  final pokemonMovesMap = <int, Set<int>>{};
  final moveLearnersMap = <int, Set<int>>{};
  for (final p in pokemon) {
    final pid = p['id'] as int;
    final abs = p['abilities'];
    if (abs is List) {
      abilitiesMap[pid] = abs.map((e) => e.toString()).toList();
    }
    final mvs = p['moves'];
    if (mvs is List) {
      final moveSet = mvs.map((e) => (e as num).toInt()).toSet();
      pokemonMovesMap[pid] = moveSet;
      for (final mid in moveSet) {
        (moveLearnersMap[mid] ??= <int>{}).add(pid);
      }
    }
  }
  return ChampionsData(
    pokemonIds: {for (final p in pokemon) p['id'] as int},
    speciesIds: {for (final p in pokemon) p['dex'] as int},
    itemSlugs: {
      for (final name in (data['items'] as List<dynamic>).cast<String>())
        normalizeItemName(name),
    },
    pokemonAbilities: abilitiesMap,
    pokemonMoves: pokemonMovesMap,
    moveLearners: moveLearnersMap,
  );
});

const String _defaultPokedexPrefKey = 'user_default_pokedex_preference';

enum DefaultPokedexMode { national, champions }

final defaultPokedexModeProvider = StateProvider<DefaultPokedexMode>((ref) {
  final prefs = AppPreferences.instance;
  if (prefs != null) {
    final saved = prefs.getString(_defaultPokedexPrefKey);
    if (saved == 'champions') {
      return DefaultPokedexMode.champions;
    }
  }
  return DefaultPokedexMode.national;
});

class DefaultPokedexHelper {
  static const String prefKey = _defaultPokedexPrefKey;

  static Future<void> setDefaultPokedex(
    dynamic ref,
    DefaultPokedexMode mode,
  ) async {
    ref.read(defaultPokedexModeProvider.notifier).state = mode;
    ref.read(championsModeProvider.notifier).state =
        mode == DefaultPokedexMode.champions;
    final prefs = await AppPreferences.getPrefs();
    await prefs.setString(
      _defaultPokedexPrefKey,
      mode == DefaultPokedexMode.champions ? 'champions' : 'national',
    );
  }
}

/// When true, the home Pokédex and the Moves/Abilities/Items tools are scoped
/// to the Champions roster. Toggled from the tools sheet's Champions Pokédex
/// button or the Champions pill on the home screen.
final championsModeProvider = StateProvider<bool>((ref) {
  final prefs = AppPreferences.instance;
  if (prefs != null) {
    final saved = prefs.getString(_defaultPokedexPrefKey);
    return saved == 'champions';
  }
  return false;
});
