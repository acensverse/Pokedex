class PokemonHelpers {
  // NOTE: type-effectiveness data lives solely in core/utils/type_chart.dart.

  // Formatting helper for Pokemon names to handle edge cases like hyphens, gender, and multi-word names
  static String formatName(String rawName) {
    if (rawName.isEmpty) return rawName;
    
    // Hardcoded edge cases
    if (rawName.toLowerCase() == 'mr-mime' || rawName.toLowerCase() == 'mr. mime') return 'Mr. Mime';
    if (rawName.toLowerCase() == 'mime-jr' || rawName.toLowerCase() == 'mime jr.') return 'Mime Jr.';
    if (rawName.toLowerCase() == 'nidoran-m') return 'Nidoran ♂';
    if (rawName.toLowerCase() == 'nidoran-f') return 'Nidoran ♀';
    if (rawName.toLowerCase() == 'type-null' || rawName.toLowerCase() == 'type: null') return 'Type: Null';
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
    final formattedBase = name.split(RegExp(r'[- ]')).map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    
    return '$prefix$formattedBase$suffixToAppend'.trim();
  }

  // Fallback species data lookups based on Pokemon ID (Offline first cache fallback)
  static Map<String, dynamic> getPokemonSpeciesData(int id) {
    if (id == 1 || id == 2 || id == 3) {
      return {
        'category': 'Seed Pokémon',
        'entry': 'A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon.',
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
        'entry': 'Obviously prefers hot places. When it rains, steam is said to spout from the tip of its tail.',
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

  // Get generic categories for physical/special/status moves
  static String getMoveCategory(String moveName) {
    final statusMoves = {'growl', 'leech seed', 'poison powder', 'sweet scent', 'worry seed', 'growth', 'synthesis', 'sleep powder'};
    final specialMoves = {'solar beam', 'vine whip', 'razor leaf', 'seed bomb'};
    
    if (statusMoves.contains(moveName.toLowerCase())) return 'STATUS';
    if (specialMoves.contains(moveName.toLowerCase())) return 'SPECIAL';
    return 'PHYSICAL';
  }

  // Returns the local asset path for the Pokemon thumbnail
  static String getThumbnailAssetPath(int id) {
    return 'assets/thumbnails/$id.png';
  }

  // Returns the local asset path for the Pokemon Home 3D artwork
  static String getHomeAssetPath(int id) {
    return 'assets/home/$id.png';
  }

  // Returns the local asset path for the Shiny Pokemon Home 3D artwork
  static String getHomeShinyAssetPath(int id) {
    return 'assets/home_shiny/$id.png';
  }
}
