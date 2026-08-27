import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pokemon.dart';
import '../../../core/providers.dart';
import '../../../core/services/champions_data_service.dart';
import 'section_header.dart';

class StatsTab extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final Color themeColor;
  final Widget? header;

  const StatsTab({
    super.key,
    required this.pokemon,
    required this.themeColor,
    this.header,
  });

  @override
  ConsumerState<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<StatsTab> {
  String _statsMode = 'Base';
  List<PokemonStatSlot>? champsStats;

  @override
  void initState() {
    super.initState();
    _fetchChampsStats();
  }

  Future<void> _fetchChampsStats() async {
    final isChampions = ref.read(isChampionsModeProvider);
    if (isChampions) {
      final service = ref.read(championsDataServiceProvider);
      try {
        final roster = await service.getPokemonList();
        for (final p in roster) {
          if (p.id == widget.pokemon.id) {
            if (mounted) {
              setState(() {
                champsStats = p.stats;
              });
            }
            break;
          }
        }
      } catch (_) {}
    }
  }

  String _getDisplayLabel(String name) {
    switch (name.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return name;
    }
  }

  int _calculateTotal(List<PokemonStatSlot> stats) {
    return stats.fold<int>(0, (sum, s) {
      int baseValue = s.baseStat;
      final label = _getDisplayLabel(s.stat.name);

      if (_statsMode == 'Base') {
        return sum + baseValue;
      } else if (_statsMode == 'Min') {
        if (label == 'HP') {
          return sum + (baseValue * 2 + 110);
        } else {
          return sum + ((baseValue * 2 + 5) * 0.9).toInt();
        }
      } else {
        // Max
        if (label == 'HP') {
          return sum + (baseValue * 2 + 204);
        } else {
          return sum + ((baseValue * 2 + 99) * 1.1).toInt();
        }
      }
    });
  }

  Widget _buildStatBar(String label, int baseValue, Color color) {
    int displayValue;
    int maxValue = 255;

    if (_statsMode == 'Base') {
      displayValue = baseValue;
    } else if (_statsMode == 'Min') {
      if (label == 'HP') {
        displayValue = (baseValue * 2 + 110);
      } else {
        displayValue = ((baseValue * 2 + 5) * 0.9).toInt();
      }
      maxValue = label == 'HP' ? 714 : 504;
    } else {
      // Max
      if (label == 'HP') {
        displayValue = (baseValue * 2 + 204);
      } else {
        displayValue = ((baseValue * 2 + 99) * 1.1).toInt();
      }
      maxValue = label == 'HP' ? 714 : 504;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Dashed background line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        20,
                        (index) => Container(
                          width: constraints.maxWidth / 40,
                          height: 2,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    // The actual stat bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: 6,
                        width:
                            constraints.maxWidth *
                            (displayValue / maxValue).clamp(0.0, 1.0),
                        color: color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              displayValue.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localChampsStats = champsStats;

    return Column(
      key: const ValueKey('Stats'),
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 0,
              bottom: 16 + MediaQuery.paddingOf(context).bottom,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Base Statistics',
                  themeColor: widget.themeColor,
                ),
                const SizedBox(height: 24),

                // Mode Selector (Base, Min, Max)
                Container(
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final modes = ['Base', 'Min', 'Max'];
                      final currentIndex = modes.indexOf(_statsMode);
                      final tabWidth = constraints.maxWidth / modes.length;

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            left: currentIndex * tabWidth,
                            top: 0,
                            bottom: 0,
                            width: tabWidth,
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.themeColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: modes.map((mode) {
                              final isActive = _statsMode == mode;
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => _statsMode = mode),
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : Colors.black45,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      child: Text(mode),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                ...widget.pokemon.stats.map((s) {
                  final label = _getDisplayLabel(s.stat.name);
                  return _buildStatBar(label, s.baseStat, widget.themeColor);
                }),

                const Divider(
                  color: Colors.black12,
                  height: 32,
                  thickness: 1.5,
                ),

                Row(
                  children: [
                    const SizedBox(
                      width: 70,
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      _calculateTotal(widget.pokemon.stats).toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                if (localChampsStats != null) ...[
                  const SizedBox(height: 32),
                  SectionHeader(
                    title: 'Champions Statistics',
                    themeColor: widget.themeColor,
                  ),
                  const SizedBox(height: 32),
                  ...localChampsStats.map((s) {
                    final label = _getDisplayLabel(s.stat.name);
                    return _buildStatBar(label, s.baseStat, widget.themeColor);
                  }),
                  const Divider(
                    color: Colors.black12,
                    height: 32,
                    thickness: 1.5,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 70,
                        child: Text(
                          'Total',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        _calculateTotal(localChampsStats).toString(),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
