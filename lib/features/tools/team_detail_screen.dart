import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/type_chart.dart';
import '../pokedex/widgets/pokemon_card.dart';
import '../../models/pokemon.dart';
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

  int _statValue(Pokemon p, String key) {
    for (final s in p.stats) {
      if (s.stat.name == key) return s.baseStat;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final teamFuture = ref.watch(databaseProvider).getTeamById(widget.teamId);
    final membersAsync = ref.watch(localPokemonListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: FutureBuilder(
          future: teamFuture,
          builder: (context, snapshot) => Text(
            snapshot.data?.name ?? 'Team',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () =>
                context.push('/tools/teams/new?id=${widget.teamId}'),
          ),
        ],
      ),
      body: FutureBuilder(
        future: teamFuture,
        builder: (context, teamSnapshot) {
          final team = teamSnapshot.data;
          if (team == null) {
            return Center(child: CircularProgressIndicator());
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
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load dex:\n$e')),
            data: (dex) {
              final byId = {for (final p in dex) p.id: p};
              final members = [
                for (final id in slotIds)
                  if (byId[id] != null) byId[id]!,
              ];

              return ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  // Members as home-grid gradient cards.
                  for (final p in members) PokemonCard(pokemon: p),
                  if (members.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Empty party',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(height: 16),
                    _sectionCard('Team stats', _teamStatsBody(members)),
                    SizedBox(height: 26),
                    _sectionCard('Defensive coverage', _defenseBody(members)),
                    SizedBox(height: 26),
                    _sectionCard(
                      'Move type coverage',
                      _moveCoverageBody(members),
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

  // ---- Shared section chrome ----------------------------------------------

  Widget _sectionCard(String title, Widget child) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.topCenter,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 14),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
      Positioned(top: 0, child: SectionHeaderPill(title)),
    ],
  );

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
    if (types.isEmpty) return SizedBox.shrink();
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

  // ---- Team stats -----------------------------------------------------------

  Widget _teamStatsBody(List<Pokemon> members) {
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
        height: 10,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF26A69A), Color(0xFF66BB6A)],
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );

    final rows = <Widget>[];
    var total = 0;
    for (final (label, key) in keys) {
      final avg = members.isEmpty
          ? 0.0
          : members.map((m) => _statValue(m, key)).reduce((a, b) => a + b) /
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
                  style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey.shade800 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    bar(avg / 255),
                  ],
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 34,
                child: Text(
                  '$shown',
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
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...rows,
        const Divider(height: 20),
        Row(
          children: [
            SizedBox(
              width: 78,
              child: Text(
                'Total:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
            const Expanded(child: SizedBox()),
            Text(
              '$total',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Each stat is an average of the stats of each Pok\u00e9mon in the party.',
          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ---- Defensive coverage ---------------------------------------------------

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
          'The Defense Index (DI) indicates how resistant (or weak) your team '
          'is against a specific type. Higher positive value indicates '
          'greater team resistance.',
          style: TextStyle(
            fontSize: 12.5,
            height: 1.4,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Show Defense Index',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

  // ---- Move type coverage ---------------------------------------------------

  Widget _moveCoverageBody(List<Pokemon> members) {
    final seedAsync = ref.watch(_movesSeedProvider);
    final memberIds = members.map((m) => m.id).toSet();

    return seedAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text(
        'Failed to load move data',
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
      data: (seedMoves) {
        // SEM per defending type: moves that any party member can learn and
        // that hit the defender super effectively.
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
              'This value is based on the number of Super Effective Moves (SEM) '
              'available in your party against a specific type.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            SizedBox(height: 12),
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
                        height: 10,
                        decoration: BoxDecoration(
                          color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey.shade800 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: coveragePct / 100,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFE4613E)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
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
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Show Super Effective Moves',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
