import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/pokedex/pokedex_screen.dart';
import '../features/pokemon_detail/pokemon_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => _RouteErrorScreen(
    message: 'Page not found:\n${state.uri}',
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PokedexScreen(),
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
