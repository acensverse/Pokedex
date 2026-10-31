import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../../models/pokemon.dart';
import 'services/team_customization_service.dart';
import 'widgets/team_member_editor_sheet.dart';
import 'widgets/tool_widgets.dart';

/// One move from the baked seed: its type plus the IDs of Pokemon that can
/// learn it (base + forms). Powers the offline move-coverage calculation.
class _SeedMove {
  final String type;
  final List<int> learn;

  const _SeedMove(this.type, this.learn);
}

final _movesSeedProvider = FutureProvider<List<_SeedMove>>((ref) async {
  final raw = await rootBundle.loadString('assets/moves_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return [
    for (final e in list.cast<Map>())
      _SeedMove(
        e['type'] as String,
        (e['learn'] as List<dynamic>? ?? const [])
            .map((e) => e as int)
            .toList(),
      ),
  ];
});

/// Pure Defense Index math (unit-tested): the party's average resistance to
/// [attacker], where each member contributes (1 - multiplier).
/// Positive = resistant, negative = weak, 0 = balanced.
/// Multipliers are 0/0.25/0.5/1/2/4 (dyadic), so sums are float-exact.
double teamDefenseIndex(List<List<String>> memberTypeLists, String attacker) {
  if (memberTypeLists.isEmpty) return 0;
  var di = 0.0;
  for (final types in memberTypeLists) {
    final mult = TypeChart.getEffectiveness(types)[attacker] ?? 1.0;
    di += 1 - mult;
  }
  return di / memberTypeLists.length;
}

class TeamDetailScreen extends ConsumerStatefulWidget {
  final int teamId;

  const TeamDetailScreen({super.key, required this.teamId});

