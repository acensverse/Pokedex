import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModePrefKey = 'user_theme_mode_preference';
const String _layoutModePrefKey = 'user_pokedex_layout_preference';

enum PokedexLayoutMode { grid, list }

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  _initThemeFromPrefs(ref);
  return ThemeMode.system;
});

final pokedexLayoutProvider = StateProvider<PokedexLayoutMode>((ref) {
  _initLayoutFromPrefs(ref);
  return PokedexLayoutMode.list;
});

Future<void> _initThemeFromPrefs(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getString(_themeModePrefKey);
  if (savedMode == 'light') {
    ref.read(themeModeProvider.notifier).state = ThemeMode.light;
  } else if (savedMode == 'dark') {
    ref.read(themeModeProvider.notifier).state = ThemeMode.dark;
  } else if (savedMode == 'system') {
    ref.read(themeModeProvider.notifier).state = ThemeMode.system;
  }
}

Future<void> _initLayoutFromPrefs(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getString(_layoutModePrefKey);
  if (savedMode == 'list') {
    ref.read(pokedexLayoutProvider.notifier).state = PokedexLayoutMode.list;
  } else if (savedMode == 'grid') {
    ref.read(pokedexLayoutProvider.notifier).state = PokedexLayoutMode.grid;
  }
}

class ThemeHelper {
  static Future<void> setTheme(WidgetRef ref, ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themeModePrefKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themeModePrefKey, 'dark');
    } else {
      await prefs.setString(_themeModePrefKey, 'system');
    }
  }
}

class LayoutHelper {
  static Future<void> setLayout(WidgetRef ref, PokedexLayoutMode mode) async {
    ref.read(pokedexLayoutProvider.notifier).state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _layoutModePrefKey,
      mode == PokedexLayoutMode.grid ? 'grid' : 'list',
    );
  }
}

