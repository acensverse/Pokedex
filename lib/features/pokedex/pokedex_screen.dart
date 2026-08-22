import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import 'widgets/search_bar.dart';
import 'widgets/pokemon_grid.dart';
import 'widgets/filter_sheet.dart';
import 'pokedex_provider.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final activeFilter = ref.watch(typeFilterProvider);
    final isShiny = ref.watch(shinyModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? const PokedexSearchBar()
            : Row(
                children: [
                  Text(
                    'POKEDEX',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(width: 8),
                  // Red check dropdown icon
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
        actions: [
          // Shiny Mode Switch
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.auto_awesome,
                    color: isShiny ? Colors.amber : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
                Switch(
                  value: isShiny,
                  onChanged: (val) {
                    ref.read(shinyModeProvider.notifier).state = val;
                  },
                ),
              ],
            ),
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black54, size: 28),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  ref.read(searchQueryProvider.notifier).state = '';
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black54, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (activeFilter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    label: Text(
                      'TYPE: ${activeFilter.toUpperCase()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      ref.read(typeFilterProvider.notifier).state = '';
                    },
                  ),
                ],
              ),
            ),
          const Expanded(
            child: PokemonGrid(),
          ),
        ],
      ),
    );
  }
}
