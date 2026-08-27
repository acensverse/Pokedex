import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../pokedex/widgets/tools_sheet.dart';
import '../../data/database/app_database.dart';

/// Team list with search; swipe to delete, FAB to create.
class TeamBuilderScreen extends ConsumerStatefulWidget {
  const TeamBuilderScreen({super.key});

  @override
  ConsumerState<TeamBuilderScreen> createState() => _TeamBuilderScreenState();
}

class _TeamBuilderScreenState extends ConsumerState<TeamBuilderScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsStreamProvider(_query));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Team builder'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 32),
        onPressed: () => context.push('/tools/teams/new'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search for a team...',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: teamsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load teams:\n$e')),
              data: (teams) {
                if (teams.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.groups,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'No teams yet.\nTap + to build your dream team!'
                              : 'No teams match "$_query"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: teams.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _teamCard(context, teams[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamCard(BuildContext context, Team team) {
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
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        final messenger = ScaffoldMessenger.of(context);
        final db = ref.read(databaseProvider);
        await db.deleteTeam(team.id);
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
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/tools/teams/detail?id=${team.id}'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 44,
                height: 3,
                color: AppColors.primary,
              ),
              if (members.isEmpty)
                Text(
                  'Empty party - tap to add Pok\u00e9mon',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                )
              else
                // Equal-width squares shrink to fit: all members always on
                // one line, no scrolling, no overflow.
                Row(
                  children: [
                    for (final id in members)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _MemberBox(pokemonId: id),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberBox extends ConsumerWidget {
  final int pokemonId;

  const _MemberBox({required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<PokemonCacheData?>(
      future: db.getPokemonById(pokemonId),
      builder: (context, snapshot) {
        final row = snapshot.data;
        final tint = row == null
            ? Colors.grey.shade200
            : AppColors.getTypeColor(
                row.types.split(',').first.trim(),
              ).withValues(alpha: 0.18);
        return GestureDetector(
          onTap: () => context.push('/pokemon/$pokemonId'),
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Stack(
                children: [
                  // Faint pokeball watermark, clipped top-right.
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 34,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      // Pokemon Home 3D artwork, thumbnail fallback.
                      PokemonHelpers.getHomeAssetPath(pokemonId),
                      fit: BoxFit.contain,
                      cacheWidth: PokemonHelpers.cacheWidth(context, 46),
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        PokemonHelpers.getThumbnailAssetPath(pokemonId),
                        fit: BoxFit.contain,
                        cacheWidth: PokemonHelpers.cacheWidth(context, 40),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.catching_pokemon,
                          size: 22,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
