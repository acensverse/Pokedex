import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../app/theme/app_colors.dart';
import '../pokedex/widgets/tools_sheet.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../models/pokemon.dart';
import '../../core/providers.dart';
import 'widgets/pokemon_picker_sheet.dart';

final selectedBreedingPokemonProvider = StateProvider<Pokemon?>((ref) => null);

final breedingInfoProvider = FutureProvider.autoDispose<({List<String> eggGroups, int genderRate, int hatchCounter})?>((ref) async {
  final pokemon = ref.watch(selectedBreedingPokemonProvider);
  if (pokemon == null) return null;
  final repository = ref.watch(pokemonRepositoryProvider);
  return repository.getBreedingInfo(pokemon.speciesId);
});

class BreedingScreen extends ConsumerWidget {
  const BreedingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPokemon = ref.watch(selectedBreedingPokemonProvider);
    final breedingInfoAsync = ref.watch(breedingInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Breeding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Choose Pokemon Box
            GestureDetector(
              onTap: () async {
                final result = await PokemonPickerSheet.show(context);
                if (result != null) {
                  ref.read(selectedBreedingPokemonProvider.notifier).state = result;
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.pink.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedPokemon != null
                          ? Image.asset(
                              PokemonHelpers.getThumbnailAssetPath(selectedPokemon.id),
                              errorBuilder: (_, __, ___) => const Icon(Icons.pets, color: Colors.pink),
                            )
                          : const Icon(Icons.search, color: Colors.pink),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedPokemon != null ? PokemonHelpers.formatName(selectedPokemon.name) : 'Choose Pok\u00e9mon',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedPokemon != null ? 'Tap to change Pok\u00e9mon' : 'Select a Pok\u00e9mon to view breeding info',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Breeding Info Card
            if (selectedPokemon != null)
              breedingInfoAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('Error loading breeding data: $e'),
                  ),
                ),
                data: (info) {
                  if (info == null) return const SizedBox.shrink();
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionTitle('Egg Groups'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: info.eggGroups.isEmpty
                            ? [const Text('Undiscovered')]
                            : info.eggGroups.map((group) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.purple.shade200),
                                  ),
                                  child: Text(
                                    PokemonHelpers.formatName(group),
                                    style: TextStyle(
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      _SectionTitle('Gender Ratio'),
                      const SizedBox(height: 12),
                      _GenderBar(genderRate: info.genderRate),
                      
                      const SizedBox(height: 24),
                      _SectionTitle('Egg Cycles & Hatch Time'),
                      const SizedBox(height: 12),
                      _HatchTimeCard(hatchCounter: info.hatchCounter),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _GenderBar extends StatelessWidget {
  final int genderRate; // -1 = genderless, 0-8 where 8 is 100% female
  const _GenderBar({required this.genderRate});

  @override
  Widget build(BuildContext context) {
    if (genderRate == -1) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Genderless',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }
    
    final femalePercent = (genderRate / 8) * 100;
    final malePercent = 100 - femalePercent;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.male, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text('${malePercent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
            Row(
              children: [
                Text('${femalePercent.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                const SizedBox(width: 4),
                const Icon(Icons.female, color: Colors.pink, size: 20),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                flex: (malePercent * 10).toInt(),
                child: Container(height: 12, color: Colors.blue),
              ),
              Expanded(
                flex: (femalePercent * 10).toInt(),
                child: Container(height: 12, color: Colors.pink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HatchTimeCard extends StatelessWidget {
  final int hatchCounter;
  const _HatchTimeCard({required this.hatchCounter});

  @override
  Widget build(BuildContext context) {
    final baseSteps = hatchCounter * 255; // API formula
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_walk, color: Colors.orange, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$hatchCounter Egg Cycles',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Approx. $baseSteps steps to hatch',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
