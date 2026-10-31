import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pokemon.dart';
import '../../../app/theme/app_colors.dart';
import '../../tools/moves_screen.dart' show MoveEntry, MoveDetailSheet, movesSeedProvider;
import '../../../core/feedback_service.dart';
import 'section_header.dart';
import '../../../core/utils/pokemon_helpers.dart';

class MovesTab extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final Color themeColor;
  final Widget? header;

  const MovesTab({
    super.key,
    required this.pokemon,
    required this.themeColor,
    this.header,
  });

  @override
  ConsumerState<MovesTab> createState() => _MovesTabState();
}

class _MovesTabState extends ConsumerState<MovesTab> {
  String _activeMoveTab = 'Level up';

  int? _cachedPokemonId;
  int? _cachedMovesLength;
  List<_LocalMove> _cachedLevelUp = [];
  List<_LocalMove> _cachedTm = [];
  List<_LocalMove> _cachedEgg = [];
  List<_LocalMove> _cachedTutor = [];

  void _ensureMovesExtracted(Map<String, MoveEntry> moveLookup) {
    if (_cachedPokemonId == widget.pokemon.id &&
        _cachedMovesLength == moveLookup.length) {
      return;
    }
    _cachedPokemonId = widget.pokemon.id;
    _cachedMovesLength = moveLookup.length;

    final levelUpMoves = <_LocalMove>[];
    final tmMoves = <_LocalMove>[];
    final eggMoves = <_LocalMove>[];
    final tutorMoves = <_LocalMove>[];

    for (final entry in moveLookup.values) {
      for (final ld in entry.learnDetails) {
        if (ld[0] == widget.pokemon.id) {
          final level = ld[1];
          final methodIdx = ld[2];
          final localMove = _LocalMove(entry: entry, level: level);

          if (methodIdx == 0) {
            levelUpMoves.add(localMove);
          } else if (methodIdx == 1) {
            tmMoves.add(localMove);
          } else if (methodIdx == 2) {
            eggMoves.add(localMove);
          } else if (methodIdx == 3) {
            tutorMoves.add(localMove);
          }
        }
      }
    }

    List<_LocalMove> dedupe(List<_LocalMove> list) {
      final seen = <String>{};
      final sorted = list.where((m) => seen.add(m.entry.name)).toList()
        ..sort((a, b) {
          final byLevel = a.level.compareTo(b.level);
          return byLevel != 0 ? byLevel : a.entry.name.compareTo(b.entry.name);
        });
      return sorted;
    }

    _cachedLevelUp = dedupe(levelUpMoves);
    _cachedTm = dedupe(tmMoves);
    _cachedEgg = dedupe(eggMoves);
    _cachedTutor = dedupe(tutorMoves);
  }

  @override
  Widget build(BuildContext context) {
    final allMovesAsync = ref.watch(movesSeedProvider);

    return allMovesAsync.when(
      data: (allMoves) {
        final lookup = {for (final m in allMoves) m.name: m};
        return _buildContent(lookup);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading moves: $e')),
    );
  }

  Widget _buildContent(Map<String, MoveEntry> moveLookup) {
    _ensureMovesExtracted(moveLookup);

    List<_LocalMove> currentMoves;
    bool isLevelUp = false;
    if (_activeMoveTab == 'Level up') {
      currentMoves = _cachedLevelUp;
      isLevelUp = true;
    } else if (_activeMoveTab == 'TM/HM') {
      currentMoves = _cachedTm;
    } else if (_activeMoveTab == 'Eggs') {
      currentMoves = _cachedEgg;
    } else {
      currentMoves = _cachedTutor;
    }

    final modes = ['Level up', 'TM/HM', 'Eggs', 'Tutor'];
    final currentIndex = modes.indexOf(_activeMoveTab);
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;
    final double xAlignment = -1.0 + (2.0 * safeIndex) / (modes.length - 1);

    return Column(
      key: const ValueKey('Moves'),
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Movesets', themeColor: widget.themeColor),
                const SizedBox(height: 16),
                Container(
                  height: 42,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: Theme.of(context).brightness == Brightness.dark
                              ? 0.25
                              : 0.06,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        alignment: Alignment(xAlignment, 0.0),
                        child: FractionallySizedBox(
                          widthFactor: 1 / modes.length,
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: modes.map((mode) {
                          final isActive = _activeMoveTab == mode;
                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                AppFeedback.selectionClick();
                                if (_activeMoveTab != mode) {
                                  setState(() => _activeMoveTab = mode);
                                }
                              },
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600),
                                    fontWeight: isActive
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 11.5,
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
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildMoveTable(currentMoves, isLevelUp: isLevelUp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(bool isLevelUp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              isLevelUp ? 'Lvl' : '-',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              'Move',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'Cat',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    'Pwr',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    'Acc',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveTable(List<_LocalMove> moves, {required bool isLevelUp}) {
    if (moves.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No moves found for this category.',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
      ),
      itemCount: moves.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildTableHeader(isLevelUp);
        }
        final m = moves[index - 1];
        return _LocalMoveRow(
          move: m,
          methodText: isLevelUp ? m.level.toString() : '-',
          activeTab: _activeMoveTab,
        );
      },
    );
  }
}

class _LocalMove {
  final MoveEntry entry;
  final int level;
  _LocalMove({required this.entry, required this.level});
}

class _LocalMoveRow extends ConsumerWidget {
  final _LocalMove move;
  final String methodText;
  final String activeTab;

  const _LocalMoveRow({
    required this.move,
    required this.methodText,
    required this.activeTab,
  });

  String _formatName(String name) => PokemonHelpers.formatName(name);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = move.entry;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => FractionallySizedBox(
            heightFactor: 0.85,
            child: MoveDetailSheet(move: m),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                methodText,
                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                textAlign: TextAlign.right,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(
                _formatName(m.name),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  Expanded(flex: 2, child: _TypePill(type: m.type)),
                  SizedBox(width: 4),
                  Expanded(flex: 2, child: _CatPill(cls: m.cls)),
                  SizedBox(
                    width: 36,
                    child: Text(
                      m.power?.toString() ?? '—',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      m.acc?.toString() ?? '∞',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;
  const _TypePill({required this.type});
  @override
  Widget build(BuildContext context) {
    final c = AppColors.getTypeColor(type);
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          type.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CatPill extends StatelessWidget {
  final String cls;
  const _CatPill({required this.cls});
  @override
  Widget build(BuildContext context) {
    Color c = Colors.grey;
    if (cls == 'physical') c = Colors.redAccent;
    if (cls == 'special') c = Colors.blueGrey;
    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          cls.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
