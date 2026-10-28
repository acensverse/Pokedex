import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/pokedex/pokedex_screen.dart';
import '../features/pokemon_detail/pokemon_detail_screen.dart';
import '../features/tools/comparator_screen.dart';
import '../features/tools/abilities_screen.dart';
import '../features/tools/items_screen.dart';
import '../features/tools/moves_screen.dart';
import '../features/tools/natures_screen.dart';
import '../features/tools/types_screen.dart';
import '../features/tools/team_builder_screen.dart';
import '../features/tools/team_detail_screen.dart';
import '../features/tools/new_team_screen.dart';
import '../features/tools/breeding_screen.dart';
import '../features/tools/speed_tiers_screen.dart';

import '../features/settings/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) =>
      _RouteErrorScreen(message: 'Page not found:\n${state.uri}'),
  routes: [
    GoRoute(path: '/', builder: (context, state) => const PokedexScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/pokemon/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null || id < 1) {
          return const _RouteErrorScreen(message: 'Invalid Pok\u00e9mon ID.');
        }
        return PokemonDetailScreen(pokemonId: id);
      },
    ),
    GoRoute(
      path: '/tools/comparator',
      builder: (context, state) => const ComparatorScreen(),
    ),
    GoRoute(
      path: '/tools/types',
      builder: (context, state) => const TypesScreen(),
    ),
    GoRoute(
      path: '/tools/moves',
      builder: (context, state) => const MovesScreen(),
    ),
    GoRoute(
      path: '/tools/items',
      builder: (context, state) => const ItemsScreen(),
    ),
    GoRoute(
      path: '/tools/abilities',
      builder: (context, state) => const AbilitiesScreen(),
    ),
    GoRoute(
      path: '/tools/natures',
      builder: (context, state) => const NaturesScreen(),
    ),
    GoRoute(
      path: '/tools/breeding',
      builder: (context, state) => const BreedingScreen(),
    ),
    GoRoute(
      path: '/tools/speed-tiers',
      builder: (context, state) => const SpeedTiersScreen(),
    ),
    GoRoute(
      path: '/tools/teams',
      builder: (context, state) => const TeamBuilderScreen(),
    ),
    GoRoute(
      path: '/tools/teams/detail',
      builder: (context, state) {
        final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
        if (id == null) {
          return const _RouteErrorScreen(message: 'Invalid team ID.');
        }
        return TeamDetailScreen(teamId: id);
      },
    ),
    GoRoute(
      path: '/tools/teams/new',
      builder: (context, state) {
        final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
        return NewTeamScreen(editId: id);
      },
    ),
  ],
);

class _RouteErrorScreen extends StatelessWidget {
  final String message;

  const _RouteErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oops!')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.catching_pokemon, size: 64),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Pok\u00e9dex'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
