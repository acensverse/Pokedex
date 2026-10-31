import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../data/database/app_database.dart';
import '../tools/widgets/pokemon_picker_sheet.dart';
import 'services/team_customization_service.dart';
import 'widgets/team_member_editor_sheet.dart';
import 'widgets/tool_widgets.dart';

/// Create or edit a Pokémon team, with full stat and move customizability.
class NewTeamScreen extends ConsumerStatefulWidget {
  final int? editId;

  const NewTeamScreen({super.key, this.editId});

  @override
  ConsumerState<NewTeamScreen> createState() => _NewTeamScreenState();
}

class _NewTeamScreenState extends ConsumerState<NewTeamScreen> {
  final _nameController = TextEditingController();
  final List<int?> _slots = [null, null, null, null, null, null];
  final Map<int, MemberCustomization> _customizations = {};

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final team = await ref.read(databaseProvider).getTeamById(widget.editId!);
    if (!mounted || team == null) return;
    final customs = await TeamCustomizationService.loadTeamCustomizations(widget.editId!);
    setState(() {
      _nameController.text = team.name;
      _slots[0] = team.slot1;
      _slots[1] = team.slot2;
      _slots[2] = team.slot3;
      _slots[3] = team.slot4;
      _slots[4] = team.slot5;
      _slots[5] = team.slot6;
      _customizations.addAll(customs);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty && _slots.any((s) => s != null);

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? 'Edit Team & Stats' : 'Build New Team',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  // Team Name Section
                  _buildSectionHeader('Team Name', LucideIcons.tag),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E212B) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                              : Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter your team name (e.g. Master League Core)',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Party Members Section
                  _buildSectionHeader('Party Roster (6 Slots)', LucideIcons.users),
                  const SizedBox(height: 4),
                  Text(
                    'Tap any selected Pokémon to edit custom stats, level, nature, held items, and moves.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < 6; i++) _buildSlotTile(i, isDark),
                ],
              ),
            ),

            // Save Action Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                    disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: _canSave ? 3 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.check, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        isEdit ? 'SAVE TEAM & STATS' : 'CREATE TEAM',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentEmerald = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    return Row(
      children: [
        Icon(icon, size: 16, color: accentEmerald),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Future<void> _pickSlot(int index) async {
    AppFeedback.selectionClick();
    final picked = await PokemonPickerSheet.show(context);
    if (!mounted || picked == null) return;
    setState(() {
      for (var i = 0; i < _slots.length; i++) {
        if (_slots[i] == picked.id && i != index) {
          _slots[i] = null;
        }
      }
      _slots[index] = picked.id;
    });
  }

  Future<void> _openStatEditor(int index, int pokemonId) async {
    AppFeedback.lightImpact();
    final dex = await ref.read(localPokemonListProvider.future);
    final pokemon = dex.firstWhere(
      (p) => p.id == pokemonId,
      orElse: () => dex.first,
    );

    if (!mounted) return;
    final updated = await TeamMemberEditorSheet.show(
      context,
      pokemon: pokemon,
      initialCustomization: _customizations[index],
      onSave: (custom) {
        setState(() {
          _customizations[index] = custom;
        });
      },
    );

    if (updated != null && mounted) {
      setState(() {
        _customizations[index] = updated;
      });
    }
  }

  Widget _buildSlotTile(int index, bool isDark) {
    final id = _slots[index];

    if (id == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _pickSlot(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                      : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      LucideIcons.plus,
                      size: 20,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Party Slot #${index + 1}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to select a Pokémon',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Theme.of(context)
                      .iconTheme
                      .color
                      ?.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final custom = _customizations[index];

    return FutureBuilder<PokemonCacheData?>(
      future: ref.read(databaseProvider).getPokemonById(id),
      builder: (context, snapshot) {
        final row = snapshot.data;
        final types = row != null && row.types.isNotEmpty
            ? row.types.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
            : <String>['normal'];
        final primaryType = types.first;
        final typeColor = AppColors.getTypeColor(primaryType);

        final displayName = custom?.nickname != null && custom!.nickname!.isNotEmpty
            ? '${custom.nickname} (${PokemonHelpers.formatName(row?.name ?? '')})'
            : (row == null ? 'Loading...' : PokemonHelpers.formatName(row.name));

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: typeColor.withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: isDark ? 0.16 : 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 3D Artwork
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset(
                    PokemonHelpers.getHomeAssetPath(id),
                    fit: BoxFit.contain,
                    cacheWidth: PokemonHelpers.cacheWidth(context, 58),
                    errorBuilder: (_, _, _) => Image.asset(
                      PokemonHelpers.getThumbnailAssetPath(id),
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
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final t in types)
                            TypePill(t, fontSize: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lv. ${custom?.level ?? 50}',
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
                // Edit Stats button
                IconButton(
                  tooltip: 'Edit stats, level & moves',
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: isDark ? 0.25 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.pencil,
                      size: 15,
                      color: typeColor,
                    ),
                  ),
                  onPressed: () => _openStatEditor(index, id),
                ),
                // Remove button
                IconButton(
                  tooltip: 'Remove',
                  icon: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: Theme.of(context)
                        .iconTheme
                        .color
                        ?.withValues(alpha: 0.5),
                  ),
                  onPressed: () => setState(() {
                    _slots[index] = null;
                    _customizations.remove(index);
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    final entry = TeamsCompanion.insert(
      name: _nameController.text.trim(),
      slot1: Value(_slots[0]),
      slot2: Value(_slots[1]),
      slot3: Value(_slots[2]),
      slot4: Value(_slots[3]),
      slot5: Value(_slots[4]),
      slot6: Value(_slots[5]),
    );

    int savedTeamId;
    if (widget.editId != null) {
      await db.updateTeam(widget.editId!, entry);
      savedTeamId = widget.editId!;
    } else {
      savedTeamId = await db.insertTeam(entry);
    }

    // Save all custom stats, levels, natures, abilities, and moves
    await TeamCustomizationService.saveTeamCustomizations(savedTeamId, _customizations);

    if (mounted) context.pop();
  }
}
