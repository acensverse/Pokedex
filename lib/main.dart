import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/app_preferences.dart';
import 'core/utils/name_forms.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load the data-driven name/cry rules before the UI resolves any name.
  await NameForms.load();
  await AppPreferences.init();
  runApp(const ProviderScope(child: PokedexApp()));
}
