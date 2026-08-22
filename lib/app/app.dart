import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pokédex',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
