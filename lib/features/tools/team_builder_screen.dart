import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/widgets/app_search_bar.dart';
import '../../data/database/app_database.dart';
import '../pokedex/widgets/tools_sheet.dart';
import 'services/team_customization_service.dart';

/// Premium Team Builder: browse, search, and manage Pokémon battle teams.
class TeamBuilderScreen extends ConsumerStatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  ConsumerState<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends ConsumerState<TeamBuilderScreen> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsStreamProvider(_query));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Team Builder'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
        elevation: 4,
        icon: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
        label: const Text(
          'NEW TEAM',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            fontSize: 13,
          ),
        ),
        onPressed: () {
          AppFeedback.lightImpact();
          context.push('/tools/teams/new');
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search for a team...',
              voiceTitle: 'Team Voice Search',
              voiceHint: 'Say a team name...',
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          Expanded(
            child: teamsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load teams:\n$e')),
              data: (teams) {
                if (teams.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: teams.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) => _buildTeamCard(context, teams[i], isDark),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team, bool isDark) {
    final members = [
      team.slot1,
      team.slot2,
      team.slot3,
      team.slot4,
      team.slot5,
      team.slot6,
    ].whereType<int>().toList();

    return Dismissible(
      key: ValueKey('team-${team.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 24),
      ),
      onDismissed: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        final db = ref.read(databaseProvider);
        await db.deleteTeam(team.id);
        await TeamCustomizationService.deleteTeamCustomizations(team.id);
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('"${team.name}" deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => db.restoreTeam(team),
            ),
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          AppFeedback.lightImpact();
          context.push('/tools/teams/detail?id=${team.id}');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
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
              // Team Title & Actions
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)).withValues(alpha: isDark ? 0.25 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.swords,
                        size: 16,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${members.length} / 6',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withValues(alpha: 0.6),
                    ),
                    tooltip: 'Edit Team',
                    onPressed: () {
                      AppFeedback.selectionClick();
                      context.push('/tools/teams/new?id=${team.id}');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 6 Member Party Capsules
              Row(
                children: [
                  for (var i = 0; i < 6; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i < 5 ? 6 : 0),
                        child: i < members.length
                            ? _MemberBox(pokemonId: members[i], isDark: isDark)
                            : _emptySlotBox(isDark),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Bottom Info: Tap to view details & editable stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    members.isEmpty
                        ? 'Empty party • Tap to add Pokémon'
                        : 'Tap to view defense index & edit stats',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: Theme.of(context)
                        .iconTheme
                        .color
                        ?.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptySlotBox(bool isDark) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            LucideIcons.plus,
            size: 16,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E212B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)).withValues(alpha: isDark ? 0.20 : 0.10),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.users,
                    size: 34,
                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _query.isEmpty
                    ? 'Build Your Dream Team'
                    : 'No Teams Match "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _query.isEmpty
                      ? 'Create competitive Pokémon parties, customize moves, natures, held items, and fine-tune stats for battle simulations.'
                      : 'Try searching with a different name or clear the search box.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
                ),
              ),
              if (_query.isEmpty) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    AppFeedback.selectionClick();
                    context.push('/tools/teams/new');
                  },
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('CREATE FIRST TEAM'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

class _MemberBox extends ConsumerWidget {
  final int pokemonId;
  final bool isDark;

  const _MemberBox({required this.pokemonId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<PokemonCacheData?>(
      future: db.getPokemonById(pokemonId),
      builder: (context, snapshot) {
        final row = snapshot.data;
        final types = row != null && row.types.isNotEmpty
            ? row.types.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : <String>['normal'];
        final primaryType = types.first;
        final secondaryType = types.length > 1 ? types[1] : null;
        final typeColor = AppColors.getTypeColor(primaryType);
        final secColor = secondaryType != null ? AppColors.getTypeColor(secondaryType) : null;

        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              gradient: secColor != null
                  ? LinearGradient(
                      colors: [
                        typeColor.withValues(alpha: isDark ? 0.28 : 0.16),
                        secColor.withValues(alpha: isDark ? 0.28 : 0.16),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: secColor == null
                  ? typeColor.withValues(alpha: isDark ? 0.22 : 0.12)
                  : null,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: typeColor.withValues(alpha: isDark ? 0.45 : 0.3),
                width: 1.2,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Image.asset(
                      PokemonHelpers.getHomeAssetPath(pokemonId),
                      fit: BoxFit.contain,
                      cacheWidth: PokemonHelpers.cacheWidth(context, 48),
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        PokemonHelpers.getThumbnailAssetPath(pokemonId),
                        fit: BoxFit.contain,
                        cacheWidth: PokemonHelpers.cacheWidth(context, 44),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.catching_pokemon,
                          size: 22,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final t in types)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.getTypeColor(t),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
