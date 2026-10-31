import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/champions.dart';
import '../../core/speed_tiers.dart';
import '../../core/utils/name_forms.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../models/pokemon.dart';
import '../pokedex/pokedex_provider.dart';
import '../pokedex/widgets/tools_sheet.dart';
import 'widgets/tool_widgets.dart';
import 'widgets/type_picker_sheet.dart';
import '../../core/widgets/app_search_bar.dart';

/// Champions Speed Tiers: every Pokemon on the Champions roster ranked by
/// Level-50 speed, with the common build and battle modifiers from
/// pokemon-zone.com/champions/speed-tiers (baked into assets/speed_tiers.json).
/// The roster comes from assets/champions_seed.json, so the list always
/// matches what the Champions mode shows.
class SpeedTiersScreen extends ConsumerStatefulWidget {
  const SpeedTiersScreen({super.key});

  @override
  ConsumerState<SpeedTiersScreen> createState() => _SpeedTiersScreenState();
}

class _SpeedTiersScreenState extends ConsumerState<SpeedTiersScreen> {
  /// Seed row ids whose modifier panel is expanded.
  final Set<int> _expanded = {};

  String _query = '';
  bool _isSearching = false;
  String? _typeFilter;
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

  Future<void> _openTypeFilter() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TypePickerSheet(
        title: 'Filter by type',
        selectedType: _typeFilter,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _typeFilter = picked.isEmpty ? null : picked);
  }

  static int _speedOf(Pokemon pokemon) {
    for (final slot in pokemon.stats) {
      if (slot.stat.name == 'speed') return slot.baseStat;
    }
    return 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pokedexState = ref.watch(pokedexProvider);
    final champions = ref.watch(championsDataProvider);
    final tiers = ref.watch(speedTiersDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Speed Tiers'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 26,
              color: _isSearching
                  ? (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00796B))
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: Icon(
              Icons.tune,
              size: 26,
              color: _typeFilter != null
                  ? (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00796B))
                  : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _openTypeFilter,
          ),
        ],
      ),
      body: champions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('Could not load the Champions roster'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(championsDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (championsData) => tiers.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 12),
                const Text('Could not load the speed tiers'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(speedTiersDataProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (tiersData) {
            if (pokedexState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Roster Pokemon joined with their tier row; roster ids missing
            // from the asset fall back to the (build-verified) formulas.
            final entries =
                pokedexState.pokemonList
                    .where((p) => championsData.pokemonIds.contains(p.id))
                    .map(
                      (p) => (
                        pokemon: p,
                        tier:
                            tiersData.byId[p.id] ??
                            computedTier(p.id, p.name, _speedOf(p)),
                      ),
                    )
                    .toList()
                  ..sort((a, b) {
                    final bySpeed = b.tier.base.compareTo(a.tier.base);
                    return bySpeed != 0
                        ? bySpeed
                        : PokemonHelpers.formatName(
                          a.pokemon.name,
                        ).compareTo(PokemonHelpers.formatName(b.pokemon.name));
                  });

            if (entries.isEmpty) {
              return Center(
                child: Text(
                  'No Champions roster Pokemon found',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              );
            }

            // Competition ranking by base speed (ties share a rank, like the
            // upstream table: 1, 1, 1, 4, ...). Ranks are computed over the
            // full roster so a filtered view keeps each Pokemon's real
            // standing.
            var lastBase = -1;
            var lastRank = 0;
            final ranks = <int>[];
            for (var i = 0; i < entries.length; i++) {
              if (entries[i].tier.base != lastBase) {
                lastBase = entries[i].tier.base;
                lastRank = i + 1;
              }
              ranks.add(lastRank);
            }

            // Search filter on the normalized display name (accent- and
            // punctuation-insensitive, like NameForms matching).
            final q = NameForms.normalizeKey(_query);
            final visible = <({Pokemon pokemon, SpeedTier tier, int rank})>[];
            for (var i = 0; i < entries.length; i++) {
              final pokemon = entries[i].pokemon;
              if (q.isNotEmpty &&
                  !NameForms.normalizeKey(
                    PokemonHelpers.formatName(pokemon.name),
                  ).contains(q)) {
                continue;
              }
              if (_typeFilter != null &&
                  !pokemon.types
                      .any((slot) => slot.type.name == _typeFilter)) {
                continue;
              }
              visible.add(
                (pokemon: pokemon, tier: entries[i].tier, rank: ranks[i]),
              );
            }

            return Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _isSearching
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: AppSearchBar(
                              controller: _searchController,
                              hintText: 'Search Pokémon speed...',
                              autofocus: true,
                              voiceTitle: 'Speed Tiers Voice Search',
                              voiceHint: 'Say a Pokémon name...',
                              onChanged: (v) => setState(() => _query = v),
                              onClear: _clearSearch,
                            ),
                          )
                      : const SizedBox.shrink(),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            'No Pok\u00e9mon match your search or filters',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            16 + MediaQuery.paddingOf(context).bottom,
                          ),
                          itemCount: visible.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) return const _TiersLegend();
                            final entry = visible[index - 1];
                            final pokemonId = entry.pokemon.id;
                            return _TierCard(
                              rank: entry.rank,
                              pokemon: entry.pokemon,
                              tier: entry.tier,
                              expanded: _expanded.contains(pokemonId),
                              onToggle: () => setState(() {
                                _expanded.contains(pokemonId)
                                    ? _expanded.remove(pokemonId)
                                    : _expanded.add(pokemonId);
                              }),
                              onOpenDetails: () =>
                                  context.push('/pokemon/$pokemonId'),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One-line explainer above the list.
class _TiersLegend extends StatelessWidget {
  const _TiersLegend();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const teal = Color(0xFF00897B);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: teal.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: teal.withValues(alpha: 0.3)),
      ),
      child: Text(
        'Level 50 speed with max IVs. Base = base stat, '
        'Max = full investment, + = helpful nature. '
        'Tap the arrow for battle modifiers.',
        style: TextStyle(
          fontSize: 12,
          height: 1.35,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  final int rank;
  final Pokemon pokemon;
  final SpeedTier tier;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOpenDetails;

  const _TierCard({
    required this.rank,
    required this.pokemon,
    required this.tier,
    required this.expanded,
    required this.onToggle,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: 'Open details for ${PokemonHelpers.formatName(pokemon.name)}',
      child: GestureDetector(
        onTap: onOpenDetails,
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
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 34,
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      PokemonHelpers.getHomeAssetPath(pokemon.id),
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      cacheWidth: PokemonHelpers.cacheWidth(context, 44),
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.catching_pokemon,
                        size: 28,
                        color: Theme.of(context)
                            .iconTheme
                            .color
                            ?.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PokemonHelpers.formatName(pokemon.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final slot in pokemon.types)
                              TypePill(slot.type.name, fontSize: 10),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF00897B,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00897B),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      '${tier.base}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00897B),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Semantics(
                      button: true,
                      label:
                          '${expanded ? 'Hide' : 'Show'} battle modifiers for '
                          '${PokemonHelpers.formatName(pokemon.name)}',
                      child: GestureDetector(
                        onTap: onToggle,
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 36,
                          height: 44,
                          child: Center(
                            child: Icon(
                              Icons.expand_more,
                              size: 22,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ModifierChip(label: 'No Invest', value: tier.noInvest),
                      _ModifierChip(label: 'Max+', value: tier.maxPlus),
                      _ModifierChip(label: 'Max', value: tier.max),
                      _ModifierChip(label: 'Min', value: tier.min),
                      _ModifierChip(label: 'Scarf +1', value: tier.scarf),
                      _ModifierChip(label: 'Tailwind +2', value: tier.tailwind),
                      _ModifierChip(
                        label: 'Paralyzed',
                        value: tier.paralyzed,
                      ),
                    ],
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

/// One computed speed value in the expanded panel.
class _ModifierChip extends StatelessWidget {
  final String label;
  final int value;

  const _ModifierChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
