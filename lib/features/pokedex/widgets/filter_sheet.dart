import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../pokedex_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  void _toggleType(WidgetRef ref, String type, bool dualMode) {
    final notifier = ref.read(selectedTypesProvider.notifier);
    final current = List<String>.of(notifier.state);
    if (current.contains(type)) {
      current.remove(type);
    } else if (current.length >= (dualMode ? 2 : 1)) {
      if (dualMode) return;
      current
        ..clear()
        ..add(type);
    } else {
      current.add(type);
    }
    notifier.state = current;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(selectedTypesProvider);
    final dualMode = ref.watch(dualTypeModeProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 2.4,
                  children: AppColors.typeColors.keys.map((type) {
                    final isSelected = selectedTypes.contains(type);
                    final typeColor = AppColors.getTypeColor(type);

                    return GestureDetector(
                      onTap: () => _toggleType(ref, type, dualMode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? typeColor : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/types/$type.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              type[0].toUpperCase() + type.substring(1),
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Filter by two types',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: dualMode
                                ? AppColors.primary
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Switch(
                        value: dualMode,
                        onChanged: (val) {
                          final types = ref.read(selectedTypesProvider);
                          if (!val && types.length > 1) {
                            ref.read(selectedTypesProvider.notifier).state = [
                              types.first,
                            ];
                          }
                          ref.read(dualTypeModeProvider.notifier).state = val;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
