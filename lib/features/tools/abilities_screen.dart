import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/champions.dart';
import '../../core/remote_data.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../pokedex/pokedex_provider.dart';
import '../pokedex/widgets/tools_sheet.dart';
import 'widgets/tool_widgets.dart';
import '../../core/widgets/app_search_bar.dart';

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

/// All abilities baked from assets/abilities_seed.json (offline-first),
/// with runtime overrides supported when Champions data is updated.
final abilitiesSeedProvider = FutureProvider<List<AbilityEntry>>((ref) async {
  ref.watch(remoteDataVersionProvider);
  final store = ref.read(remoteDataStoreProvider);
  final override = await store.read(kRemoteAbilitiesFile);
  final raw = override ?? await rootBundle.loadString(kAbilitiesAssetPath);
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
      builder: (_) => AbilityDetailSheet(ability: ability),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Abilities'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 26,
              color: _isSearching
                  ? (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00897B))
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: Icon(
              Icons.tune,
              size: 26,
              color: _genFilter != null
                  ? (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00897B))
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
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
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 12),
              Text('Could not load abilities'),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(abilitiesSeedProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (abilities) {
          final q = _query.toLowerCase().replaceAll('-', ' ');
          final championsMode = ref.watch(championsModeProvider);
          final championIds =
              ref.watch(championsDataProvider).value?.pokemonIds;
          final filtered = abilities.where((a) {
            final matchesQuery = q.isEmpty || a.name.replaceAll('-', ' ').contains(q);
            final matchesGen = _genFilter == null || a.gen == _genFilter;
            // Champions mode: keep only abilities a roster Pokemon has.
            // `pokemon` includes form ids, so compare against the roster's
            // seed row ids directly.
            final matchesChampions = !championsMode ||
                (championIds != null && a.pokemon.any(championIds.contains));
            return matchesQuery && matchesGen && matchesChampions;
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // A-Z
          return Column(
            children: [
              if (championsMode)
                const ChampionsModeBanner(
                  message:
                      'Champions Pok\u00e9dex \u2014 only abilities a roster Pok\u00e9mon has',
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Search abilities...',
                          autofocus: true,
                          voiceTitle: 'Abilities Voice Search',
                          voiceHint: 'Say an ability name...',
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
                          'No abilities found',
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          16 + MediaQuery.paddingOf(context).bottom,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final ability = filtered[index];
                          return _AbilityCard(
                            ability: ability,
                            onTap: () => _openDetail(ability),
                          );
                        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Open details for ${PokemonHelpers.formatName(ability.name)}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PokemonHelpers.formatName(ability.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (ability.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  ability.description!,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
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

  void _openHoldersInPokedex(BuildContext context, WidgetRef ref) {
    if (ability.pokemon.isEmpty) return;
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(debouncedSearchQueryProvider.notifier).state = '';
    ref.read(selectedTypesProvider.notifier).state = [];
    ref.read(genFilterProvider.notifier).state = 0;
    ref.read(favoritesOnlyProvider.notifier).state = false;
    ref.read(toolLearnerFilterProvider.notifier).state = null;

    final allSet = ability.pokemon.toSet();
    final hiddenSet = ability.hidden.toSet();
    final normalSet = allSet.difference(hiddenSet);

    ref.read(toolAbilityFilterProvider.notifier).state = (
      name: PokemonHelpers.formatName(ability.name),
      mode: 'all',
      allIds: allSet,
      normalIds: normalSet,
      hiddenIds: hiddenSet,
      flavor: ability.flavor ?? '',
      eff: ability.eff ?? '',
    );
    Navigator.of(context).pop(); // close the sheet
    // push (not go) so system-back from the filtered home returns here.
    FocusManager.instance.primaryFocus?.unfocus();
    GoRouter.of(context).push('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00897B);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16181F) : const Color(0xFFF7F8FA),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'ABILITY',
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
                        PokemonHelpers.formatName(ability.name),
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
                        if (ability.gen.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isDark ? Colors.white12 : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              _genLabel(ability.gen),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.users, size: 13, color: accentColor),
                              const SizedBox(width: 6),
                              Text(
                                '${ability.pokemon.length} Pokémon',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      context: context,
                      isDark: isDark,
                      title: 'Details',
                      icon: LucideIcons.sparkles,
                      accentColor: accentColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ability.flavor != null) ...[
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
                              ability.flavor!,
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.45,
                                color:
                                    Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                          if (ability.eff != null &&
                              ability.eff!.isNotEmpty &&
                              ability.eff != ability.flavor) ...[
                            if (ability.flavor != null)
                              const SizedBox(height: 14),
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
                              ability.eff!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color:
                                    Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                          if (ability.hidden.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(
                                  alpha: isDark ? 0.12 : 0.08,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.amber.withValues(alpha: 0.28),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.sparkles,
                                    size: 16,
                                    color: isDark
                                        ? Colors.amber.shade300
                                        : Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${ability.hidden.length} Pokémon have this as their Hidden Ability.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Colors.amber.shade200
                                            : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (ability.flavor == null && ability.eff == null)
                            Text(
                              'No details available.',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color:
                                    Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
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
                          ? LinearGradient(
                              colors: [
                                Colors.grey.shade600,
                                Colors.grey.shade500,
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Color(0xFF00897B),
                                Color(0xFF26A69A),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: ability.pokemon.isEmpty
                          ? null
                          : [
                              BoxShadow(
                                color: const Color(
                                  0xFF00897B,
                                ).withValues(alpha: 0.32),
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
                          ability.pokemon.isEmpty
                              ? 'NO POKÉMON HAVE THIS ABILITY'
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
                            ? const Color(0xFF00897B).withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected == gen
                              ? const Color(0xFF00897B)
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
                                ? const Color(0xFF00897B)
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
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
