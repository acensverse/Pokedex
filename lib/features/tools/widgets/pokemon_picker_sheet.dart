import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/providers.dart';
import '../../../core/utils/pokemon_helpers.dart';
import '../../../core/utils/type_icons.dart';
import '../../../models/pokemon.dart';

/// Modal sheet with a search field over the full local dex; returns the
/// picked [Pokemon] via Navigator.pop.
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
        color: Colors.white,
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
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
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
                    .where((p) =>
                        p.name.toLowerCase().contains(q) ||
                        p.id.toString() == q)
                    .toList();
                if (results.isEmpty) {
                  return const Center(child: Text('No matches'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, i) {
                    final p = results[i];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          PokemonHelpers.getThumbnailAssetPath(p.id),
                          width: 44,
                          height: 44,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.catching_pokemon, size: 32, color: Colors.grey.shade400),
                        ),
                      ),
                      title: Text(
                        PokemonHelpers.formatName(p.name),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('#${p.id.toString().padLeft(4, '0')}'),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          for (final t in p.types)
                            CircleAvatar(
                              radius: 9,
                              backgroundColor:
                                  AppColors.getTypeColor(t.type.name),
                              child: Icon(kTypeIcons[t.type.name],
                                  size: 11, color: Colors.white),
                            ),
                        ],
                      ),
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