  @override
  ConsumerState<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends ConsumerState<TeamDetailScreen> {
  bool _showDefenseIndex = false;
  bool _showSemCounts = false;
  Map<int, MemberCustomization> _customizations = {};

  @override
  void initState() {
    super.initState();
    _loadCustomizations();
  }

  Future<void> _loadCustomizations() async {
    final map = await TeamCustomizationService.loadTeamCustomizations(widget.teamId);
    if (mounted) {
      setState(() {
        _customizations = map;
      });
    }
  }

  int _statValue(Pokemon p, String key, int slotIndex) {
    final custom = _customizations[slotIndex];
    if (custom != null && custom.customStats.containsKey(key)) {
      return custom.customStats[key]!;
    }
    for (final s in p.stats) {
      if (s.stat.name == key) return s.baseStat;
    }
    return 0;
  }

  Future<void> _editMember(int slotIndex, Pokemon pokemon) async {
    AppFeedback.lightImpact();
    final updated = await TeamMemberEditorSheet.show(
      context,
      pokemon: pokemon,
      initialCustomization: _customizations[slotIndex],
      onSave: (custom) async {
        setState(() {
          _customizations[slotIndex] = custom;
        });
        await TeamCustomizationService.saveMemberCustomization(
          widget.teamId,
          slotIndex,
          custom,
        );
      },
    );

    if (updated != null && mounted) {
      setState(() {
        _customizations[slotIndex] = updated;
      });
      await TeamCustomizationService.saveMemberCustomization(
        widget.teamId,
        slotIndex,
        updated,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamFuture = ref.watch(databaseProvider).getTeamById(widget.teamId);
    final membersAsync = ref.watch(localPokemonListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => context.pop(),
        ),
        title: FutureBuilder(
          future: teamFuture,
          builder: (context, snapshot) => Text(
            snapshot.data?.name ?? 'Team Details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 18),
            tooltip: 'Edit Roster',
            onPressed: () async {
              AppFeedback.selectionClick();
              await context.push('/tools/teams/new?id=${widget.teamId}');
              await _loadCustomizations();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder(
        future: teamFuture,
        builder: (context, teamSnapshot) {
          final team = teamSnapshot.data;
          if (team == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final slotIds = [
            team.slot1,
            team.slot2,
            team.slot3,
            team.slot4,
            team.slot5,
            team.slot6,
          ].whereType<int>().toList();

          return membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load dex:\n$e')),
            data: (dex) {
              final byId = {for (final p in dex) p.id: p};
              final members = [
                for (final id in slotIds)
                  if (byId[id] != null) byId[id]!,
              ];

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  // Party Members Overview Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Party Members (${members.length}/6)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Tap "Edit Stats" on any Pokémon',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Members Cards with Editable Stats
                  for (var i = 0; i < members.length; i++)
                    _buildMemberDetailCard(i, members[i], isDark),

                  if (members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              LucideIcons.users,
                              size: 48,
                              color: Theme.of(context).dividerColor,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Empty party\nTap edit above to add Pokémon to this team.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Team Stats & Averages',
                      icon: LucideIcons.barChart3,
                      isDark: isDark,
                      child: _teamStatsBody(members, isDark),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: 'Defensive Coverage',
                      icon: LucideIcons.shieldCheck,
                      isDark: isDark,
                      child: _defenseBody(members),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionCard(
                      title: 'Move Type Coverage',
                      icon: LucideIcons.swords,
                      isDark: isDark,
                      child: _moveCoverageBody(members, isDark),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMemberDetailCard(int slotIndex, Pokemon pokemon, bool isDark) {
    final custom = _customizations[slotIndex];
    final primaryType = pokemon.types.isNotEmpty
        ? pokemon.types.first.type.name
        : 'normal';
    final typeColor = AppColors.getTypeColor(primaryType);

    final displayName = custom?.nickname != null && custom!.nickname!.isNotEmpty
        ? '${custom.nickname} (${PokemonHelpers.formatName(pokemon.name)})'
        : PokemonHelpers.formatName(pokemon.name);

    final level = custom?.level ?? 50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              // 3D Artwork
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Image.asset(
                  PokemonHelpers.getHomeAssetPath(pokemon.id),
                  fit: BoxFit.contain,
                  cacheWidth: PokemonHelpers.cacheWidth(context, 62),
                  errorBuilder: (_, _, _) => Image.asset(
                    PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                    fit: BoxFit.contain,
                    cacheWidth: PokemonHelpers.cacheWidth(context, 52),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final t in pokemon.types)
                          TypePill(t.type.name, fontSize: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Lv. $level',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              // "Edit Stats" Button
              ElevatedButton.icon(
                onPressed: () => _editMember(slotIndex, pokemon),
                icon: const Icon(LucideIcons.pencil, size: 13),
                label: const Text('Edit Stats', style: TextStyle(fontSize: 11.5)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: typeColor.withValues(alpha: isDark ? 0.3 : 0.15),
                  foregroundColor: isDark ? Colors.white : typeColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: typeColor.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (custom != null && (custom.nature != null || custom.heldItem != null || custom.moves.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (custom.nature != null)
                  Expanded(
                    child: Text(
                      'Nature: ${custom.nature!.split(" ").first}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                if (custom.heldItem != null)
                  Expanded(
                    child: Text(
                      'Item: ${custom.heldItem}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---- Shared Section Card ------------------------------------------------

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _groupHeading(String text, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
        ],
      ),
    );
  }

  Widget _typeEntry(String type, String? badge) => Column(
    children: [
      TypePill(type, fontSize: 12),
      if (badge != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            badge,
            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
    ],
  );

  Widget _typeGroup({
    required String heading,
    required String? subtitle,
    required List<String> types,
    required String? Function(String) badgeFor,
  }) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _groupHeading(heading, subtitle),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in types) _typeEntry(t, badgeFor(t))],
          ),
        ],
      ),
    );
  }

  // ---- Team Stats Body (Uses Edited / Custom Stats!) ------------------------

  Widget _teamStatsBody(List<Pokemon> members, bool isDark) {
    const keys = [
      ('HP', 'hp'),
      ('Attack', 'attack'),
      ('Defense', 'defense'),
      ('Sp. Attack', 'special-attack'),
      ('Sp. Defense', 'special-defense'),
      ('Speed', 'speed'),
    ];

    Widget bar(double fraction) => FractionallySizedBox(
      widthFactor: fraction.clamp(0.0, 1.0),
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF26A69A),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    final rows = <Widget>[];
    var total = 0;
    for (final (label, key) in keys) {
      final avg = members.isEmpty
          ? 0.0
          : members
                    .asMap()
                    .entries
                    .map((e) => _statValue(e.value, key, e.key))
                    .reduce((a, b) => a + b) /
                members.length;
      final shown = avg.round();
      total += shown;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(
                width: 78,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    bar(avg / 255),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 38,
                child: Text(
                  '$shown',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...rows,
        Divider(
          height: 16,
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
        ),
        Row(
          children: [
            const SizedBox(
              width: 78,
              child: Text(
                'Total BST:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
            const Expanded(child: SizedBox()),
            Text(
              '$total',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Each stat shows the average computed from your party\'s active (and customized) stats.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // ---- Defensive Coverage ---------------------------------------------------

  double _defenseIndex(List<Pokemon> members, String attacker) =>
      teamDefenseIndex([
        for (final m in members) m.types.map((s) => s.type.name).toList(),
      ], attacker);

  Widget _defenseBody(List<Pokemon> members) {
    final resistant = <String>[];
    final weak = <String>[];
    final balanced = <String>[];
    final diByType = <String, double>{};
    for (final attacker in AppColors.typeColors.keys) {
      final di = _defenseIndex(members, attacker);
      diByType[attacker] = di;
      if (di > 0) {
        resistant.add(attacker);
      } else if (di < -0.0001) {
        weak.add(attacker);
      } else {
        balanced.add(attacker);
      }
    }
    resistant.sort((a, b) => diByType[b]!.compareTo(diByType[a]!));
    weak.sort((a, b) => diByType[a]!.compareTo(diByType[b]!));

    String? diBadge(String t) => _showDefenseIndex
        ? (diByType[t]! >= 0 ? '+' : '') + diByType[t]!.toStringAsFixed(1)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Defense Index (DI) indicates how resistant your party is against specific attacking types.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Show Defense Index',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            Switch(
              value: _showDefenseIndex,
              onChanged: (v) => setState(() => _showDefenseIndex = v),
            ),
          ],
        ),
        _typeGroup(
          heading: 'Resistant against:',
          subtitle: _showDefenseIndex ? 'Defense Index > 0' : null,
          types: resistant,
          badgeFor: diBadge,
        ),
        _typeGroup(
          heading: 'Weak against:',
          subtitle: _showDefenseIndex ? 'Defense Index < 0' : null,
          types: weak,
          badgeFor: diBadge,
        ),
        _typeGroup(
          heading: 'Balanced against:',
          subtitle: _showDefenseIndex ? 'Defense Index = 0' : null,
          types: balanced,
          badgeFor: diBadge,
        ),
      ],
    );
  }

  // ---- Move Type Coverage ---------------------------------------------------

  Widget _moveCoverageBody(List<Pokemon> members, bool isDark) {
    final seedAsync = ref.watch(_movesSeedProvider);
    final memberIds = members.map((m) => m.id).toSet();

    return seedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        'Failed to load move data',
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
      data: (seedMoves) {
        int sem(String defender) {
          var count = 0;
          for (final mv in seedMoves) {
            final mult = TypeChart.getEffectiveness([defender])[mv.type] ?? 1.0;
            if (mult > 1 && mv.learn.any(memberIds.contains)) count++;
          }
          return count;
        }

        final covered = <String>[];
        final uncovered = <String>[];
        final semByType = <String, int>{};
        for (final defender in AppColors.typeColors.keys) {
          final n = sem(defender);
          semByType[defender] = n;
          (n > 0 ? covered : uncovered).add(defender);
        }
        covered.sort((a, b) => semByType[b]!.compareTo(semByType[a]!));
        final coveragePct = covered.length / AppColors.typeColors.length * 100;

        String? semBadge(String t) =>
            _showSemCounts ? '${semByType[t]} SEM' : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Super Effective Moves (SEM) available in your party against defending types.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    'Coverage',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: coveragePct / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${coveragePct.round()}%',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show Super Effective Moves',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Switch(
                  value: _showSemCounts,
                  onChanged: (v) => setState(() => _showSemCounts = v),
                ),
              ],
            ),
            _typeGroup(
              heading: 'Coverage against:',
              subtitle: _showSemCounts
                  ? 'Number of super effective moves > 0'
                  : null,
              types: covered,
              badgeFor: semBadge,
            ),
            _typeGroup(
              heading: 'No Coverage against:',
              subtitle: _showSemCounts
                  ? 'Number of super effective moves = 0'
                  : null,
              types: uncovered,
              badgeFor: semBadge,
            ),
          ],
        );
      },
    );
  }
}
