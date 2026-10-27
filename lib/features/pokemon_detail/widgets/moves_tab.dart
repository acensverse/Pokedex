import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/pokemon.dart';
import '../../../app/theme/app_colors.dart';
import '../../tools/moves_screen.dart' show MoveEntry, movesSeedProvider;
import 'section_header.dart';
import 'package:go_router/go_router.dart';
import '../../pokedex/pokedex_provider.dart';

class MovesTab extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final Color themeColor;
  final Widget? header;

  MovesTab({
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

  @override
  Widget build(BuildContext context) {
    final allMovesAsync = ref.watch(movesSeedProvider);

    return allMovesAsync.when(
      data: (allMoves) {
        final lookup = {for (final m in allMoves) m.name: m};
        return _buildContent(lookup);
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading moves: $e')),
    );
  }

  Widget _buildContent(Map<String, MoveEntry> moveLookup) {
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
          } else if (methodIdx == 1)
            tmMoves.add(localMove);
          else if (methodIdx == 2)
            eggMoves.add(localMove);
          else if (methodIdx == 3)
            tutorMoves.add(localMove);
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

    final sortedLevelUp = dedupe(levelUpMoves);
    final sortedTm = dedupe(tmMoves);
    final sortedEgg = dedupe(eggMoves);
    final sortedTutor = dedupe(tutorMoves);

    List<_LocalMove> currentMoves;
    bool isLevelUp = false;
    if (_activeMoveTab == 'Level up') {
      currentMoves = sortedLevelUp;
      isLevelUp = true;
    } else if (_activeMoveTab == 'TM/HM') {
      currentMoves = sortedTm;
    } else if (_activeMoveTab == 'Eggs') {
      currentMoves = sortedEgg;
    } else {
      currentMoves = sortedTutor;
    }

    return Column(
      key: ValueKey('Moves'),
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: Container(
            padding: EdgeInsets.only(
              top: 0,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Movesets', themeColor: widget.themeColor),
                SizedBox(height: 16),
                Container(
                  height: 40,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final modes = ['Level up', 'TM/HM', 'Eggs', 'Tutor'];
                      final currentIndex = modes.indexOf(_activeMoveTab);
                      final tabWidth = constraints.maxWidth / modes.length;

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 300),
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
                              final isActive = _activeMoveTab == mode;
                              return Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => _activeMoveTab = mode),
                                  child: Center(
                                    child: AnimatedDefaultTextStyle(
                                      duration: Duration(
                                        milliseconds: 300,
                                      ),
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.white
                                            : Theme.of(context).textTheme.bodyMedium?.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
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
                SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: 16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: _buildMoveTable(currentMoves, isLevelUp: isLevelUp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoveTable(List<_LocalMove> moves, {required bool isLevelUp}) {
    if (moves.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No moves found for this category.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
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
              SizedBox(width: 12),
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
                    SizedBox(width: 4),
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
        ),
        ...moves.map(
          (m) => _LocalMoveRow(
            move: m,
            methodText: isLevelUp ? m.level.toString() : '-',
          ),
        ),
      ],
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

  _LocalMoveRow({required this.move, required this.methodText});

  String _formatName(String name) => name
      .replaceAll('-', ' ')
      .split(' ')
      .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
      .join(' ');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = move.entry;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref.read(searchQueryProvider.notifier).state = '';
        ref.read(debouncedSearchQueryProvider.notifier).state = '';
        ref.read(selectedTypesProvider.notifier).state = [];
        ref.read(genFilterProvider.notifier).state = 0;
        ref.read(favoritesOnlyProvider.notifier).state = false;
        ref.read(toolLearnerFilterProvider.notifier).state = null;
        ref.read(toolAbilityFilterProvider.notifier).state = null;

        ref.read(toolMoveFilterProvider.notifier).state = (
          name: _formatName(m.name),
          flavor: m.flavor ?? m.eff ?? '',
          type: m.type,
          category: m.cls,
          power: m.power,
          accuracy: m.acc,
          pp: m.pp,
          ids: {
            ...m.learn,
            ...m.learnDetails.map((ld) => ld[0]),
          },
        );

        if (context.mounted) {
          FocusManager.instance.primaryFocus?.unfocus();
          context.push('/');
        }
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
  _TypePill({required this.type});
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
  _CatPill({required this.cls});
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
