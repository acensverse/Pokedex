import 'package:flutter/material.dart';
import '../../../core/feedback_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../models/pokemon.dart';
import '../../pokedex/widgets/pokemon_card.dart';
import '../../../core/widgets/app_search_bar.dart';

/// Modal sheet with a search field over the full local dex, rendered with
/// the same cards as the home Pokedex grid; returns the picked [Pokemon]
/// via Navigator.pop.
class PokemonPickerSheet extends ConsumerStatefulWidget {
  const PokemonPickerSheet({super.key});

  static Future<Pokemon?> show(BuildContext context) {
    return showModalBottomSheet<Pokemon>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.85,
        child: PokemonPickerSheet(),
      ),
    );
  }

  @override
  ConsumerState<PokemonPickerSheet> createState() => _PokemonPickerSheetState();
}

class _PokemonPickerSheetState extends ConsumerState<PokemonPickerSheet> {  String _query = '';  final TextEditingController _searchController = TextEditingController();  @override  void dispose() {    _searchController.dispose();    super.dispose();  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(localPokemonListProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search for a Pokémon...',
              autofocus: true,
              voiceTitle: 'Pokémon Voice Search',
              voiceHint: 'Say a Pokémon name...',
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          Expanded(
            child: listAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load dex:\n$e')),
              data: (all) {
                final q = _query.toLowerCase().trim();
                final results = all
                    .where(
                      (p) =>
                          p.name.toLowerCase().contains(q) ||
                          p.id.toString() == q,
                    )
                    .toList();
                if (results.isEmpty) {
                  return Center(child: Text('No matches'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final p = results[i];
                    // Same cards as the home Pokedex grid; tap returns the
                    // Pokemon to the caller instead of navigating.
                    return PokemonCard(
                      pokemon: p,
                      showHero: false,
                      onTap: () {
                        AppFeedback.selectionClick();
                        Navigator.pop(context, p);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
