import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../models/pokemon.dart';
import '../../pokedex/widgets/pokemon_card.dart';

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

class _PokemonPickerSheetState extends ConsumerState<PokemonPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(localPokemonListProvider);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search for a Pok\u00e9mon...',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                  return const Center(child: Text('No matches'));
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
                      onTap: () => Navigator.pop(context, p),
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
