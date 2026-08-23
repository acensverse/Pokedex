import 'package:flutter/material.dart';

/// Material icon approximations for the 18 types.
const Map<String, IconData> kTypeIcons = {
  'normal': Icons.radio_button_checked,
  'fire': Icons.local_fire_department,
  'water': Icons.water_drop,
  'electric': Icons.bolt,
  'grass': Icons.eco,
  'ice': Icons.ac_unit,
  'fighting': Icons.sports_mma,
  'poison': Icons.science,
  'ground': Icons.landscape,
  'flying': Icons.flight_takeoff,
  'psychic': Icons.psychology,
  'bug': Icons.bug_report,
  'rock': Icons.terrain,
  'ghost': Icons.blur_on,
  'dragon': Icons.auto_awesome,
  'dark': Icons.dark_mode,
  'steel': Icons.settings_suggest,
  'fairy': Icons.star,
};

IconData typeIcon(String type) =>
    kTypeIcons[type.toLowerCase()] ?? Icons.help_outline;
