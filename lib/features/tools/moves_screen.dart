import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/champions.dart';
import '../../core/remote_data.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../pokedex/pokedex_provider.dart';
import '../pokedex/widgets/tools_sheet.dart';
import 'widgets/tool_widgets.dart';
import '../../core/widgets/app_search_bar.dart';


class MoveEntry {
  final int id;
  final String name;
  final String type;
  final String cls;
  final int? power;
  final int? pp;
  final int? acc;
  final int pri;
  final String gen;
  final String ail;
  final String? eff;
  final String? flavor;

  /// IDs (base forms only) of Pokemon that can learn this move. Baked into
  /// the seed so the learner list works fully offline.
  final List<int> learn;

  /// Contest condition (e.g. "smart"), null when the move has none.
  final String? contest;

  /// Learn details baked from every Pokemon's moves array, deduped across
  /// game versions: entries are [pokemonId, level, methodIdx] where
  /// methodIdx: 0=level-up, 1=machine, 2=egg, 3=tutor, 4=other.
  /// Level is 0 for non-level-up methods.
  final List<List<int>> learnDetails;

  const MoveEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.cls,
    required this.power,
    required this.pp,
    required this.acc,
    required this.pri,
    required this.gen,
    required this.ail,
    required this.eff,
    required this.flavor,
    required this.learn,
    required this.contest,
    required this.learnDetails,
  });

  factory MoveEntry.fromJson(Map<String, dynamic> json) => MoveEntry(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        cls: json['cls'] as String,
        power: json['power'] as int?,
        pp: json['pp'] as int?,
        acc: json['acc'] as int?,
        pri: (json['pri'] as int?) ?? 0,
        gen: (json['gen'] as String?) ?? '',
        ail: (json['ail'] as String?) ?? 'none',
        eff: json['eff'] as String?,
        flavor: json['flavor'] as String?,
        learn: (json['learn'] as List<dynamic>? ?? const [])
            .map((e) => e as int)
            .toList(),
        contest: json['contest'] as String?,
        learnDetails: (json['ld'] as List<dynamic>? ?? const [])
            .map((e) => (e as List<dynamic>).map((x) => x as int).toList())
            .toList(),
      );
}


