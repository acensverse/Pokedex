import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../pokedex/pokedex_provider.dart';
import '../pokedex/widgets/tools_sheet.dart';

class AbilityEntry {
  final int id;
  final String name;
  final String gen;
  final String? eff;
  final String? flavor;

  /// IDs (base + forms) of Pokemon that have this ability.
  final List<int> pokemon;

  /// Subset of [pokemon] that only have it as a hidden ability.
  final List<int> hidden;

  const AbilityEntry({
    required this.id,
    required this.name,
    required this.gen,
    required this.eff,
    required this.flavor,
    required this.pokemon,
    required this.hidden,
  });

  factory AbilityEntry.fromJson(Map<String, dynamic> json) => AbilityEntry(
        id: json['id'] as int,
        name: json['name'] as String,
        gen: (json['gen'] as String?) ?? '',
        eff: json['eff'] as String?,
        flavor: json['flavor'] as String?,
        pokemon: (json['pokemon'] as List<dynamic>? ?? const [])
            .map((e) => e as int)
            .toList(),
        hidden: (json['hidden'] as List<dynamic>? ?? const [])
            .map((e) => e as int)
            .toList(),
      );
  String? get description => eff ?? flavor;
}

/// All abilities baked from assets/abilities_seed.json (offline-first).
final abilitiesSeedProvider = FutureProvider<List<AbilityEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/abilities_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => AbilityEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

String _genLabel(String gen) {
  if (gen.isEmpty) return '';
  return 'Gen ${gen.toUpperCase()}';
}

class AbilitiesScreen extends ConsumerStatefulWidget {
  const AbilitiesScreen({super.key});

  @override
  ConsumerState<AbilitiesScreen> createState() => _AbilitiesScreenState();
}

class _AbilitiesScreenState extends ConsumerState<AbilitiesScreen> {
  String _query = '';
  bool _isSearching = false;
  String? _genFilter;
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

  void _openFilterSheet(List<String> gens) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GenFilterSheet(
        gens: gens,
        selected: _genFilter,
        onSelected: (g) => setState(() => _genFilter = g),
      ),
    );
  }

  void _openDetail(AbilityEntry ability) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,
        child: AbilityDetailSheet(ability: ability),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final abilitiesAsync = ref.watch(abilitiesSeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Abilities'),
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
              color: _genFilter != null ? AppColors.primary : Colors.black54,
            ),
            onPressed: () {
              final abilities =
                  ref.read(abilitiesSeedProvider).value ?? const [];
              final gens =
                  abilities.map((a) => a.gen).where((g) => g.isNotEmpty).toSet().toList()
                    ..sort();
              _openFilterSheet(gens);
            },
          ),
        ],
      ),
      body: abilitiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('Could not load abilities'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(abilitiesSeedProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (abilities) {
          final q = _query.toLowerCase().replaceAll('-', ' ');
          final filtered = abilities.where((a) {
            final matchesQuery = q.isEmpty || a.name.replaceAll('-', ' ').contains(q);
            final matchesGen = _genFilter == null || a.gen == _genFilter;
            return matchesQuery && matchesGen;
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
                            hintText: 'Search abilities...',
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
                            'No abilities match your search or filters',
                            style: TextStyle(color: Colors.grey.shade500)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) => _AbilityCard(
                          ability: filtered[index],
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

class _AbilityCard extends StatelessWidget {
  final AbilityEntry ability;
  final VoidCallback onTap;

  const _AbilityCard({required this.ability, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open details for ${PokemonHelpers.formatName(ability.name)}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.diamond,
                    size: 24, color: Color(0xFF8E24AA)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PokemonHelpers.formatName(ability.name),
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
                        if (ability.gen.isNotEmpty) _genLabel(ability.gen),
                        '${ability.pokemon.length} Pok\u00e9mon',
                      ].join('  \u00b7  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (ability.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        ability.description!,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ability detail bottom sheet — same layout as the move sheet: centered
/// header, section pills, and a gradient POKEMON LIST button that jumps to
/// the home Pokedex filtered to Pokemon with this ability.
class AbilityDetailSheet extends ConsumerWidget {
  final AbilityEntry ability;

  const AbilityDetailSheet({super.key, required this.ability});

  static const _accent = Color(0xFF43A047);
  static const _sheetBg = Color(0xFFF1F4F8);

  void _openHoldersInPokedex(BuildContext context, WidgetRef ref) {
    if (ability.pokemon.isEmpty) return;
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(debouncedSearchQueryProvider.notifier).state = '';
    ref.read(selectedTypesProvider.notifier).state = [];
    ref.read(genFilterProvider.notifier).state = 0;
    ref.read(favoritesOnlyProvider.notifier).state = false;
    ref.read(toolAbilityFilterProvider.notifier).state = null;

    ref.read(toolLearnerFilterProvider.notifier).state = (
      kind: 'Ability',
      name: PokemonHelpers.formatName(ability.name),
      ids: ability.pokemon.toSet(),
    );
    Navigator.of(context).pop(); // close the sheet
    // push (not go) so system-back from the filtered home returns here.
    FocusManager.instance.primaryFocus?.unfocus();
    GoRouter.of(context).push('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  child: Text('ABILITY',
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    PokemonHelpers.formatName(ability.name),
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
                    if (ability.gen.isNotEmpty)
                      _InfoPill(label: _genLabel(ability.gen)),
                    _InfoPill(
                        label: '${ability.pokemon.length} Pok\u00e9mon'),
                  ],
                ),
                const SizedBox(height: 26),
                _sectionCard(
                  'Details',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (ability.flavor != null) ...[
                        const _CardHeading('Description'),
                        const SizedBox(height: 6),
                        Text(ability.flavor!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade700)),
                      ],
                      if (ability.eff != null) ...[
                        const SizedBox(height: 14),
                        const _CardHeading('Effect'),
                        const SizedBox(height: 6),
                        Text(ability.eff!,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade700)),
                      ],
                      if (ability.hidden.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        const _CardHeading('Hidden by'),
                        const SizedBox(height: 6),
                        Text(
                            '${ability.hidden.length} Pok\u00e9mon have this as their hidden ability.',
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.grey.shade700)),
                      ],
                      if (ability.flavor == null && ability.eff == null)
                        Text('No details available.',
                            style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade500)),
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
                onTap: ability.pokemon.isEmpty
                    ? null
                    : () => _openHoldersInPokedex(context, ref),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: ability.pokemon.isEmpty
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
                        ability.pokemon.isEmpty
                            ? 'NO POK\u00c9MON HAVE THIS ABILITY'
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
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _accent)),
            ),
          ),
        ],
      );
}

class _InfoPill extends StatelessWidget {
  final String label;

  const _InfoPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8E24AA),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
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

/// Generation filter bottom sheet: 3-column grid of gen pills, same style
/// as the Items category filter.
class _GenFilterSheet extends StatelessWidget {
  final List<String> gens;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _GenFilterSheet({
    required this.gens,
    required this.selected,
    required this.onSelected,
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
                for (final gen in gens)
                  GestureDetector(
                    onTap: () {
                      onSelected(selected == gen ? null : gen);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected == gen
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected == gen
                              ? AppColors.primary
                              : Colors.grey.shade400,
                          width: selected == gen ? 3 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Gen ${gen.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: selected == gen
                                ? AppColors.primary
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
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
