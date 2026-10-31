import 'dart:math' as math;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/champions.dart';
import '../../core/remote_data.dart';
import '../tools/widgets/tool_widgets.dart';
import 'widgets/search_bar.dart';
import 'widgets/pokemon_grid.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/gen_filter_sheet.dart';
import 'widgets/tools_sheet.dart';
import '../../core/feedback_service.dart';
import 'pokedex_provider.dart';


class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  bool _isSearching = false;
  bool _showFilters = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Refresh the Champions data from the pipeline at most every 6 h
    // (throttled inside the controller); silent when offline.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(remoteDataControllerProvider.notifier).maybeAutoCheck();
    });
  }

  String _genLabel(int gen) => gen == 0 ? 'All Gens' : 'Gen $gen';

  String _typeLabel(List<String> types) {
    if (types.isEmpty) return 'All Type';
    return types.map((t) => t[0].toUpperCase() + t.substring(1)).join(' + ');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final abilityFilter = ref.watch(toolAbilityFilterProvider);
    final learnerFilter = ref.watch(toolLearnerFilterProvider);
    final moveFilter = ref.watch(toolMoveFilterProvider);
    final activeTypes = ref.watch(selectedTypesProvider);
    final activeGen = ref.watch(genFilterProvider);
    final championsMode = ref.watch(championsModeProvider);
    final shinyMode = ref.watch(shinyModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(searchClearTriggerProvider, (_, _) {
      if (_isSearching) {
        setState(() {
          _isSearching = false;
        });
        ref.read(searchQueryProvider.notifier).state = '';
        ref.read(debouncedSearchQueryProvider.notifier).state = '';
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    });

    ref.listen<RemoteDataStatus>(remoteDataControllerProvider, (_, next) {
      if (next == RemoteDataStatus.updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Champions data updated.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(toolAbilityFilterProvider.notifier).state = null;
          ref.read(toolMoveFilterProvider.notifier).state = null;
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Semantics(
            button: true,
            label: 'Open Pok\u00e9dex tools menu',
            child: GestureDetector(
              onTap: () {
                AppFeedback.lightImpact();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ToolsSheet(),
                );
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    Text(
                      championsMode
                          ? 'Champions Pok\u00e9dex'
                          : 'Pok\u00e9dex',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        fontSize: championsMode ? 20 : null,
                        color: championsMode ? championsPurple : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: championsMode ? championsPurple : Colors.red,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                LucideIcons.search,
                color: _isSearching ? AppColors.primary : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    ref.read(searchQueryProvider.notifier).state = '';
                    ref.read(debouncedSearchQueryProvider.notifier).state = '';
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(0);
                    }
                  }
                });
              },
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: AnimatedRotation(
                turns: _showFilters ? 0.5 : 0,
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeInOutBack,
                child: const _PokeballIcon(size: 28),
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
            
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: const Icon(Icons.settings_outlined, size: 24),
              tooltip: 'Settings',
              onPressed: () {
                context.push('/settings');
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isSearching
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                      child: PokedexSearchBar(
                        onExit: () {
                          setState(() {
                            _isSearching = false;
                          });
                          ref.read(searchQueryProvider.notifier).state = '';
                          ref
                                  .read(debouncedSearchQueryProvider.notifier)
                                  .state =
                              '';
                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _showFilters
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterPill(
                            label: _genLabel(activeGen),
                            isActive: activeGen > 0,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const GenFilterSheet(),
                              );
                            },
                          ),
                          _FilterPill(
                            label: _typeLabel(activeTypes),
                            isActive: activeTypes.isNotEmpty,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const FilterSheet(),
                              );
                            },
                          ),
                          _FilterPill(
                            label: 'Favorites',
                            isActive: ref.watch(favoritesOnlyProvider),
                            onTap: () {
                              ref.read(favoritesOnlyProvider.notifier).state =
                                  !ref.read(favoritesOnlyProvider);
                            },
                          ),
                          _FilterPill(
                            label: 'Shiny',
                            icon: LucideIcons.sparkles,
                            isActive: shinyMode,
                            activeColor: const Color(0xFFFFA000),
                            onTap: () {
                              ref.read(shinyModeProvider.notifier).state =
                                  !ref.read(shinyModeProvider);
                            },
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (learnerFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Chip(
                      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                      side: Theme.of(context).chipTheme.side ?? BorderSide(color: Colors.grey.shade300),
                      label: Text(
                        '${learnerFilter.kind.toUpperCase()}: ${learnerFilter.name.toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        ref.read(toolLearnerFilterProvider.notifier).state =
                            null;
                        final router = GoRouter.of(context);
                        if (router.canPop()) router.pop();
                      },
                    ),
                  ],
                ),
              ),
            if (abilityFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    abilityFilter.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (abilityFilter.flavor.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                              child: Text(
                                abilityFilter.flavor,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          if (abilityFilter.eff.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                              child: Text(
                                'Effect',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                abilityFilter.eff,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AbilityModeSegmentedSwitch(
                      activeMode: abilityFilter.mode,
                      activeColor: const Color(0xFF9C27B0),
                      onModeChanged: (newMode) {
                        final c = ref.read(toolAbilityFilterProvider);
                        if (c != null) {
                          ref
                              .read(toolAbilityFilterProvider.notifier)
                              .state = (
                            name: c.name,
                            mode: newMode,
                            allIds: c.allIds,
                            normalIds: c.normalIds,
                            hiddenIds: c.hiddenIds,
                            flavor: c.flavor,
                            eff: c.eff,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            if (moveFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: moveFilter.type != null 
                                        ? AppColors.getTypeColor(moveFilter.type!)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    moveFilter.name.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (moveFilter.flavor.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                (moveFilter.eff != null && moveFilter.eff!.isNotEmpty)
                                    ? 4
                                    : 12,
                              ),
                              child: Text(
                                moveFilter.flavor,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          if (moveFilter.eff != null && moveFilter.eff!.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
                              child: Text(
                                'Effect',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                moveFilter.eff!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.grey.shade100,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                                                          ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (moveFilter.type != null)
                                  _MoveStatItemPill(
                                    label: 'TYPE',
                                    value: moveFilter.type!,
                                    pillColor: AppColors.getTypeColor(moveFilter.type!),
                                  ),
                                if (moveFilter.category != null)
                                  _MoveStatItemPill(
                                    label: 'CAT',
                                    value: moveFilter.category!,
                                    pillColor: moveFilter.category!.toLowerCase() == 'physical'
                                        ? Colors.redAccent
                                        : (moveFilter.category!.toLowerCase() == 'special'
                                            ? Colors.blueGrey
                                            : Colors.grey),
                                  ),
                                _MoveStatItem(
                                  label: 'PWR',
                                  value: moveFilter.power == null || moveFilter.power == 0 ? '-' : moveFilter.power.toString(),
                                ),
                                _MoveStatItem(
                                  label: 'ACC',
                                  value: moveFilter.accuracy == null || moveFilter.accuracy == 0 ? '-' : '${moveFilter.accuracy}%',
                                ),
                                _MoveStatItem(
                                  label: 'PP',
                                  value: moveFilter.pp == null ? '-' : moveFilter.pp.toString(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (championsMode)
                      Container(
                        height: 42,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: Color(0xFFD4AF37),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CHAMPIONS ROSTER LEARNERS (${moveFilter.championsIds.length})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _MoveModeSegmentedSwitch(
                        activeMode: moveFilter.mode,
                        activeColor: moveFilter.type != null
                            ? AppColors.getTypeColor(moveFilter.type!)
                            : const Color(0xFF26A69A),
                        hasTutor: moveFilter.tutorIds.isNotEmpty,
                        onModeChanged: (newMode) {
                          final c = ref.read(toolMoveFilterProvider);
                          if (c != null) {
                            ref
                                .read(toolMoveFilterProvider.notifier)
                                .state = (
                              name: c.name,
                              flavor: c.flavor,
                              eff: c.eff,
                              type: c.type,
                              category: c.category,
                              power: c.power,
                              accuracy: c.accuracy,
                              pp: c.pp,
                              mode: newMode,
                              allIds: c.allIds,
                              levelUpIds: c.levelUpIds,
                              tmIds: c.tmIds,
                              eggIds: c.eggIds,
                              tutorIds: c.tutorIds,
                              championsIds: c.championsIds,
                            );
                          }
                        },
                      ),
                  ],
                ),
              ),
            Expanded(child: PokemonGrid(scrollController: _scrollController)),
          ],
        ),
      ),
    );
  }
}

class _MoveStatItem extends StatelessWidget {
  final String label;
  final String value;
  const _MoveStatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}

class _MoveStatItemPill extends StatelessWidget {
  final String label;
  final String value;
  final Color pillColor;

  const _MoveStatItemPill({
    required this.label,
    required this.value,
    required this.pillColor,
  });

  String _capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}' : s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _capitalize(value),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _AbilityModeSegmentedSwitch extends StatefulWidget {
  final String activeMode;
  final Color activeColor;
  final ValueChanged<String> onModeChanged;

  const _AbilityModeSegmentedSwitch({
    required this.activeMode,
    this.activeColor = const Color(0xFF9C27B0),
    required this.onModeChanged,
  });

  @override
  State<_AbilityModeSegmentedSwitch> createState() =>
      _AbilityModeSegmentedSwitchState();
}

class _AbilityModeSegmentedSwitchState
    extends State<_AbilityModeSegmentedSwitch> {
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.activeMode;
  }

  @override
  void didUpdateWidget(covariant _AbilityModeSegmentedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeMode != oldWidget.activeMode) {
      _currentMode = widget.activeMode;
    }
  }

  void _onTapTab(String mode) {
    AppFeedback.selectionClick();
    if (_currentMode == mode) return;
    setState(() {
      _currentMode = mode;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onModeChanged(mode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int activeIndex = switch (_currentMode) {
      'normal' => 1,
      'hidden' => 2,
      _ => 0,
    };

    final Alignment indicatorAlignment = switch (activeIndex) {
      1 => Alignment.center,
      2 => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };

    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
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
                  color: widget.activeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildTab(context, 'All', 'all', 0, activeIndex, isDark),
              _buildTab(context, 'Normal', 'normal', 1, activeIndex, isDark),
              _buildTab(context, 'Hidden', 'hidden', 2, activeIndex, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    String mode,
    int index,
    int activeIndex,
    bool isDark,
  ) {
    final isSelected = activeIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTapTab(mode),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _MoveModeSegmentedSwitch extends StatefulWidget {
  final String activeMode;
  final Color? activeColor;
  final bool hasTutor;
  final ValueChanged<String> onModeChanged;

  const _MoveModeSegmentedSwitch({
    required this.activeMode,
    this.activeColor,
    this.hasTutor = false,
    required this.onModeChanged,
  });

  @override
  State<_MoveModeSegmentedSwitch> createState() =>
      _MoveModeSegmentedSwitchState();
}

class _MoveModeSegmentedSwitchState extends State<_MoveModeSegmentedSwitch> {
  late String _currentMode;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.activeMode;
  }

  @override
  void didUpdateWidget(covariant _MoveModeSegmentedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeMode != oldWidget.activeMode) {
      _currentMode = widget.activeMode;
    }
  }

  void _onTapTab(String mode) {
    if (_currentMode == mode) return;
    setState(() {
      _currentMode = mode;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onModeChanged(mode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabActiveColor = widget.activeColor ?? AppColors.primary;
    final modes = [
      ('all', 'All'),
      ('level-up', 'Level up'),
      ('tm', 'TM/HM'),
      ('egg', 'Eggs'),
      if (widget.hasTutor) ('tutor', 'Tutor'),
    ];

    final n = modes.length;
    var activeIndex = modes.indexWhere((m) =>
        m.$1 == _currentMode ||
        m.$2.toLowerCase() == _currentMode.toLowerCase() ||
        (m.$1 == 'tm' && (_currentMode.toLowerCase() == 'tm' || _currentMode.toLowerCase() == 'tm/hm')) ||
        (m.$1 == 'level-up' && (_currentMode.toLowerCase() == 'level-up' || _currentMode.toLowerCase() == 'level up')) ||
        (m.$1 == 'egg' && (_currentMode.toLowerCase() == 'egg' || _currentMode.toLowerCase() == 'eggs')));
    if (activeIndex < 0) activeIndex = 0;

    final double xAlignment = n > 1 ? -1.0 + (2.0 * activeIndex) / (n - 1) : 0.0;

    return Container(
      height: 42,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(xAlignment, 0.0),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 1 / n,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: tabActiveColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < n; i++)
                _buildTab(
                  context,
                  modes[i].$2,
                  modes[i].$1,
                  i,
                  activeIndex,
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    String mode,
    int index,
    int activeIndex,
    bool isDark,
  ) {
    final isSelected = activeIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTapTab(mode),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    this.icon,
    required this.isActive,
    this.activeColor = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey.shade300,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isActive ? activeColor : Colors.grey.shade700,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? activeColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PokeballIcon extends StatelessWidget {
  final double size;

  const _PokeballIcon({this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: _PokeballPainter()),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  const _PokeballPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = (math.min(w, h) / 2) - 1.0;
    if (radius <= 0) return;

    final ballRect = Rect.fromCircle(center: center, radius: radius);

    // 1. Ambient Drop Shadow underneath the sphere for realistic depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawCircle(center.translate(0, 1.2), radius, shadowPaint);

    // Save layer to clip sphere contents cleanly to the perimeter
    canvas.save();
    final circleClip = Path()..addOval(ballRect);
    canvas.clipPath(circleClip);

    // 2. Top Hemisphere (Actual Vibrant 3D Pokéball Scarlet Red with Spherical Shading)
    final topHalfPath = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..arcTo(ballRect, math.pi, math.pi, false)
      ..lineTo(center.dx + radius, center.dy)
      ..close();

    final redLightCenter = Offset(
      center.dx - radius * 0.25,
      center.dy - radius * 0.30,
    );
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (redLightCenter.dx - center.dx) / radius,
          (redLightCenter.dy - center.dy) / radius,
        ),
        radius: 0.95,
        colors: const [
          Color(0xFFFF4E4E), // bright light highlight
          Color(0xFFEE1515), // iconic vivid Pokéball red
          Color(0xFFB30B12), // deep crimson shading
          Color(0xFF7E0409), // outer rim shadow
        ],
        stops: const [0.0, 0.40, 0.80, 1.0],
      ).createShader(ballRect);

    canvas.drawPath(topHalfPath, topPaint);

    // 3. Curved Glossy Specular Glass Highlight on Top Shell
    final glossRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - radius * 0.44),
      width: radius * 1.15,
      height: radius * 0.46,
    );
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(glossRect);
    canvas.drawOval(glossRect, glossPaint);

    // 4. Bottom Hemisphere (3D Pearl White with Ambient Ground Bounce)
    final bottomHalfPath = Path()
      ..moveTo(center.dx - radius, center.dy)
      ..arcTo(ballRect, 0, math.pi, false)
      ..lineTo(center.dx - radius, center.dy)
      ..close();

    final whiteLightCenter = Offset(
      center.dx - radius * 0.20,
      center.dy + radius * 0.10,
    );
    final bottomPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (whiteLightCenter.dx - center.dx) / radius,
          (whiteLightCenter.dy - center.dy) / radius,
        ),
        radius: 0.95,
        colors: const [
          Color(0xFFFFFFFF), // pure pearl white
          Color(0xFFF2F4F7), // soft silver
          Color(0xFFD4DAE1), // ambient under-shadow
          Color(0xFFAAB3BD), // dark bottom rim
        ],
        stops: const [0.0, 0.45, 0.80, 1.0],
      ).createShader(ballRect);

    canvas.drawPath(bottomHalfPath, bottomPaint);

    // 5. Subtle Bottom Bounce Reflection
    final bottomBounceRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + radius * 0.72),
      width: radius * 0.72,
      height: radius * 0.22,
    );
    final bottomBouncePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(bottomBounceRect);
    canvas.drawOval(bottomBounceRect, bottomBouncePaint);

    // 6. Center Dividing Band (Recessed Obsidian Metal Band with Seams)
    final bandHeight = radius * 0.22;
    final bandRect = Rect.fromCenter(
      center: center,
      width: (radius + 2) * 2,
      height: bandHeight,
    );

    final bandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF141518),
          Color(0xFF24262C),
          Color(0xFF141518),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bandRect);

    canvas.drawRect(bandRect, bandPaint);

    // Groove seam lines at top and bottom of the band for physical separation
    final seamTopPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - bandHeight / 2),
      Offset(center.dx + radius, center.dy - bandHeight / 2),
      seamTopPaint,
    );

    final seamBottomPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.40)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + bandHeight / 2),
      Offset(center.dx + radius, center.dy + bandHeight / 2),
      seamBottomPaint,
    );

    // Restore clip
    canvas.restore();

    // 7. Center Button Assembly (Multi-layered 3D Tactile Release Mechanism)
    final outerRingRadius = radius * 0.35;
    final beveledRingRadius = radius * 0.27;
    final buttonSocketRadius = radius * 0.20;
    final innerButtonRadius = radius * 0.14;

    // A. Outer socket shadow onto the band
    canvas.drawCircle(
      center.translate(0, 0.7),
      outerRingRadius + 0.3,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0),
    );

    // B. Outer Dark Socket Ring
    final outerRingPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topLeft,
        radius: 0.9,
        colors: const [
          Color(0xFF2D2F36),
          Color(0xFF141518),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: outerRingRadius));
    canvas.drawCircle(center, outerRingRadius, outerRingPaint);

    // C. Metallic Beveled Ring (Silver Chrome)
    final bevelPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFE4E8ED),
          Color(0xFFB8C0C9),
          Color(0xFF88929E),
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: beveledRingRadius));
    canvas.drawCircle(center, beveledRingRadius, bevelPaint);

    // D. Dark Button Inset Groove
    final socketPaint = Paint()
      ..color = const Color(0xFF16171B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (beveledRingRadius - buttonSocketRadius);
    canvas.drawCircle(
      center,
      (beveledRingRadius + buttonSocketRadius) / 2,
      socketPaint,
    );

    // E. Raised Center Push Button (Luminous pure white with soft 3D spherical gradient)
    final buttonRect = Rect.fromCircle(center: center, radius: innerButtonRadius);
    final buttonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.85,
        colors: const [
          Color(0xFFFFFFFF), // pure core highlight
          Color(0xFFF1F4F8),
          Color(0xFFD2D8E0), // soft bevel shade
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(buttonRect);
    canvas.drawCircle(center, innerButtonRadius, buttonPaint);

    // F. Button Specular Shine Dot
    final shineOffset = Offset(
      center.dx - innerButtonRadius * 0.35,
      center.dy - innerButtonRadius * 0.35,
    );
    canvas.drawCircle(
      shineOffset,
      innerButtonRadius * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // 8. Crisp Outer Rim Bezel (Subtle metallic dark contour)
    final outerBezelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          const Color(0xFF1A1B1F).withValues(alpha: 0.60),
          const Color(0xFF0E0F12).withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(ballRect);
    canvas.drawCircle(center, radius, outerBezelPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
