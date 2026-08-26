import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/pokemon.dart';
import '../../pokedex/pokedex_provider.dart';
import '../pokemon_detail_screen.dart';

class AboutTab extends ConsumerWidget {
  final Pokemon pokemon;
  final Color themeColor;
  final Map<String, dynamic> speciesData;
  final Widget? header;

  const AboutTab({
    super.key,
    required this.pokemon,
    required this.themeColor,
    required this.speciesData,
    this.header,
  });

  String _resolveDescription(WidgetRef ref) {
    final staticEntry = speciesData['entry'] as String?;
    if (staticEntry != null && staticEntry.isNotEmpty) {
      return staticEntry.replaceAll('\n', ' ');
    }
    final cachedFlavor = ref.watch(cachedSpeciesProvider(pokemon.id)).asData?.value.flavorText;
    if (cachedFlavor != null && cachedFlavor.isNotEmpty) {
      return cachedFlavor;
    }
    final infoAsync = ref.watch(speciesInfoProvider(pokemon.id));
    return infoAsync.when(
      data: (info) => info.flavorText ?? 'No Pok\u00e9dex entry available.',
      loading: () => '\u2026',
      error: (_, _) => 'No Pok\u00e9dex entry available.',
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderRing(double? maleRatio) {
    if (maleRatio == null || maleRatio < 0) {
      return _buildIconText(Icons.transgender, 'Unknown');
    }

    final femaleRatio = 100.0 - maleRatio;
    String maleText = '${(maleRatio % 1 == 0) ? maleRatio.toInt() : maleRatio.toStringAsFixed(1)}%';
    String femaleText = '${(femaleRatio % 1 == 0) ? femaleRatio.toInt() : femaleRatio.toStringAsFixed(1)}%';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.male, size: 12, color: Colors.blueAccent),
                const SizedBox(width: 4),
                Text(maleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.female, size: 12, color: Colors.pinkAccent),
                const SizedBox(width: 4),
                Text(femaleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ],
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: maleRatio / 100,
            backgroundColor: Colors.pinkAccent,
            color: Colors.blueAccent,
            strokeWidth: 4,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      key: const ValueKey('About'),
      children: [
        if (header != null) header!,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              children: [
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    _resolveDescription(ref),
              textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 3-Column Stats Row (Height | Weight | Gender Ratio Ring)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: Center(child: _buildIconText(Icons.height, '${(pokemon.height / 10).toStringAsFixed(1)} m'))),
                const VerticalDivider(color: Colors.white54, thickness: 1, indent: 0, endIndent: 0),
                Expanded(child: Center(child: _buildIconText(Icons.fitness_center, '${(pokemon.weight / 10).toStringAsFixed(1)} kg'))),
                const VerticalDivider(color: Colors.white54, thickness: 1, indent: 0, endIndent: 0),
                Expanded(child: Center(child: _buildGenderRing(speciesData['genderMale']))),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),

        // Abilities Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 36, bottom: 32, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                width: double.infinity,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: pokemon.abilities.map((a) {
                    final isHidden = a.isHidden;
                    final rawName = a.ability.name.replaceAll('-', ' ');
                    final abilityName = rawName.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
                    return GestureDetector(
                      onTap: () async {
                        final seed = ref.read(abilitiesSeedProvider).value;
                        if (seed == null) return;
                        final slug = a.ability.name;
                        final match = seed.firstWhere(
                          (e) => e['name'] == slug,
                          orElse: () => {},
                        );
                        if (match.isEmpty) return;
                        final allIds = (match['pokemon'] as List<dynamic>? ?? [])
                            .map((e) => e as int)
                            .toSet();
                        final hiddenIds = (match['hidden'] as List<dynamic>? ?? [])
                            .map((e) => e as int)
                            .toSet();
                        final normalIds = allIds.difference(hiddenIds);
                        final flavor = (match['flavor'] as String?) ?? '';
                        final eff = (match['eff'] as String?) ?? '';
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(debouncedSearchQueryProvider.notifier).state = '';
                        ref.read(selectedTypesProvider.notifier).state = [];
                        ref.read(genFilterProvider.notifier).state = 0;
                        ref.read(favoritesOnlyProvider.notifier).state = false;
                        ref.read(toolLearnerFilterProvider.notifier).state = null;

                        ref.read(toolAbilityFilterProvider.notifier).state = (
                          name: abilityName,
                          mode: 'all',
                          allIds: allIds,
                          normalIds: normalIds,
                          hiddenIds: hiddenIds,
                          flavor: flavor,
                          eff: eff,
                        );
                        if (context.mounted) context.push('/');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: themeColor.withValues(alpha: 0.8), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHidden) ...[
                              const Text(
                                'Hidden',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 12, color: Colors.white54),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              abilityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Abilities',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ), // Close Padding

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
