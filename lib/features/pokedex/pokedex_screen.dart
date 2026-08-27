import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import 'widgets/search_bar.dart';
import 'widgets/pokemon_grid.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/gen_filter_sheet.dart';
import 'widgets/tools_sheet.dart';
import 'pokedex_provider.dart';
import '../../core/providers.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({super.key});

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  bool _isSearching = false;
  bool _showFilters = false;
  final ScrollController _scrollController = ScrollController();

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

    ref.listen(searchClearTriggerProvider, (_, __) {
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

    final isChampions = ref.watch(isChampionsModeProvider);

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
              child: Row(
                children: [
                  Text(
                    isChampions ? 'POK\u00c9MON CHAMPIONS' : 'POKEDEX',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontSize: isChampions ? 18 : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isChampions
                          ? const Color(0xFF7E57C2)
                          : AppColors.primary,
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
          actions: [
            IconButton(
              icon: Icon(
                LucideIcons.search,
                color: _isSearching ? AppColors.primary : Colors.black54,
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
                            label: 'Shiny',
                            isActive: ref.watch(shinyModeProvider),
                            activeColor: Colors.amber,
                            onTap: () {
                              ref.read(shinyModeProvider.notifier).state = !ref
                                  .read(shinyModeProvider);
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
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300),
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
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    ref
                                            .read(
                                              toolAbilityFilterProvider
                                                  .notifier,
                                            )
                                            .state =
                                        null;
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
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _AbilityModeButton(
                            label: 'All',
                            isActive: abilityFilter.mode == 'all',
                            onTap: () {
                              final c = ref.read(toolAbilityFilterProvider);
                              if (c != null && c.mode != 'all') {
                                ref
                                    .read(toolAbilityFilterProvider.notifier)
                                    .state = (
                                  name: c.name,
                                  mode: 'all',
                                  allIds: c.allIds,
                                  normalIds: c.normalIds,
                                  hiddenIds: c.hiddenIds,
                                  flavor: c.flavor,
                                  eff: c.eff,
                                );
                              }
                            },
                          ),
                          _AbilityModeButton(
                            label: 'Normal',
                            isActive: abilityFilter.mode == 'normal',
                            onTap: () {
                              final c = ref.read(toolAbilityFilterProvider);
                              if (c != null && c.mode != 'normal') {
                                ref
                                    .read(toolAbilityFilterProvider.notifier)
                                    .state = (
                                  name: c.name,
                                  mode: 'normal',
                                  allIds: c.allIds,
                                  normalIds: c.normalIds,
                                  hiddenIds: c.hiddenIds,
                                  flavor: c.flavor,
                                  eff: c.eff,
                                );
                              }
                            },
                          ),
                          _AbilityModeButton(
                            label: 'Hidden',
                            isActive: abilityFilter.mode == 'hidden',
                            onTap: () {
                              final c = ref.read(toolAbilityFilterProvider);
                              if (c != null && c.mode != 'hidden') {
                                ref
                                    .read(toolAbilityFilterProvider.notifier)
                                    .state = (
                                  name: c.name,
                                  mode: 'hidden',
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
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (moveFilter.type != null)
                                  _MoveStatItem(label: 'TYPE', value: moveFilter.type!),
                                if (moveFilter.category != null)
                                  _MoveStatItem(label: 'CAT', value: moveFilter.category!),
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _AbilityModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AbilityModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey.shade600,
              ),
            ),
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
