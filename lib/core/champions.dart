import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

  const ChampionsData({
    required this.pokemonIds,
    required this.speciesIds,
    required this.itemSlugs,
  });
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
  return ChampionsData(
    pokemonIds: {for (final p in pokemon) p['id'] as int},
    speciesIds: {for (final p in pokemon) p['dex'] as int},
    itemSlugs: {
      for (final name in (data['items'] as List<dynamic>).cast<String>())
        normalizeItemName(name),
    },
  );
});

/// When true, the home Pokédex and the Moves/Abilities/Items tools are scoped
/// to the Champions roster. Toggled from the tools sheet's Champions Pokédex
/// button or the Champions pill on the home screen.
final championsModeProvider = StateProvider<bool>((ref) => false);
