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
                    const SizedBox(width: 8),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color:
                            championsMode ? championsPurple : AppColors.primary,
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
              tooltip: 'Shiny mode',
              icon: Icon(
                LucideIcons.sparkles,
                size: 24,
                color: shinyMode
                    ? Colors.amber
                    : Theme.of(context)
                        .iconTheme
                        .color
                        ?.withValues(alpha: 0.7),
              ),
              onPressed: () {
                ref.read(shinyModeProvider.notifier).state =
                    !ref.read(shinyModeProvider);
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
                            label: 'Champions',
                            isActive: championsMode,
                            activeColor: const Color(0xFF8E24AA),
                            onTap: () {
                              final next = !ref.read(championsModeProvider);
                              ref.read(championsModeProvider.notifier).state =
                                  next;
                              if (next) {
                                // Entering champions mode starts clean
                                ref.read(selectedTypesProvider.notifier).state =
                                    [];
                                ref.read(genFilterProvider.notifier).state = 0;
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
                                ref
                                    .read(debouncedSearchQueryProvider
                                        .notifier)
                                    .state = '';
                                ref
                                    .read(toolLearnerFilterProvider.notifier)
                                    .state = null;
                                ref
                                    .read(toolAbilityFilterProvider.notifier)
                                    .state = null;
                                ref
                                    .read(toolMoveFilterProvider.notifier)
                                    .state = null;
                              }
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
                        border: Border.all(color: Theme.of(context).dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                                    color: AppColors.primary,
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
                                  color: Colors.grey.shade700,
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
                                  color: Colors.grey.shade600,
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
                        border: Border.all(color: Theme.of(context).dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
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
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(toolMoveFilterProvider.notifier)
                                        .state = null;
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.black45,
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
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                              child: Text(
                                moveFilter.flavor,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
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

class _AbilityModeSegmentedSwitch extends StatelessWidget {
  final String activeMode;
  final ValueChanged<String> onModeChanged;

  const _AbilityModeSegmentedSwitch({
    required this.activeMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int activeIndex = switch (activeMode) {
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
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: indicatorAlignment,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
        onTap: () {
          if (!isSelected) {
            onModeChanged(mode);
          }
        },
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

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isActive,
    this.activeColor = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? activeColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _PokeballIcon extends StatelessWidget {
  final double size;

  const _PokeballIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PokeballPainter()),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  static const _outlineColor = Color(0xFF303030);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bandHeight = size.height * 0.12;
    final buttonRadius = radius * 0.34;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.14159,
      3.14159,
      true,
      Paint()..color = AppColors.primary,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      3.14159,
      true,
      Paint()..color = Colors.white,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height / 2 - bandHeight / 2,
        size.width,
        bandHeight,
      ),
      Paint()..color = _outlineColor,
    );

    canvas.drawCircle(center, buttonRadius, Paint()..color = _outlineColor);
    canvas.drawCircle(
      center,
      buttonRadius * 0.66,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      buttonRadius * 0.28,
      Paint()..color = _outlineColor,
    );

    canvas.drawCircle(
      center,
      radius - 0.75,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = _outlineColor,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
