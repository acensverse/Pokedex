import 'package:flutter/material.dart';
import '../../../models/pokemon.dart';
import '../../../core/feedback_service.dart';
import 'section_header.dart';

class StatsTab extends StatefulWidget {
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
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  String _statsMode = 'Base';

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

  int _calculateTotal() {
    return widget.pokemon.stats.fold<int>(0, (sum, s) {
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
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    // The actual stat bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 500),
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
          SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              displayValue.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
    return Column(
      key: ValueKey('Stats'),
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
                SizedBox(height: 24),

                // Mode Selector (Base, Min, Max)
                Builder(
                  builder: (context) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final int activeIndex = switch (_statsMode) {
                      'Min' => 1,
                      'Max' => 2,
                      _ => 0,
                    };
                    final Alignment indicatorAlignment = switch (activeIndex) {
                      1 => Alignment.center,
                      2 => Alignment.centerRight,
                      _ => Alignment.centerLeft,
                    };
                    const modes = ['Base', 'Min', 'Max'];

                    return Container(
                      height: 42,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.06,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            alignment: indicatorAlignment,
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOut,
                            child: FractionallySizedBox(
                              widthFactor: 1 / 3,
                              heightFactor: 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.themeColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: modes.map((mode) {
                              final isActive = _statsMode == mode;
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    AppFeedback.selectionClick();
                                    if (_statsMode != mode) {
                                      setState(() => _statsMode = mode);
                                    }
                                  },
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600),
                                        fontWeight: isActive
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        fontSize: 12.5,
                                      ),
                                      child: Text(mode),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),

                ...widget.pokemon.stats.map((s) {
                  final label = _getDisplayLabel(s.stat.name);
                  return _buildStatBar(label, s.baseStat, widget.themeColor);
                }),

                Divider(
                  color: Theme.of(context).dividerColor,
                  height: 32,
                  thickness: 1.5,
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        'Total',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Text(
                      _calculateTotal().toString(),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