/// All moves baked from assets/moves_seed.json (offline-first),
/// with runtime overrides supported when Champions data is updated.
final movesSeedProvider = FutureProvider<List<MoveEntry>>((ref) async {
  ref.watch(remoteDataVersionProvider);
  final store = ref.read(remoteDataStoreProvider);
  final override = await store.read(kRemoteMovesFile);
  final raw = override ?? await rootBundle.loadString(kMovesAssetPath);
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => MoveEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

String _clsLabel(String cls) {
  switch (cls) {
    case 'physical':
      return 'Physical';
    case 'special':
      return 'Special';
    default:
      return 'Status';
  }
}

Color _clsColor(String cls) {
  switch (cls) {
    case 'physical':
      return const Color(0xFFE4613E); // fire-red
    case 'special':
      return const Color(0xFF3099E1); // water-blue
    default:
      return Colors.grey.shade600;
  }
}

class MovesScreen extends ConsumerStatefulWidget {
  const MovesScreen({super.key});

  @override
  ConsumerState<MovesScreen> createState() => _MovesScreenState();
}

class _MovesScreenState extends ConsumerState<MovesScreen> {
  String _query = '';
  bool _isSearching = false;
  String? _typeFilter;
  String? _clsFilter;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(MoveEntry move) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,
        child: MoveDetailSheet(move: move),
      ),
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MovesFilterSheet(
        selectedType: _typeFilter,
        selectedCls: _clsFilter,
        onTypeSelected: (t) => setState(() => _typeFilter = t),
        onClsSelected: (c) => setState(() => _clsFilter = c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movesAsync = ref.watch(movesSeedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Moves'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 26,
              color: _isSearching
                  ? (isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100))
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: Icon(
              Icons.tune,
              size: 26,
              color: (_typeFilter != null || _clsFilter != null)
                  ? (isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100))
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: movesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 12),
              Text('Could not load moves'),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(movesSeedProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (moves) {
          final q = _query.toLowerCase();
          final championsMode = ref.watch(championsModeProvider);
          final championSpecies =
              ref.watch(championsDataProvider).value?.speciesIds;
          final filtered = moves.where((m) {
            final matchesQuery = q.isEmpty || m.name.replaceAll('-', ' ').contains(q);
            final matchesType =
                _typeFilter == null || m.type == _typeFilter;
            final matchesCls = _clsFilter == null || m.cls == _clsFilter;
            // Champions mode: keep only moves a roster Pokemon can learn.
            // `learn` holds base-form ids, so compare against the roster's
            // species (dex) ids.
            final matchesChampions = !championsMode ||
                (championSpecies != null &&
                    m.learn.any(championSpecies.contains));
            return matchesQuery && matchesType && matchesCls && matchesChampions;
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // A-Z
          return Column(
            children: [
              if (championsMode)
                const ChampionsModeBanner(
                  message:
                      'Champions Pok\u00e9dex \u2014 only moves a roster Pok\u00e9mon can learn',
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Search moves...',
                          autofocus: true,
                          voiceTitle: 'Moves Voice Search',
                          voiceHint: 'Say a move name...',
                          onChanged: (v) => setState(() => _query = v),
                          onClear: () => setState(() => _query = ''),
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No moves match your search or filters',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          4,
                          16,
                          16 + MediaQuery.paddingOf(context).bottom,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) => _MoveCard(
                          move: filtered[index],
                          onTap: () => _openDetail(filtered[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bottom-sheet filter picker: 18 types + 3 damage classes = 21 cells laid
/// out as a 3-column x 7-row grid. Damage-class pills carry a permanent
/// colored border so they stand apart from the type pills.
class _MovesFilterSheet extends StatelessWidget {
  final String? selectedType;
  final String? selectedCls;
  final ValueChanged<String?> onTypeSelected;
  final ValueChanged<String?> onClsSelected;

  const _MovesFilterSheet({
    required this.selectedType,
    required this.selectedCls,
    required this.onTypeSelected,
    required this.onClsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 2.4,
              children: [
                for (final type in AppColors.typeColors.keys)
                  _FilterTypePill(
                    type: type,
                    isSelected: selectedType == type,
                    onTap: () {
                      onTypeSelected(selectedType == type ? null : type);
                      Navigator.pop(context);
                    },
                  ),
                for (final cls in const ['physical', 'special', 'status'])
                  _FilterClsPill(
                    cls: cls,
                    isSelected: selectedCls == cls,
                    onTap: () {
                      onClsSelected(selectedCls == cls ? null : cls);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Type pill: identical style to the Pokedex type sheet — tinted background,
/// SVG icon + colored label, thick border only when selected.
class _FilterTypePill extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTypePill({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = AppColors.getTypeColor(type);
    return GestureDetector(
      onTap: onTap,
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
            SvgPicture.asset('assets/types/${type.toLowerCase()}.svg', width: 24, height: 24),
            SizedBox(width: 4),
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
  }
}

/// Damage-class pill: same shape, but with a permanent colored border
/// ("special border") so Physical/Special/Status read as a different kind
/// of filter than the types.
class _FilterClsPill extends StatelessWidget {
  final String cls;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterClsPill({
    required this.cls,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clsColor = _clsColor(cls);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: clsColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? clsColor : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Center(
          child: Text(
            _clsLabel(cls),
            style: TextStyle(
              color: clsColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveCard extends StatelessWidget {
  final MoveEntry move;
  final VoidCallback onTap;

  const _MoveCard({required this.move, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = AppColors.getTypeColor(move.type);
    final clsColor = _clsColor(move.cls);

    return Semantics(
      button: true,
      label: 'Open details for ${PokemonHelpers.formatName(move.name)}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/types/${move.type}.svg',
                    width: 26,
                    height: 26,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PokemonHelpers.formatName(move.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      [
                        move.type[0].toUpperCase() + move.type.substring(1),
                        if (move.power != null) 'Power ${move.power}',
                        if (move.acc != null) 'Acc ${move.acc}%',
                        'PP ${move.pp ?? '-'}',
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: clsColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: clsColor, width: 1.2),
                ),
                child: Text(
                  _clsLabel(move.cls),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: clsColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Move detail bottom sheet — centered header, solid type/class chips,
/// outlined section pills ("Stats", "Details", "Damage dealt") overlapping
/// white cards, and a fixed gradient POKEMON LIST button that jumps to the
/// home Pokedex filtered to the Pokemon that learn this move.
class MoveDetailSheet extends ConsumerWidget {
  final MoveEntry move;

  const MoveDetailSheet({super.key, required this.move});

  void _openLearnersInPokedex(BuildContext context, WidgetRef ref) {
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(debouncedSearchQueryProvider.notifier).state = '';
    ref.read(selectedTypesProvider.notifier).state = [];
    ref.read(genFilterProvider.notifier).state = 0;
    ref.read(favoritesOnlyProvider.notifier).state = false;
    ref.read(toolAbilityFilterProvider.notifier).state = null;
    ref.read(toolLearnerFilterProvider.notifier).state = null;
    final all = {
      ...move.learn,
      ...move.learnDetails.map((ld) => ld[0]),
    };
    final levelUp = <int>{};
    final tm = <int>{};
    final egg = <int>{};
    final tutor = <int>{};
    for (final ld in move.learnDetails) {
      final pid = ld[0];
      final m = ld[1];
      if (m == 1) levelUp.add(pid);
      if (m == 4) tm.add(pid);
      if (m == 2) egg.add(pid);
      if (m == 3) tutor.add(pid);
    }
    for (final pid in move.learn) {
      levelUp.add(pid);
    }

    ref.read(toolMoveFilterProvider.notifier).state = (
      name: PokemonHelpers.formatName(move.name),
      flavor: move.flavor ?? '',
      eff: move.eff,
      type: move.type,
      category: move.cls,
      power: move.power,
      accuracy: move.acc,
      pp: move.pp,
      mode: 'all',
      allIds: all,
      levelUpIds: levelUp,
      tmIds: tm,
      eggIds: egg,
      tutorIds: tutor,
      championsIds: const <int>{},
    );
    Navigator.of(context).pop(); // close the sheet
    // push (not go) so system-back from the filtered home returns here.
    FocusManager.instance.primaryFocus?.unfocus();
    GoRouter.of(context).push('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = AppColors.getTypeColor(move.type);
    final clsColor = _clsColor(move.cls);

    // Damage-dealt groups for this move's attacking type.
    final supers = <String>[];
    final weaks = <String>[];
    final noEffects = <String>[];
    final normals = <String>[];
    for (final defender in AppColors.typeColors.keys) {
      final mult = TypeChart.getEffectiveness([defender])[move.type] ?? 1.0;
      if (mult > 1) {
        supers.add(defender);
      } else if (mult == 0) {
        noEffects.add(defender);
      } else if (mult < 1) {
        weaks.add(defender);
      } else {
        normals.add(defender);
      }
    }

    final totalLearners = move.learn.length + move.learnDetails.length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16181F) : const Color(0xFFF7F8FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              children: [
                Center(
                  child: Text(
                    'MOVE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    PokemonHelpers.formatName(move.name),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _TypePill(type: move.type, color: typeColor),
                    _SolidClsPill(cls: move.cls, color: clsColor),
                  ],
                ),
                const SizedBox(height: 16),

                // Card 1: Stats (2x2 Grid with Power, Accuracy, PP, Priority)
                _buildSectionCard(
                  context: context,
                  isDark: isDark,
                  title: 'Stats',
                  icon: LucideIcons.chartColumnBig,
                  accentColor: typeColor,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStatBox(
                            context: context,
                            isDark: isDark,
                            label: 'Power',
                            value: move.power != null && move.power! > 0
                                ? '${move.power}'
                                : '—',
                            subtitle: move.power != null && move.power! > 0
                                ? 'Base Damage'
                                : 'Status Move',
                            icon: LucideIcons.zap,
                            accentColor: typeColor,
                          ),
                          const SizedBox(width: 10),
                          _buildStatBox(
                            context: context,
                            isDark: isDark,
                            label: 'Accuracy',
                            value: move.acc != null
                                ? '${move.acc}%'
                                : (move.cls.toLowerCase() == 'status'
                                    ? '—'
                                    : '∞'),
                            subtitle: move.acc != null
                                ? 'Hit Rate'
                                : (move.cls.toLowerCase() == 'status'
                                    ? 'Self / Field'
                                    : 'Never Misses'),
                            icon: LucideIcons.target,
                            accentColor: const Color(0xFF26A69A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStatBox(
                            context: context,
                            isDark: isDark,
                            label: 'PP',
                            value: move.pp != null ? '${move.pp}' : '—',
                            subtitle: move.pp != null
                                ? 'Max ${(move.pp! * 1.6).floor()}'
                                : 'Power Points',
                            icon: LucideIcons.repeat,
                            accentColor: const Color(0xFF5C6BC0),
                          ),
                          const SizedBox(width: 10),
                          _buildStatBox(
                            context: context,
                            isDark: isDark,
                            label: 'Priority',
                            value: move.pri > 0
                                ? '+${move.pri}'
                                : (move.pri < 0 ? '${move.pri}' : '0'),
                            subtitle: move.pri > 0
                                ? 'Fast Move'
                                : (move.pri < 0 ? 'Slow Move' : 'Standard (0)'),
                            icon: LucideIcons.clock,
                            accentColor: move.pri > 0
                                ? const Color(0xFF43A047)
                                : (move.pri < 0
                                    ? const Color(0xFFE53935)
                                    : Colors.blueGrey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Card 2: Details
                _buildSectionCard(
                  context: context,
                  isDark: isDark,
                  title: 'Details',
                  icon: LucideIcons.fileText,
                  accentColor: typeColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (move.flavor != null) ...[
                        Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          move.flavor!,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                      if (move.eff != null && move.eff!.isNotEmpty) ...[
                        if (move.flavor != null) const SizedBox(height: 14),
                        Text(
                          'IN-DEPTH EFFECT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          move.eff!,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                      if (move.contest != null && move.contest!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              'CONTEST CATEGORY:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                PokemonHelpers.formatName(move.contest!),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (move.flavor == null && move.eff == null && move.contest == null)
                        Text(
                          'No details available.',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                    ],
                  ),
                ),

                // Card 3: Damage Dealt with Generous Spacing Between Sections
                _buildSectionCard(
                  context: context,
                  isDark: isDark,
                  title: 'Damage Dealt',
                  icon: LucideIcons.swords,
                  accentColor: typeColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDamageGroup(
                        context: context,
                        isDark: isDark,
                        heading: 'Super effective against',
                        badge: '2x damage',
                        badgeColor: const Color(0xFF43A047),
                        types: supers,
                      ),
                      _buildDamageGroup(
                        context: context,
                        isDark: isDark,
                        heading: 'Weak against',
                        badge: '1/2x damage',
                        badgeColor: const Color(0xFFFB8C00),
                        types: weaks,
                      ),
                      _buildDamageGroup(
                        context: context,
                        isDark: isDark,
                        heading: 'No effect against',
                        badge: '0x damage',
                        badgeColor: Colors.grey,
                        types: noEffects,
                      ),
                      _buildDamageGroup(
                        context: context,
                        isDark: isDark,
                        heading: 'Normal damage to',
                        badge: '1x damage',
                        badgeColor: Colors.blueGrey,
                        types: normals,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: GestureDetector(
                onTap: totalLearners == 0
                    ? null
                    : () => _openLearnersInPokedex(context, ref),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: totalLearners == 0
                        ? LinearGradient(colors: [Colors.grey.shade600, Colors.grey.shade500])
                        : LinearGradient(colors: [typeColor, typeColor.withValues(alpha: 0.82)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: totalLearners == 0
                        ? null
                        : [
                            BoxShadow(
                              color: typeColor.withValues(alpha: 0.32),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.catching_pokemon,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalLearners == 0
                            ? 'NO POKÉMON LEARN THIS MOVE'
                            : 'POKÉMON LIST',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageGroup({
    required BuildContext context,
    required bool isDark,
    required String heading,
    required String badge,
    required Color badgeColor,
    required List<String> types,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  heading,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${types.length}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white60 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (types.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'None',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in types)
                  _TypePill(
                    type: t,
                    color: AppColors.getTypeColor(t),
                    compact: true,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String type;
  final Color color;
  final bool compact;

  const _TypePill({
    required this.type,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/types/${type.toLowerCase()}.svg',
            width: compact ? 16 : 18,
            height: compact ? 16 : 18,
          ),
          const SizedBox(width: 6),
          Text(
            type.isNotEmpty
                ? type[0].toUpperCase() + type.substring(1).toLowerCase()
                : '',
            style: TextStyle(
              color: color,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolidClsPill extends StatelessWidget {
  final String cls;
  final Color color;

  const _SolidClsPill({required this.cls, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        _clsLabel(cls),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
