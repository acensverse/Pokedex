import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../pokedex/pokedex_provider.dart';
import '../pokedex/widgets/tools_sheet.dart';
import '../../core/providers.dart';
import '../../core/services/champions_data_service.dart';

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


/// All moves baked from assets/moves_seed.json (offline-first).
final movesSeedProvider = FutureProvider<List<MoveEntry>>((ref) async {
  final isChampions = ref.watch(isChampionsModeProvider);
  if (isChampions) {
    return ref.watch(championsDataServiceProvider).getMoves();
  }
  final raw = await rootBundle.loadString('assets/moves_seed.json');
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

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Moves'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 26,
              color: _isSearching ? AppColors.primary : Colors.black54,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: Icon(
              Icons.tune,
              size: 26,
              color: _typeFilter != null || _clsFilter != null
                  ? AppColors.primary
                  : Colors.black54,
            ),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      body: movesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('Could not load moves'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(movesSeedProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (moves) {
          final q = _query.toLowerCase();
          final filtered = moves.where((m) {
            final matchesQuery = q.isEmpty || m.name.replaceAll('-', ' ').contains(q);
            final matchesType =
                _typeFilter == null || m.type == _typeFilter;
            final matchesCls = _clsFilter == null || m.cls == _clsFilter;
            return matchesQuery && matchesType && matchesCls;
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // A-Z
          return Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Search moves...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(LucideIcons.search,
                                color: Colors.black54),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    icon: const Icon(Icons.close,
                                        color: Colors.black54, size: 20),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                            'No moves match your search or filters',
                            style: TextStyle(color: Colors.grey.shade500)))
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _MoveCard(
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: AppSpacing.lg),
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
            SvgPicture.asset('assets/types/$type.svg', width: 24, height: 24),
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
          color: clsColor.withValues(alpha: isSelected ? 0.22 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: clsColor,
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_martial_arts, size: 18, color: clsColor),
            const SizedBox(width: 4),
            Text(
              _clsLabel(cls),
              style: TextStyle(
                color: clsColor,
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

class _MoveCard extends StatelessWidget {
  final MoveEntry move;
  final VoidCallback onTap;

  const _MoveCard({required this.move, required this.onTap});

  @override
  Widget build(BuildContext context) {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PokemonHelpers.formatName(move.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
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
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

  static const _accent = Color(0xFF43A047);
  static const _sheetBg = Color(0xFFF1F4F8);

  void _openLearnersInPokedex(BuildContext context, WidgetRef ref) {
    if (move.learn.isEmpty) return;
    ref.read(toolLearnerFilterProvider.notifier).state = (
      kind: 'Move',
      name: PokemonHelpers.formatName(move.name),
      ids: move.learn.toSet(),
    );
    Navigator.of(context).pop(); // close the sheet
    // push (not go) so system-back from the filtered home returns here.
    GoRouter.of(context).push('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Container(
      decoration: const BoxDecoration(
        color: _sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                const SizedBox(height: 4),
                const Center(
                  child: Text('MOVE',
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    PokemonHelpers.formatName(move.name),
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _TypePill(type: move.type, color: typeColor),
                    _SolidClsPill(cls: move.cls, color: clsColor),
                  ],
                ),
                const SizedBox(height: 26),
                _sectionCard(
                  'Stats',
                  Row(
                    children: [
                      _StatColumn(
                          label: 'Power',
                          value: move.power?.toString() ?? '\u2014'),
                      _verticalDivider(),
                      _StatColumn(
                          label: 'Accuracy',
                          value: move.acc != null ? '${move.acc}' : '\u2014'),
                      _verticalDivider(),
                      _StatColumn(
                          label: 'PP',
                          value: move.pp?.toString() ?? '\u2014'),
                      _verticalDivider(),
                      _StatColumn(
                          label: 'Priority',
                          value: move.pri > 0
                              ? '+${move.pri}'
                              : '${move.pri}'),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _sectionCard(
                  'Details',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (move.flavor != null) ...[
                        const _CardHeading('Description'),
                        const SizedBox(height: 6),
                        Text(move.flavor!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade700)),
                      ],
                      if (move.eff != null) ...[
                        const SizedBox(height: 14),
                        const _CardHeading('Effect'),
                        const SizedBox(height: 6),
                        Text(move.eff!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade700)),
                      ],
                      if (move.contest != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const _CardHeading('Contest:'),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                move.contest![0].toUpperCase() +
                                    move.contest!.substring(1),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (move.flavor == null &&
                          move.eff == null &&
                          move.contest == null)
                        Text('No details available.',
                            style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _sectionCard(
                  'Damage dealt',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DamageGroup(
                        heading: 'Super effective against:',
                        subtitle: '2x damage',
                        types: supers,
                      ),
                      _DamageGroup(
                        heading: 'Weak against:',
                        subtitle: '1/2x damage',
                        types: weaks,
                      ),
                      _DamageGroup(
                        heading: 'No effect against:',
                        subtitle: '0x damage',
                        types: noEffects,
                      ),
                      _DamageGroup(
                        heading: 'Normal damage to:',
                        subtitle: '1x damage',
                        types: normals,
                      ),
                    ],
                  ),
                 ),
                 const SizedBox(height: 8),
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
             child: SizedBox(
               width: double.infinity,
               height: 52,
               child: GestureDetector(
                 onTap: move.learn.isEmpty
                     ? null
                     : () => _openLearnersInPokedex(context, ref),
                 child: Container(
                   decoration: BoxDecoration(
                     gradient: move.learn.isEmpty
                         ? const LinearGradient(
                             colors: [Colors.grey, Colors.grey])
                         : const LinearGradient(
                             colors: [Color(0xFF7CB342), Color(0xFF26A69A)],
                           ),
                     borderRadius: BorderRadius.circular(16),
                   ),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(
                         Icons.catching_pokemon,
                         color: Colors.white,
                       ),
                       const SizedBox(width: 8),
                       Text(
                         move.learn.isEmpty
                             ? 'NO POK\u00c9MON LEARN THIS MOVE'
                             : 'POK\u00c9MON LIST',
                         style: const TextStyle(
                             color: Colors.white,
                             fontWeight: FontWeight.w900,
                             letterSpacing: 1.2,
                             fontSize: 15),
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

  Widget _verticalDivider() =>
      Container(width: 1, height: 36, color: Colors.grey.shade300);

  Widget _sectionCard(String title, Widget child) => Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 14),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: child,
          ),
          Positioned(
            top: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent, width: 1.5),
              ),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _accent)),
            ),
          ),
        ],
      );
}

class _CardHeading extends StatelessWidget {
  final String text;

  const _CardHeading(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary));
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ],
        ),
      );
}

class _DamageGroup extends StatelessWidget {
  final String heading;
  final String subtitle;
  final List<String> types;

  const _DamageGroup({
    required this.heading,
    required this.subtitle,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in types)
                _TypePill(
                    type: t,
                    color: AppColors.getTypeColor(t),
                    compact: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Type pill in the app's standard style: natural colored type icon on a
/// tinted background with matching colored label.
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
          horizontal: compact ? 12 : 16, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/types/$type.svg',
            width: compact ? 16 : 18,
            height: compact ? 16 : 18,
          ),
          const SizedBox(width: 6),
          Text(
            type[0].toUpperCase() + type.substring(1),
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w700),
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
    final icon = switch (cls) {
      'physical' => Icons.fitness_center,
      'special' => Icons.auto_awesome,
      _ => Icons.adjust,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(_clsLabel(cls),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
