import 'package:flutter/material.dart';

import 'name_forms.dart';

class PokemonHelpers {
  // NOTE: type-effectiveness data lives solely in core/utils/type_chart.dart.

  /// Formats a Pokemon name for display. Delegates to the data-driven
  /// NameForms engine (assets/name_forms.json): slugs become display names
  /// ("charizard-mega-x" -> "Mega Charizard X"), display-style names pass
  /// through unchanged. Add new forms to the JSON, never here.
  static String formatName(String rawName) => NameForms.toDisplay(rawName);

  /// Offline species data fallback (assets/species_fallback.json).
  static Map<String, dynamic> getPokemonSpeciesData(int id) =>
      NameForms.speciesFallback(id);

  // Returns the local asset path for the Pokemon thumbnail.
  // Assets are lossless WebP (bulk-converted from PNG, 192px max) to keep
  // the APK small.
  static String getThumbnailAssetPath(int id) {
    return 'assets/thumbnails/$id.webp';
  }

  // Decode budget for Image.asset: display size x device pixel ratio.
  // Prevents decoding a 512px texture (~1MB decoded) for a 76px card cell.
  static int cacheWidth(BuildContext context, double logicalSize) =>
      (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();

  // Returns the local asset path for the Pokemon Home 3D artwork
  // (lossless WebP, 256px max).
  static String getHomeAssetPath(int id) {
    return 'assets/home/$id.webp';
  }

  // Returns the local asset path for the Shiny Pokemon Home 3D artwork
  // (lossless WebP, 256px max).
  static String getHomeShinyAssetPath(int id) {
    return 'assets/home_shiny/$id.webp';
  }

  // Game version groups, newest first. Flavor text quality follows the most
  // recent game that actually features the species, so entries are ranked by
  // version instead of trusting the API array order (which is not strictly
  // chronological - e.g. Charizard's list starts with a Black entry).
  static const _flavorVersionGroupsNewestFirst = [
    ['scarlet', 'violet'],
    ['legends-arceus'],
    ['brilliant-diamond', 'shining-pearl'],
    ['sword', 'shield'],
    ['lets-go-pikachu', 'lets-go-eevee'],
    ['ultra-sun', 'ultra-moon'],
    ['sun', 'moon'],
    ['omega-ruby', 'alpha-sapphire'],
    ['x', 'y'],
    ['black-2', 'white-2'],
    ['black', 'white'],
    ['heartgold', 'soulsilver'],
    ['platinum'],
    ['diamond', 'pearl'],
    ['emerald'],
    ['firered', 'leafgreen'],
    ['ruby', 'sapphire'],
    ['crystal'],
    ['gold', 'silver'],
    ['yellow'],
    ['red', 'blue'],
  ];

  static int _flavorVersionRank(String version) {
    for (var i = 0; i < _flavorVersionGroupsNewestFirst.length; i++) {
      if (_flavorVersionGroupsNewestFirst[i].contains(version)) return i;
    }
    return _flavorVersionGroupsNewestFirst
        .length; // unknown versions rank oldest
  }

  /// Picks the English Pok\u00e9dex entry from the newest game available for a
  /// species. Ties within one generation resolve to the later array entry
  /// (e.g. Violet over Scarlet). Returns cleaned text or null.
  static String? pickLatestFlavorText(List<dynamic> rawEntries) {
    String? best;
    var bestRank = _flavorVersionGroupsNewestFirst.length + 1;
    var bestIndex = -1;
    for (var i = 0; i < rawEntries.length; i++) {
      final e = rawEntries[i];
      if (e is! Map) continue;
      if (e['language']?['name'] != 'en') continue;
      final text = e['flavor_text'];
      if (text is! String || text.isEmpty) continue;
      final version = e['version']?['name'];
      if (version is! String) continue;
      final rank = _flavorVersionRank(version);
      if (rank < bestRank || (rank == bestRank && i > bestIndex)) {
        bestRank = rank;
        bestIndex = i;
        best = text
            .replaceAll('\u00AD', '') // stray soft hyphens in old-game texts
            .replaceAll(RegExp(r'[\n\f\r]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
      }
    }
    return best;
  }
}
