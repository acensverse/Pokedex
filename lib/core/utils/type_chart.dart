class TypeChart {
  static const Map<String, Map<String, double>> _defense = {
    'normal': {'fighting': 2.0, 'ghost': 0.0},
    'fire': {'fire': 0.5, 'water': 2.0, 'grass': 0.5, 'ice': 0.5, 'ground': 2.0, 'bug': 0.5, 'rock': 2.0, 'steel': 0.5, 'fairy': 0.5},
    'water': {'fire': 0.5, 'water': 0.5, 'electric': 2.0, 'grass': 2.0, 'ice': 0.5, 'steel': 0.5},
    'electric': {'electric': 0.5, 'ground': 2.0, 'flying': 0.5, 'steel': 0.5},
    'grass': {'fire': 2.0, 'water': 0.5, 'electric': 0.5, 'grass': 0.5, 'ice': 2.0, 'poison': 2.0, 'ground': 0.5, 'flying': 2.0, 'bug': 2.0},
    'ice': {'fire': 2.0, 'ice': 0.5, 'fighting': 2.0, 'rock': 2.0, 'steel': 2.0},
    'fighting': {'flying': 2.0, 'psychic': 2.0, 'bug': 0.5, 'rock': 0.5, 'dark': 0.5, 'fairy': 2.0},
    'poison': {'grass': 0.5, 'fighting': 0.5, 'poison': 0.5, 'ground': 2.0, 'psychic': 2.0, 'bug': 0.5, 'fairy': 0.5},
    'ground': {'water': 2.0, 'electric': 0.0, 'grass': 2.0, 'ice': 2.0, 'poison': 0.5, 'rock': 0.5},
    'flying': {'electric': 2.0, 'grass': 0.5, 'ice': 2.0, 'fighting': 0.5, 'ground': 0.0, 'bug': 0.5, 'rock': 2.0},
    'psychic': {'fighting': 0.5, 'poison': 0.5, 'bug': 2.0, 'ghost': 2.0, 'dark': 2.0, 'psychic': 0.5},
    'bug': {'fire': 2.0, 'grass': 0.5, 'fighting': 0.5, 'ground': 0.5, 'flying': 2.0, 'rock': 2.0},
    'rock': {'normal': 0.5, 'fire': 0.5, 'water': 2.0, 'grass': 2.0, 'fighting': 2.0, 'poison': 0.5, 'ground': 2.0, 'flying': 0.5, 'steel': 2.0},
    'ghost': {'normal': 0.0, 'fighting': 0.0, 'poison': 0.5, 'bug': 0.5, 'ghost': 2.0, 'dark': 2.0},
    'dragon': {'fire': 0.5, 'water': 0.5, 'electric': 0.5, 'grass': 0.5, 'ice': 2.0, 'dragon': 2.0, 'fairy': 2.0},
    'dark': {'fighting': 2.0, 'psychic': 0.0, 'bug': 2.0, 'ghost': 0.5, 'dark': 0.5, 'fairy': 2.0},
    'steel': {'normal': 0.5, 'fire': 2.0, 'grass': 0.5, 'ice': 0.5, 'fighting': 2.0, 'poison': 0.0, 'ground': 2.0, 'flying': 0.5, 'psychic': 0.5, 'bug': 0.5, 'rock': 0.5, 'dragon': 0.5, 'steel': 0.5, 'fairy': 0.5},
    'fairy': {'fighting': 0.5, 'poison': 2.0, 'bug': 0.5, 'dragon': 0.0, 'dark': 0.5, 'steel': 2.0}
  };

  static Map<String, double> getEffectiveness(List<String> types) {
    final Map<String, double> effectiveness = {
      'normal': 1.0, 'fire': 1.0, 'water': 1.0, 'electric': 1.0, 'grass': 1.0, 'ice': 1.0,
      'fighting': 1.0, 'poison': 1.0, 'ground': 1.0, 'flying': 1.0, 'psychic': 1.0, 'bug': 1.0,
      'rock': 1.0, 'ghost': 1.0, 'dragon': 1.0, 'dark': 1.0, 'steel': 1.0, 'fairy': 1.0
    };

    for (var type in types) {
      final defense = _defense[type.toLowerCase()];
      if (defense != null) {
        defense.forEach((attackType, multiplier) {
          effectiveness[attackType] = (effectiveness[attackType] ?? 1.0) * multiplier;
        });
      }
    }
    return effectiveness;
  }
}
