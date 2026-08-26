import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../data/database/app_database.dart';
import '../tools/widgets/pokemon_picker_sheet.dart';

/// Create or edit a team. Pass ?id= for edit mode.
class NewTeamScreen extends ConsumerStatefulWidget {
  final int? editId;

  const NewTeamScreen({super.key, this.editId});

  @override
  ConsumerState<NewTeamScreen> createState() => _NewTeamScreenState();
}

class _NewTeamScreenState extends ConsumerState<NewTeamScreen> {
  final _nameController = TextEditingController();
  final List<int?> _slots = [null, null, null, null, null, null];

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    final team =
        await ref.read(databaseProvider).getTeamById(widget.editId!);
    if (!mounted || team == null) return;
    setState(() {
      _nameController.text = team.name;
      _slots[0] = team.slot1;
      _slots[1] = team.slot2;
      _slots[2] = team.slot3;
      _slots[3] = team.slot4;
      _slots[4] = team.slot5;
      _slots[5] = team.slot6;
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text(isEdit ? 'Edit team' : 'New team',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _SectionLabel('Team name'),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter the name of your team',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Pok\u00e9mon party'),
                  ...[
                    for (var i = 0; i < 6; i++) _slotTile(i),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                child: InkWell(
                  onTap: _canSave ? _save : null,
                  borderRadius: BorderRadius.circular(28),
                  child: Ink(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _canSave
                            ? const [Color(0xFF66BB6A), Color(0xFF26A69A)]
                            : [Colors.grey.shade400, Colors.grey.shade500],
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 10),
                        Text('SAVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                                fontSize: 15)),
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

  Future<void> _pickSlot(int index) async {
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

  Widget _slotTile(int index) {
    final id = _slots[index];
    if (id == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _pickSlot(index),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
              child: Row(
                children: [
                  // Empty slots match the filled square preview box size.
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                        Icons.catching_pokemon, color: Colors.grey.shade500),
                  ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pok\u00e9mon #${index + 1}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    Text('Add your #${index + 1} Pok\u00e9mon',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<PokemonCacheData?>(
      future: ref.read(databaseProvider).getPokemonById(id),
      builder: (context, snapshot) {
        final row = snapshot.data;
        final tint = row == null
            ? Colors.grey.shade200
            : AppColors.getTypeColor(row.types.split(',').first.trim())
                .withValues(alpha: 0.25);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _pickSlot(index),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Square preview box with Pokemon Home artwork.
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      PokemonHelpers.getHomeAssetPath(id),
                      fit: BoxFit.contain,
                      cacheWidth: PokemonHelpers.cacheWidth(context, 64),
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                        PokemonHelpers.getThumbnailAssetPath(id),
                        fit: BoxFit.contain,
                        cacheWidth: PokemonHelpers.cacheWidth(context, 52),
                        errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.catching_pokemon,
                            size: 36,
                            color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      row == null
                          ? 'Loading...'
                          : PokemonHelpers.formatName(row.name),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black45),
                    onPressed: () =>
                        setState(() => _slots[index] = null),
                  ),
                ],
              ),
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
    if (widget.editId != null) {
      await db.updateTeam(widget.editId!, entry);
    } else {
      await db.insertTeam(entry);
    }
    if (mounted) context.pop();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
    );
  }
}
