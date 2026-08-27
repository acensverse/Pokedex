import 'package:flutter/material.dart';

class PokemonHelpers {
  // NOTE: type-effectiveness data lives solely in core/utils/type_chart.dart.

  // Formatting helper for Pokemon names to handle edge cases like hyphens, gender, and multi-word names
  static String formatName(String rawName) {
    if (rawName.isEmpty) return rawName;

    // Hardcoded edge cases
    if (rawName.toLowerCase() == 'mr-mime' ||
        rawName.toLowerCase() == 'mr. mime')
      return 'Mr. Mime';
    if (rawName.toLowerCase() == 'mime-jr' ||
        rawName.toLowerCase() == 'mime jr.')
      return 'Mime Jr.';
    if (rawName.toLowerCase() == 'nidoran-m') return 'Nidoran M';
    if (rawName.toLowerCase() == 'nidoran-f') return 'Nidoran F';
    if (rawName.toLowerCase() == 'type-null' ||
        rawName.toLowerCase() == 'type: null')
      return 'Type: Null';
    if (rawName.toLowerCase() == 'ho-oh') return 'Ho-Oh';
    if (rawName.toLowerCase() == 'porygon-z') return 'Porygon-Z';
    if (rawName.toLowerCase().startsWith('tapu-')) {
      return 'Tapu ${rawName.substring(5, 6).toUpperCase()}${rawName.substring(6)}';
    }

    String name = rawName.toLowerCase();

    // Handle form suffixes (API slugs are always hyphenated, never spaced)
    final suffixes = {
      '-mega-x': 'Mega ',
      '-mega-y': 'Mega ',
      '-mega': 'Mega ',
      '-gmax': 'Gigantamax ',
      '-alola': 'Alolan ',
      '-galar': 'Galarian ',
      '-hisui': 'Hisuian ',
      '-paldea': 'Paldean ',
      '-primal': 'Primal ',
    };

    String prefix = '';
    String suffixToAppend = '';

    for (final suffix in suffixes.keys) {
      if (name.endsWith(suffix)) {
        prefix = suffixes[suffix]!;
        name = name.replaceAll(suffix, '');
        if (suffix == '-mega-x') suffixToAppend = ' X';
        if (suffix == '-mega-y') suffixToAppend = ' Y';
        break;
      }
    }

    // Capitalize every word (split by both hyphens and spaces)
    final formattedBase = name
        .split(RegExp(r'[- ]'))
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');

    return '$prefix$formattedBase$suffixToAppend'.trim();
  }

  // Fallback species data lookups based on Pokemon ID (Offline first cache fallback)
  static Map<String, dynamic> getPokemonSpeciesData(int id) {
    if (id == 1 || id == 2 || id == 3) {
      return {
        'category': 'Seed Pokémon',
        'entry':
            'A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon.',
        'genderMale': 87.5,
        'genderFemale': 12.5,
        'eggGroups': ['Monster', 'Plant'],
        'growthRate': 'Medium Slow',
        'catchRate': '45 (17.6% - Pokeball - Full HP)',
        'evYield': '1 Sp. Atk',
        'baseHappiness': '70 (Normal)',
      };
    }
    if (id == 4 || id == 5 || id == 6) {
      return {
        'category': 'Lizard Pokémon',
        'entry':
            'Obviously prefers hot places. When it rains, steam is said to spout from the tip of its tail.',
        'genderMale': 87.5,
        'genderFemale': 12.5,
        'eggGroups': ['Monster', 'Dragon'],
        'growthRate': 'Medium Slow',
        'catchRate': '45 (17.6% - Pokeball - Full HP)',
        'evYield': '1 Speed',
        'baseHappiness': '70 (Normal)',
      };
    }
    // No offline data for other IDs: leave the entry empty so the UI can
    // fetch the real flavor text from the API instead of showing fake data.
    return {
      'category': '',
      'entry': '',
      'genderMale': 50.0,
      'genderFemale': 50.0,
      'eggGroups': ['Field'],
      'growthRate': 'Medium',
      'catchRate': '45 (17.6% - Pokeball - Full HP)',
      'evYield': '1 HP',
      'baseHappiness': '70 (Normal)',
    };
  }

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
