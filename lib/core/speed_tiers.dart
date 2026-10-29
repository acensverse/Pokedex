import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'remote_data.dart';

/// One Pokémon's Level-50 speed tiers, as published on
/// pokemon-zone.com/champions/speed-tiers for the Pokémon Champions roster.
/// Baked into assets/speed_tiers.json by tool/build_champions_from_champout.js,
/// keyed to the app's pokedex_seed.json row ids.
class SpeedTier {
  final int id;

  /// Site rank (competition ranking by base Speed desc — ties share a rank).
  final int rank;
  final int base;

  /// 0 investment, neutral nature.
  final int noInvest;

  /// Full investment + helpful nature.
  final int maxPlus;

  /// Full investment, neutral nature.
  final int max;

  /// 0 investment, hindering nature.
  final int min;

  /// Choice Scarf / +1 priority on the Max+ build.
  final int scarf;

  /// Tailwind / +2 on the Max+ build.
  final int tailwind;

  /// Max+ build under paralysis (halved).
  final int paralyzed;

  const SpeedTier({
    required this.id,
    required this.rank,
    required this.base,
    required this.noInvest,
    required this.maxPlus,
    required this.max,
    required this.min,
    required this.scarf,
    required this.tailwind,
    required this.paralyzed,
  });
}

/// Computes the tier values from a base Speed, mirroring the Level-50 formulas
/// tool/build_champions_from_champout.js verifies against every upstream row.
/// Used only when a roster Pokémon has no upstream row (the build already
/// covers the whole roster, so this is a runtime safety net — the values are
/// identical).
SpeedTier computedTier(int id, String name, int base) {
  final noInvest = base + 20;
  final max = base + 52;
  final maxPlus = (max * 1.1).floor();
  return SpeedTier(
    id: id,
    rank: 0,
    base: base,
    noInvest: noInvest,
    maxPlus: maxPlus,
    max: max,
    min: (noInvest * 0.9).floor(),
    scarf: (maxPlus * 1.5).floor(),
    tailwind: maxPlus * 2,
    paralyzed: (maxPlus * 0.5).floor(),
  );
}

/// Speed tiers for the Champions roster, indexed by seed row id.
class SpeedTiersData {
  final Map<int, SpeedTier> byId;

  const SpeedTiersData({required this.byId});
}

/// Loads the speed tiers — the downloaded override when one is installed
/// (see remote_data.dart), else the baked asset.
final speedTiersDataProvider = FutureProvider<SpeedTiersData>((ref) async {
  // Re-evaluates when overrides are installed or reverted.
  ref.watch(remoteDataVersionProvider);
  final raw = await ref
      .read(remoteDataStoreProvider)
      .read(kRemoteSpeedTiersFile) ??
      await rootBundle.loadString(kSpeedTiersAssetPath);
  final data = jsonDecode(raw) as Map<String, dynamic>;
  final tiers = (data['tiers'] as List<dynamic>).cast<Map<String, dynamic>>();
  return SpeedTiersData(
    byId: {
      for (final t in tiers)
        (t['id'] as int): SpeedTier(
          id: t['id'] as int,
          rank: t['rank'] as int,
          base: t['base'] as int,
          noInvest: t['noInvest'] as int,
          maxPlus: t['maxPlus'] as int,
          max: t['max'] as int,
          min: t['min'] as int,
          scarf: t['scarf'] as int,
          tailwind: t['tailwind'] as int,
          paralyzed: t['paralyzed'] as int,
        ),
    },
  );
});
