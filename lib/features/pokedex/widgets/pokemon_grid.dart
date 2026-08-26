import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pokedex_provider.dart';
import 'pokemon_card.dart';

class PokemonGrid extends ConsumerWidget {
  const PokemonGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonList = ref.watch(filteredPokemonProvider);
    final pokedexState = ref.watch(pokedexProvider);

    // Seeding/loading failed and there is nothing to show: surface it with a retry.
    if (pokedexState.hasError && pokedexState.pokemonList.isEmpty) {
      return _PokedexErrorView(
        onRetry: () => ref.read(pokedexProvider.notifier).refresh(),
      );
    }

    // Loaded fine but the current search/filter combination matches nothing.
    if (!pokedexState.isLoading && !pokedexState.hasError && pokemonList.isEmpty) {
      return const _EmptyResultView();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(pokedexProvider.notifier).refresh(),
      child: ListView.builder(
        // Set strict itemExtent to enable fast O(1) layout calculations (crucial for 120+ FPS scrolling)
        itemExtent: 100,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: pokemonList.length + (pokedexState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < pokemonList.length) {
            return PokemonCard(pokemon: pokemonList[index]);
          } else {
            return const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class _PokedexErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PokedexErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Could not load the Pok\u00e9dex',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while preparing your offline data.\nCheck your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResultView extends StatelessWidget {
  const _EmptyResultView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Pok\u00e9mon found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different name or type filter.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
