import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pokedex_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/pokemon_helpers.dart';

class _GenInfo {
  final int gen;
  final String region;
  final int total;
  final List<int> starters;

  const _GenInfo(this.gen, this.region, this.total, this.starters);
}

const _gens = [
  _GenInfo(1, 'KANTO', 151, [1, 4, 7]),
  _GenInfo(2, 'JOHTO', 100, [152, 155, 158]),
  _GenInfo(3, 'HOENN', 135, [252, 255, 258]),
  _GenInfo(4, 'SINNOH', 107, [387, 390, 393]),
  _GenInfo(5, 'UNOVA', 156, [495, 498, 501]),
  _GenInfo(6, 'KALOS', 72, [650, 653, 656]),
  _GenInfo(7, 'ALOLA', 88, [722, 725, 728]),
  _GenInfo(8, 'GALAR', 96, [810, 813, 816]),
  _GenInfo(9, 'PALDEA', 120, [906, 909, 912]),
];

class GenFilterSheet extends ConsumerWidget {
  const GenFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGen = ref.watch(genFilterProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _gens.length,
              itemBuilder: (context, index) {
                final info = _gens[index];
                final isSelected = selectedGen == info.gen;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(genFilterProvider.notifier).state = isSelected
                          ? 0
                          : info.gen;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 115,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.blue.shade100,
                          width: isSelected ? 2.5 : 1,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFE8F4FD),
                            const Color(0xFFD6ECFB).withValues(alpha: 0.9),
                            Colors.blue.shade50,
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: 120,
                              child: CustomPaint(
                                painter: _DiagonalStripesPainter(),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          info.region,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF1A3A5C),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Generation ${info.gen}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.blue.shade600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 170,
                                    height: 100,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        for (var i = 0; i < 3; i++)
                                          Positioned(
                                            right: i * 42.0,
                                            child: Image.asset(
                                              PokemonHelpers.getHomeAssetPath(
                                                info.starters[i],
                                              ),
                                              width: 78,
                                              height: 78,
                                              cacheWidth:
                                                  PokemonHelpers.cacheWidth(
                                                    context,
                                                    78,
                                                  ),
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    width: 78,
                                                    height: 78,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            39,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.catching_pokemon,
                                                      color:
                                                          Colors.blue.shade200,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: selectedGen == 0
                    ? null
                    : () {
                        ref.read(genFilterProvider.notifier).state = 0;
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Clear Filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 12;

    for (var i = -2; i < 6; i++) {
      final x = i * 24.0;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
