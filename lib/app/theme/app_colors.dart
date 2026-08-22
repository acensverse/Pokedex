import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE3350D);
  static const Color background = Color(0xFFF7F7F7);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF303030);
  static const Color textSecondary = Color(0xFF757575);

  static const Map<String, Color> typeColors = {
    'normal': Color(0xFF828282),
    'fire': Color(0xFFe4613e),
    'water': Color(0xFF3099e1),
    'electric': Color(0xFFdfbc28),
    'grass': Color(0xFF439837),
    'ice': Color(0xFF47c8c8),
    'fighting': Color(0xFFe49021),
    'poison': Color(0xFF9354cb),
    'ground': Color(0xFFa4733c),
    'flying': Color(0xFF74aad0),
    'psychic': Color(0xFFe96c8c),
    'bug': Color(0xFF9f9f28),
    'rock': Color(0xFFa9a481),
    'ghost': Color(0xFF6f4570),
    'dragon': Color(0xFF576fbc),
    'dark': Color(0xFF4f4747),
    'steel': Color(0xFF74b0cb),
    'fairy': Color(0xFFe18ce1),
  };

  static Color getTypeColor(String type) {
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }
}
