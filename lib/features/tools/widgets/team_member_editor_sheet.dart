import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/champions.dart';
import '../../../core/feedback_service.dart';
import '../../../core/utils/pokemon_helpers.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../models/pokemon.dart';
import '../abilities_screen.dart';
import '../items_screen.dart';
import '../moves_screen.dart';
import '../services/team_customization_service.dart';
import 'tool_widgets.dart';

/// Structured information for all 25 Pokémon natures.
class NatureInfo {
  final String name;
  final String? increasedStat;
  final String? decreasedStat;

  const NatureInfo({
    required this.name,
    this.increasedStat,
    this.decreasedStat,
  });

  bool get isNeutral => increasedStat == null || increasedStat == decreasedStat;

  String get displayName => isNeutral
      ? '$name (Neutral)'
      : '$name (+${_shortStat(increasedStat!)}, -${_shortStat(decreasedStat!)})';

  static String _shortStat(String s) {
    switch (s) {
      case 'Attack':
        return 'Atk';
      case 'Defense':
        return 'Def';
      case 'Sp. Atk':
        return 'SpA';
      case 'Sp. Def':
        return 'SpD';
      case 'Speed':
        return 'Spe';
      default:
        return s;
    }
  }

  static const List<NatureInfo> all = [
    // Attack Boost
    NatureInfo(name: 'Adamant', increasedStat: 'Attack', decreasedStat: 'Sp. Atk'),
    NatureInfo(name: 'Brave', increasedStat: 'Attack', decreasedStat: 'Speed'),
    NatureInfo(name: 'Lonely', increasedStat: 'Attack', decreasedStat: 'Defense'),
    NatureInfo(name: 'Naughty', increasedStat: 'Attack', decreasedStat: 'Sp. Def'),

    // Sp. Atk Boost
    NatureInfo(name: 'Modest', increasedStat: 'Sp. Atk', decreasedStat: 'Attack'),
    NatureInfo(name: 'Quiet', increasedStat: 'Sp. Atk', decreasedStat: 'Speed'),
    NatureInfo(name: 'Mild', increasedStat: 'Sp. Atk', decreasedStat: 'Defense'),
    NatureInfo(name: 'Rash', increasedStat: 'Sp. Atk', decreasedStat: 'Sp. Def'),

    // Speed Boost
    NatureInfo(name: 'Jolly', increasedStat: 'Speed', decreasedStat: 'Sp. Atk'),
    NatureInfo(name: 'Timid', increasedStat: 'Speed', decreasedStat: 'Attack'),
    NatureInfo(name: 'Hasty', increasedStat: 'Speed', decreasedStat: 'Defense'),
    NatureInfo(name: 'Naive', increasedStat: 'Speed', decreasedStat: 'Sp. Def'),

    // Defense Boost
    NatureInfo(name: 'Bold', increasedStat: 'Defense', decreasedStat: 'Attack'),
    NatureInfo(name: 'Impish', increasedStat: 'Defense', decreasedStat: 'Sp. Atk'),
    NatureInfo(name: 'Relaxed', increasedStat: 'Defense', decreasedStat: 'Speed'),
    NatureInfo(name: 'Lax', increasedStat: 'Defense', decreasedStat: 'Sp. Def'),

    // Sp. Def Boost
    NatureInfo(name: 'Calm', increasedStat: 'Sp. Def', decreasedStat: 'Attack'),
    NatureInfo(name: 'Careful', increasedStat: 'Sp. Def', decreasedStat: 'Sp. Atk'),
    NatureInfo(name: 'Sassy', increasedStat: 'Sp. Def', decreasedStat: 'Speed'),
    NatureInfo(name: 'Gentle', increasedStat: 'Sp. Def', decreasedStat: 'Defense'),

    // Neutral
    NatureInfo(name: 'Hardy'),
    NatureInfo(name: 'Docile'),
    NatureInfo(name: 'Serious'),
    NatureInfo(name: 'Bashful'),
    NatureInfo(name: 'Quirky'),
  ];

  static NatureInfo fromString(String raw) {
    final clean = raw.split(' ').first.trim().toLowerCase();
    for (final n in all) {
      if (n.name.toLowerCase() == clean) return n;
    }
    return all.first; // Adamant fallback
  }
}

/// Full-page Pokémon customizer for Team Builder:
/// Allows editing Nickname, Level, Nature, Ability, Held Item (from National/Champions dex),
/// Moves (from Learnable/National/Champions dex), and Stat Points (0-32 each, max 66 total)
/// using interactive sliders that compute live level-50 stats matching Pokémon Champions.
class TeamMemberEditorScreen extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final MemberCustomization? initialCustomization;
  final void Function(MemberCustomization updated) onSave;

  const TeamMemberEditorScreen({
    super.key,
    required this.pokemon,
    this.initialCustomization,
    required this.onSave,
  });

  static Future<MemberCustomization?> show(
    BuildContext context, {
    required Pokemon pokemon,
    MemberCustomization? initialCustomization,
    required void Function(MemberCustomization updated) onSave,
  }) {
    return Navigator.of(context).push<MemberCustomization>(
      MaterialPageRoute(
        builder: (ctx) => TeamMemberEditorScreen(
          pokemon: pokemon,
          initialCustomization: initialCustomization,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  ConsumerState<TeamMemberEditorScreen> createState() =>
      _TeamMemberEditorScreenState();
}

// Backward-compatible alias so existing imports and tests work seamlessly
typedef TeamMemberEditorSheet = TeamMemberEditorScreen;

class _TeamMemberEditorScreenState
    extends ConsumerState<TeamMemberEditorScreen> {
  late TextEditingController _nicknameController;
  late int _level;
  late String? _selectedNature;
  late String? _selectedAbility;
  late String? _selectedHeldItem;
  late List<String> _moves;
  late Map<String, int> _statPoints;
  late Map<String, int> _customStats;

  static const _statKeys = [
    ('HP', 'hp'),
    ('Atk', 'attack'),
    ('Def', 'defense'),
    ('SpA', 'special-attack'),
    ('SpD', 'special-defense'),
    ('Spe', 'speed'),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomization ?? const MemberCustomization();
    _nicknameController = TextEditingController(text: c.nickname ?? '');
    _level = c.level;
    _selectedNature = c.nature ?? 'Adamant (+Atk, -SpA)';
    _selectedAbility = c.ability ??
        (widget.pokemon.abilities.isNotEmpty
            ? widget.pokemon.abilities.first.ability.name
            : null);
    _selectedHeldItem = c.heldItem;

    _moves = List.generate(4, (i) => i < c.moves.length ? c.moves[i] : '');

    // Stat points (0 to 32 each, max 66 total)
    _statPoints = {};
    for (final (_, key) in _statKeys) {
      if (c.statPoints.containsKey(key)) {
        _statPoints[key] = c.statPoints[key]!.clamp(0, 32);
      } else if (c.customStats.containsKey(key)) {
        // Infer SP from legacy customStats if available
        final base = _baseStat(key);
        final current = c.customStats[key]!;
        final diff = key == 'hp' ? (current - base - 75) : (current - base - 20);
        _statPoints[key] = diff.clamp(0, 32);
      } else {
        _statPoints[key] = 0;
      }
    }

    _customStats = {};
    _recalculateAllStats();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  int _baseStat(String key) {
    for (final s in widget.pokemon.stats) {
      if (s.stat.name == key) return s.baseStat;
    }
    return 80;
  }

  int get _totalStatPoints {
    return _statPoints.values.fold(0, (sum, val) => sum + val);
  }

  double _getNatureMultiplier(String statKey) {
    if (_selectedNature == null || statKey == 'hp') return 1.0;
    final n = _selectedNature!.toLowerCase();
    if (statKey == 'attack') {
      if (n.contains('+atk')) return 1.1;
      if (n.contains('-atk')) return 0.9;
    } else if (statKey == 'defense') {
      if (n.contains('+def')) return 1.1;
      if (n.contains('-def')) return 0.9;
    } else if (statKey == 'special-attack') {
      if (n.contains('+spa')) return 1.1;
      if (n.contains('-spa')) return 0.9;
    } else if (statKey == 'special-defense') {
      if (n.contains('+spd')) return 1.1;
      if (n.contains('-spd')) return 0.9;
    } else if (statKey == 'speed') {
      if (n.contains('+spe')) return 1.1;
      if (n.contains('-spe')) return 0.9;
    }
    return 1.0;
  }

  int _calculateFinalStat(String key, int sp) {
    final base = _baseStat(key);
    if (key == 'hp') {
      return base + sp + 75;
    }
    final multiplier = _getNatureMultiplier(key);
    return ((base + sp + 20) * multiplier).floor();
  }

  void _recalculateAllStats() {
    for (final (_, key) in _statKeys) {
      final sp = _statPoints[key] ?? 0;
      _customStats[key] = _calculateFinalStat(key, sp);
    }
  }

  void _updateStatPoint(String key, int desired) {
    final current = _statPoints[key] ?? 0;
    final otherTotal = _totalStatPoints - current;
    final maxAllowed = min(32, 66 - otherTotal);
    final clamped = desired.clamp(0, maxAllowed);

    if (clamped != current) {
      AppFeedback.selectionClick();
      setState(() {
        _statPoints[key] = clamped;
        _customStats[key] = _calculateFinalStat(key, clamped);
      });
    }
  }

  void _resetStatPoints() {
    AppFeedback.lightImpact();
    setState(() {
      for (final (_, key) in _statKeys) {
        _statPoints[key] = 0;
      }
      _recalculateAllStats();
    });
  }

  void _applySweeperPreset(bool physical) {
    AppFeedback.lightImpact();
    setState(() {
      for (final (_, key) in _statKeys) {
        _statPoints[key] = 0;
      }
      if (physical) {
        _statPoints['attack'] = 32;
        _statPoints['speed'] = 32;
        _statPoints['hp'] = 2;
      } else {
        _statPoints['special-attack'] = 32;
        _statPoints['speed'] = 32;
        _statPoints['hp'] = 2;
      }
      _recalculateAllStats();
    });
  }

  void _applyBulkyPreset() {
    AppFeedback.lightImpact();
    setState(() {
      for (final (_, key) in _statKeys) {
        _statPoints[key] = 0;
      }
      _statPoints['hp'] = 32;
      _statPoints['defense'] = 32;
      _statPoints['special-defense'] = 2;
      _recalculateAllStats();
    });
  }

  void _save() {
    AppFeedback.lightImpact();
    final updated = MemberCustomization(
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      level: _level,
      nature: _selectedNature,
      ability: _selectedAbility,
      heldItem: _selectedHeldItem,
      moves: _moves.where((m) => m.trim().isNotEmpty).toList(),
      customStats: Map<String, int>.from(_customStats),
      statPoints: Map<String, int>.from(_statPoints),
    );

    widget.onSave(updated);
    Navigator.of(context).pop(updated);
  }

  // ---- Modals & Pickers ----------------------------------------------------

  Future<void> _openNaturePicker() async {
    AppFeedback.selectionClick();
    final picked = await showModalBottomSheet<NatureInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NaturePickerSheet(
        currentNature: NatureInfo.fromString(_selectedNature ?? 'Adamant'),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedNature = picked.displayName;
        _recalculateAllStats();
      });
    }
  }

  Future<void> _openAllAbilitiesPicker() async {
    AppFeedback.selectionClick();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AbilityPickerSheet(
        currentAbility: _selectedAbility,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedAbility = picked;
      });
    }
  }

  Future<void> _openItemPicker() async {
    AppFeedback.selectionClick();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ItemPickerSheet(
        currentItem: _selectedHeldItem,
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedHeldItem = picked.isEmpty ? null : picked;
      });
    }
  }

  Future<void> _openMovePicker(int slotIndex) async {
    AppFeedback.selectionClick();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MovePickerSheet(
        pokemon: widget.pokemon,
        currentMove: _moves[slotIndex],
        slotIndex: slotIndex,
      ),
    );

    if (picked != null) {
      setState(() {
        _moves[slotIndex] = picked;
      });
    }
  }

  // ---- Build UI -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryType = widget.pokemon.types.isNotEmpty
        ? widget.pokemon.types.first.type.name
        : 'normal';
    final typeColor = AppColors.getTypeColor(primaryType);
    final abilitiesAsync = ref.watch(abilitiesSeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit ${PokemonHelpers.formatName(widget.pokemon.name)}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(LucideIcons.check, size: 16),
            label: const Text(
              'SAVE',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6),
            ),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  // Hero Header with 3D artwork and DUAL TYPE PILLS
                  _buildHeroCard(isDark, typeColor),
                  const SizedBox(height: 16),

                  // Profile & Details (Nickname, Level, Nature, Ability)
                  _buildProfileCard(isDark, abilitiesAsync),
                  const SizedBox(height: 16),

                  // Held Item Section (National / Champions Dex selection)
                  _buildHeldItemCard(isDark),
                  const SizedBox(height: 16),

                  // 4 Move Slots (Learnable / Champions / National Dex selection)
                  _buildMovesCard(isDark),
                  const SizedBox(height: 16),

                  // Stat Points Editor matching user screenshot
                  _buildStatPointsCard(isDark),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Sticky Save Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(LucideIcons.save, size: 18),
                  label: const Text(
                    'SAVE POKÉMON',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  // ---- Hero Header with Dual Types -----------------------------------------

  Widget _buildHeroCard(bool isDark, Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeColor.withValues(alpha: isDark ? 0.4 : 0.25),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: isDark ? 0.16 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset(
              PokemonHelpers.getHomeAssetPath(widget.pokemon.id),
              fit: BoxFit.contain,
              cacheWidth: PokemonHelpers.cacheWidth(context, 76),
              errorBuilder: (_, _, _) => Image.asset(
                PokemonHelpers.getThumbnailAssetPath(widget.pokemon.id),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${widget.pokemon.id.toString().padLeft(4, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: typeColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  PokemonHelpers.formatName(widget.pokemon.name),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                // DUAL TYPE DISPLAY
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final t in widget.pokemon.types)
                      TypePill(t.type.name, fontSize: 11),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Profile Details with Premium Nature & Ability Boxes -----------------

  Widget _buildProfileCard(
    bool isDark,
    AsyncValue<List<AbilityEntry>> abilitiesAsync,
  ) {
    final natureInfo = NatureInfo.fromString(_selectedNature ?? 'Adamant');

    return _buildSectionBox(
      isDark: isDark,
      title: 'IDENTITY & PROFILE',
      icon: LucideIcons.badgeCheck,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nickname field
          const Text(
            'Custom Nickname',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nicknameController,
            autofocus: false,
            keyboardType: TextInputType.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Sparky, Ace, Blaster...',
              hintStyle: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.28),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Level Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Level',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Lv. $_level',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
          Slider(
            value: _level.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            activeColor:
                isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
            onChanged: (val) {
              setState(() => _level = val.round());
            },
          ),
          const SizedBox(height: 14),

          // PREMIUM NATURE SELECTOR BOX
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nature',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              Text(
                'Stat Modifier (±10%)',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: _openNaturePicker,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF34D399).withValues(alpha: 0.4)
                      : const Color(0xFF059669).withValues(alpha: 0.3),
                  width: 1.3,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669))
                          .withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.leaf,
                        size: 20,
                        color: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          natureInfo.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (natureInfo.increasedStat != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+10% ${natureInfo.increasedStat}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            if (natureInfo.decreasedStat != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-10% ${natureInfo.decreasedStat}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            if (natureInfo.isNeutral)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Neutral (No Stat Changes)',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // PREMIUM ABILITY SELECTOR CARDS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ability',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              Text(
                'Tap to equip',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Species Abilities selectable cards
          for (final a in widget.pokemon.abilities) ...[
            _buildSpeciesAbilityCard(a, isDark, abilitiesAsync),
            const SizedBox(height: 8),
          ],

          // Option to browse all abilities
          InkWell(
            onTap: _openAllAbilitiesPicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.search,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Browse all other abilities...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesAbilityCard(
    PokemonAbilitySlot a,
    bool isDark,
    AsyncValue<List<AbilityEntry>> abilitiesAsync,
  ) {
    final isSelected = _selectedAbility != null &&
        _selectedAbility!.toLowerCase() == a.ability.name.toLowerCase();

    // Look up description from seed
    String? description;
    final all = abilitiesAsync.value;
    if (all != null) {
      for (final item in all) {
        if (item.name.toLowerCase() == a.ability.name.toLowerCase()) {
          description = item.eff ?? item.flavor;
          break;
        }
      }
    }

    return InkWell(
      onTap: () {
        AppFeedback.selectionClick();
        setState(() => _selectedAbility = a.ability.name);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669))
                  .withValues(alpha: isDark ? 0.16 : 0.08)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : (isDark ? Colors.white10 : Colors.grey.shade300),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669))
                        .withValues(alpha: 0.22)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  isSelected ? LucideIcons.check : LucideIcons.sparkles,
                  size: 16,
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669))
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          PokemonHelpers.formatName(a.ability.name),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669))
                                : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: a.isHidden
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.16)
                              : (isDark
                                  ? Colors.white10
                                  : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          a.isHidden ? 'Hidden Ability ★' : 'Standard Ability',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: a.isHidden
                                ? const Color(0xFFF59E0B)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.3,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Held Item Section ---------------------------------------------------

  Widget _buildHeldItemCard(bool isDark) {
    final itemSelected = _selectedHeldItem != null && _selectedHeldItem!.isNotEmpty;

    return _buildSectionBox(
      isDark: isDark,
      title: 'HELD ITEM',
      icon: LucideIcons.backpack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose legal items from the Champions Dex or National Dex catalog.',
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _openItemPicker,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: itemSelected
                      ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                      : (isDark ? Colors.white12 : Colors.grey.shade300),
                  width: itemSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        itemSelected ? LucideIcons.packageCheck : LucideIcons.plus,
                        size: 20,
                        color: itemSelected
                            ? (isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF059669))
                            : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemSelected
                              ? PokemonHelpers.formatName(_selectedHeldItem!)
                              : 'None (Tap to choose held item)',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: itemSelected
                                ? null
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                          ),
                        ),
                        if (itemSelected) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'Equipped held item • Tap to change',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (itemSelected)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      tooltip: 'Remove item',
                      onPressed: () {
                        AppFeedback.selectionClick();
                        setState(() => _selectedHeldItem = null);
                      },
                    )
                  else
                    const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Moves Card (4 Slots) ------------------------------------------------

  Widget _buildMovesCard(bool isDark) {
    return _buildSectionBox(
      isDark: isDark,
      title: 'MOVESET (4 SLOTS)',
      icon: LucideIcons.swords,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select from Learnable Moves, Champions Dex, or the full National Move list.',
            style: TextStyle(
              fontSize: 11.5,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < 4; i++) ...[
            _buildMoveSlotTile(i, isDark),
            if (i < 3) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildMoveSlotTile(int slotIndex, bool isDark) {
    final moveName = _moves[slotIndex];
    final hasMove = moveName.trim().isNotEmpty;

    return InkWell(
      onTap: () => _openMovePicker(slotIndex),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasMove
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                    .withValues(alpha: 0.6)
                : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${slotIndex + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasMove
                    ? PokemonHelpers.formatName(moveName)
                    : 'Tap to select Move ${slotIndex + 1}...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasMove ? FontWeight.w800 : FontWeight.w500,
                  color: hasMove
                      ? null
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.6),
                ),
              ),
            ),
            if (hasMove)
              IconButton(
                icon: const Icon(LucideIcons.x, size: 16),
                tooltip: 'Clear move',
                onPressed: () {
                  AppFeedback.selectionClick();
                  setState(() => _moves[slotIndex] = '');
                },
              )
            else
              const Icon(LucideIcons.chevronRight, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ---- Stat Points Section (Exact Image Layout) ----------------------------

  Widget _buildStatPointsCard(bool isDark) {
    final totalSpent = _totalStatPoints;
    final primaryType = widget.pokemon.types.isNotEmpty
        ? widget.pokemon.types.first.type.name
        : 'normal';
    final typeColor = AppColors.getTypeColor(primaryType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row exactly as in provided image:
          // STAT POINTS                           0 / 66 max 32 each
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'STAT POINTS',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color:
                      isDark ? Colors.blueGrey.shade300 : const Color(0xFF64748B),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$totalSpent / 66 ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: totalSpent == 66
                            ? (isDark
                                ? const Color(0xFF34D399)
                                : const Color(0xFF059669))
                            : (isDark ? Colors.white : const Color(0xFF1E293B)),
                      ),
                    ),
                    TextSpan(
                      text: 'max 32 each',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.grey.shade400
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Thin divider line underneath header
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // 6 Stats Sliders matching the screenshot exactly
          for (final (label, key) in _statKeys) ...[
            _buildStatSliderRow(label, key, isDark, typeColor),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 8),

          // Quick Presets
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetPill(
                label: 'Reset to 0',
                icon: LucideIcons.rotateCcw,
                isDark: isDark,
                onTap: _resetStatPoints,
              ),
              _buildPresetPill(
                label: 'Phys. Sweeper (32/32/2)',
                icon: LucideIcons.swords,
                isDark: isDark,
                onTap: () => _applySweeperPreset(true),
              ),
              _buildPresetPill(
                label: 'Spec. Sweeper (32/32/2)',
                icon: LucideIcons.sparkles,
                isDark: isDark,
                onTap: () => _applySweeperPreset(false),
              ),
              _buildPresetPill(
                label: 'Tank (32/32/2)',
                icon: LucideIcons.shield,
                isDark: isDark,
                onTap: _applyBulkyPreset,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSliderRow(
    String label,
    String key,
    bool isDark,
    Color typeColor,
  ) {
    final sp = _statPoints[key] ?? 0;
    final finalStat = _customStats[key] ?? _calculateFinalStat(key, sp);
    final multiplier = _getNatureMultiplier(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stat Label on left, 'X EV (FinalStat)' on right
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (multiplier > 1.0) ...[
                  const SizedBox(width: 4),
                  const Text('(+10%)',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981))),
                ] else if (multiplier < 1.0) ...[
                  const SizedBox(width: 4),
                  const Text('(-10%)',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEF4444))),
                ],
              ],
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$sp EV ',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  TextSpan(
                    text: '($finalStat)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade400
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Slider exactly like in screenshot
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 5,
            activeTrackColor:
                isDark ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1),
            inactiveTrackColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 9,
              elevation: 2,
            ),
            overlayColor: Colors.grey.withValues(alpha: 0.15),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: sp.toDouble(),
            min: 0,
            max: 32,
            divisions: 32,
            onChanged: (val) => _updateStatPoint(key, val.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetPill({
    required String label,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12),
            const SizedBox(width: 6),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionBox({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF059669))
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
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

// =============================================================================
// NATURE PICKER SHEET (Premium Categorized + Searchable Sheet)
// =============================================================================

class _NaturePickerSheet extends StatefulWidget {
  final NatureInfo currentNature;

  const _NaturePickerSheet({required this.currentNature});

  @override
  State<_NaturePickerSheet> createState() => _NaturePickerSheetState();
}

class _NaturePickerSheetState extends State<_NaturePickerSheet> {
  String _query = '';
  int _categoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  static const _categories = [
    'All (25)',
    'Attack (+Atk)',
    'Speed (+Spe)',
    'Sp. Atk (+SpA)',
    'Defense (+Def)',
    'Sp. Def (+SpD)',
    'Neutral',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = NatureInfo.all.where((n) {
      if (_categoryIndex == 1 && n.increasedStat != 'Attack') return false;
      if (_categoryIndex == 2 && n.increasedStat != 'Speed') return false;
      if (_categoryIndex == 3 && n.increasedStat != 'Sp. Atk') return false;
      if (_categoryIndex == 4 && n.increasedStat != 'Defense') return false;
      if (_categoryIndex == 5 && n.increasedStat != 'Sp. Def') return false;
      if (_categoryIndex == 6 && !n.isNeutral) return false;

      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final matchesName = n.name.toLowerCase().contains(q);
        final matchesInc = n.increasedStat?.toLowerCase().contains(q) ?? false;
        final matchesDec = n.decreasedStat?.toLowerCase().contains(q) ?? false;
        if (!matchesName && !matchesInc && !matchesDec) return false;
      }
      return true;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Nature',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search by nature name or boosted stat...',
              voiceTitle: 'Nature Search',
              voiceHint: 'Say Adamant, Jolly, or Attack...',
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          const SizedBox(height: 10),

          // Categories horizontal bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _categories.length; i++) ...[
                    _buildCategoryChip(
                      label: _categories[i],
                      selected: _categoryIndex == i,
                      isDark: isDark,
                      onTap: () => setState(() => _categoryIndex = i),
                    ),
                    if (i < _categories.length - 1) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Natures grid / list
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching natures found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final nature = filtered[idx];
                      final isSelected =
                          nature.name.toLowerCase() ==
                              widget.currentNature.name.toLowerCase();

                      return InkWell(
                        onTap: () {
                          AppFeedback.selectionClick();
                          Navigator.of(context).pop(nature);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF059669))
                                    .withValues(alpha: isDark ? 0.18 : 0.09)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF059669))
                                  : (isDark
                                      ? Colors.white10
                                      : Colors.grey.shade300),
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                              ? const Color(0xFF34D399)
                                              : const Color(0xFF059669))
                                          .withValues(alpha: 0.22)
                                      : (isDark
                                          ? Colors.white10
                                          : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    isSelected
                                        ? LucideIcons.check
                                        : LucideIcons.leaf,
                                    size: 16,
                                    color: isSelected
                                        ? (isDark
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFF059669))
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nature.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected
                                            ? (isDark
                                                ? const Color(0xFF34D399)
                                                : const Color(0xFF059669))
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        if (nature.increasedStat != null)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981)
                                                  .withValues(alpha: 0.16),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '+10% ${nature.increasedStat}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF10B981),
                                              ),
                                            ),
                                          ),
                                        if (nature.decreasedStat != null)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444)
                                                  .withValues(alpha: 0.16),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '-10% ${nature.decreasedStat}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
                                          ),
                                        if (nature.isNeutral)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey
                                                  .withValues(alpha: 0.14),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'Neutral (No Changes)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? const Color(0xFF34D399).withValues(alpha: 0.2)
                  : const Color(0xFF059669).withValues(alpha: 0.12))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : null,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ABILITY PICKER SHEET (Search across all abilities)
// =============================================================================

class _AbilityPickerSheet extends ConsumerStatefulWidget {
  final String? currentAbility;

  const _AbilityPickerSheet({required this.currentAbility});

  @override
  ConsumerState<_AbilityPickerSheet> createState() =>
      _AbilityPickerSheetState();
}

class _AbilityPickerSheetState extends ConsumerState<_AbilityPickerSheet> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final abilitiesAsync = ref.watch(abilitiesSeedProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Ability',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search all abilities...',
              voiceTitle: 'Ability Search',
              voiceHint: 'Say an ability name...',
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          const SizedBox(height: 10),

          // Abilities list
          Expanded(
            child: abilitiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load abilities:\n$e')),
              data: (allAbilities) {
                final filtered = allAbilities.where((a) {
                  if (_query.isNotEmpty) {
                    final q = _query;
                    final matchesName = a.name.toLowerCase().contains(q);
                    final matchesEff = a.eff?.toLowerCase().contains(q) ?? false;
                    final matchesFlav = a.flavor?.toLowerCase().contains(q) ?? false;
                    if (!matchesName && !matchesEff && !matchesFlav) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching abilities found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final ability = filtered[idx];
                    final isSelected = widget.currentAbility != null &&
                        widget.currentAbility!.toLowerCase() ==
                            ability.name.toLowerCase();

                    return InkWell(
                      onTap: () {
                        AppFeedback.selectionClick();
                        Navigator.of(context).pop(ability.name);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF059669))
                                  .withValues(alpha: isDark ? 0.18 : 0.09)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669))
                                : (isDark
                                    ? Colors.white10
                                    : Colors.grey.shade300),
                            width: isSelected ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFF059669))
                                        .withValues(alpha: 0.22)
                                    : (isDark
                                        ? Colors.white10
                                        : Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  isSelected
                                      ? LucideIcons.check
                                      : LucideIcons.sparkles,
                                  size: 16,
                                  color: isSelected
                                      ? (isDark
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF059669))
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          PokemonHelpers.formatName(ability.name),
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? (isDark
                                                    ? const Color(0xFF34D399)
                                                    : const Color(0xFF059669))
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (ability.gen.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Gen ${ability.gen.toUpperCase()}',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (ability.eff != null ||
                                      ability.flavor != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      ability.eff ?? ability.flavor ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.3,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ITEM PICKER SHEET (Supports National Dex & Champions Dex)
// =============================================================================

class _ItemPickerSheet extends ConsumerStatefulWidget {
  final String? currentItem;

  const _ItemPickerSheet({required this.currentItem});

  @override
  ConsumerState<_ItemPickerSheet> createState() => _ItemPickerSheetState();
}

class _ItemPickerSheetState extends ConsumerState<_ItemPickerSheet> {
  String _query = '';
  int _dexScope = 0; // 0 = Champions Dex, 1 = National Dex
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default to active app championsMode
    final isChampions = ref.read(championsModeProvider);
    _dexScope = isChampions ? 0 : 1;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemsAsync = ref.watch(itemsSeedProvider);
    final legalSlugs =
        ref.watch(championsDataProvider).value?.itemSlugs ?? const <String>{};

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Held Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                if (widget.currentItem != null)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('Clear Item',
                        style: TextStyle(color: Colors.redAccent)),
                  )
                else
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search items (e.g. Leftovers, Life Orb)...',
              voiceTitle: 'Held Item Search',
              voiceHint: 'Say an item name...',
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          const SizedBox(height: 10),

          // Dex Scope Switcher: Champions Dex vs National Dex
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildScopeChip(
                  label: 'Champions Dex (${legalSlugs.length})',
                  selected: _dexScope == 0,
                  isDark: isDark,
                  onTap: () => setState(() => _dexScope = 0),
                ),
                const SizedBox(width: 8),
                _buildScopeChip(
                  label: 'National Dex',
                  selected: _dexScope == 1,
                  isDark: isDark,
                  onTap: () => setState(() => _dexScope = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Items list
          Expanded(
            child: itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load items:\n$e')),
              data: (allItems) {
                final filtered = allItems.where((item) {
                  if (_dexScope == 0) {
                    if (!legalSlugs.contains(item.name.toLowerCase())) {
                      return false;
                    }
                  }
                  if (_query.isNotEmpty) {
                    final q = _query;
                    final matchesName = item.name.toLowerCase().contains(q);
                    final matchesCat = item.cat.toLowerCase().contains(q);
                    final matchesEff =
                        item.eff?.toLowerCase().contains(q) ?? false;
                    if (!matchesName && !matchesCat && !matchesEff) return false;
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching items found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final item = filtered[idx];
                    final isSelected = widget.currentItem != null &&
                        widget.currentItem!.toLowerCase() ==
                            item.name.toLowerCase();

                    return InkWell(
                      onTap: () {
                        AppFeedback.selectionClick();
                        Navigator.of(context).pop(item.name);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF059669))
                                  .withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669))
                                : (isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: item.sprite != null
                                  ? Image.network(
                                      item.sprite!,
                                      fit: BoxFit.contain,
                                      cacheWidth: 64,
                                      errorBuilder: (_, _, _) => const Icon(
                                          LucideIcons.package,
                                          size: 18),
                                    )
                                  : const Icon(LucideIcons.package, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          PokemonHelpers.formatName(item.name),
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      if (item.cat.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white10
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.cat,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (item.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        height: 1.3,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? const Color(0xFF34D399).withValues(alpha: 0.2)
                  : const Color(0xFF059669).withValues(alpha: 0.12))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : null,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MOVE PICKER SHEET (Supports Learnable, Champions Dex & National Dex)
// =============================================================================

class _MovePickerSheet extends ConsumerStatefulWidget {
  final Pokemon pokemon;
  final String? currentMove;
  final int slotIndex;

  const _MovePickerSheet({
    required this.pokemon,
    required this.currentMove,
    required this.slotIndex,
  });

  @override
  ConsumerState<_MovePickerSheet> createState() => _MovePickerSheetState();
}

class _MovePickerSheetState extends ConsumerState<_MovePickerSheet> {
  String _query = '';
  int _scope = 0; // 0 = Learnable Moves, 1 = Champions Dex, 2 = National Dex
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final movesAsync = ref.watch(movesSeedProvider);
    final rosterIds =
        ref.watch(championsDataProvider).value?.speciesIds ?? const <int>{};

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Move ${widget.slotIndex + 1}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                if (widget.currentMove != null && widget.currentMove!.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(''),
                    child: const Text('Clear Slot',
                        style: TextStyle(color: Colors.redAccent)),
                  )
                else
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search moves (e.g. Thunderbolt, Surf)...',
              voiceTitle: 'Move Voice Search',
              voiceHint: 'Say a move name...',
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          const SizedBox(height: 10),

          // Scope Switcher: Learnable vs Champions vs National
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildScopeChip(
                    label: 'Learnable Moves',
                    selected: _scope == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _scope = 0),
                  ),
                  const SizedBox(width: 8),
                  _buildScopeChip(
                    label: 'Champions Dex',
                    selected: _scope == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _scope = 1),
                  ),
                  const SizedBox(width: 8),
                  _buildScopeChip(
                    label: 'National Dex',
                    selected: _scope == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _scope = 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Moves list
          Expanded(
            child: movesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load moves:\n$e')),
              data: (allMoves) {
                final filtered = allMoves.where((move) {
                  if (_scope == 0) {
                    // Learnable by this Pokemon
                    final canLearn = move.learn.contains(widget.pokemon.id) ||
                        move.learnDetails
                            .any((ld) => ld.isNotEmpty && ld[0] == widget.pokemon.id);
                    if (!canLearn) return false;
                  } else if (_scope == 1) {
                    // Champions roster moves
                    final championsLegal = move.learn.any(rosterIds.contains);
                    if (!championsLegal) return false;
                  }

                  if (_query.isNotEmpty) {
                    final q = _query;
                    final matchesName = move.name.toLowerCase().contains(q);
                    final matchesType = move.type.toLowerCase().contains(q);
                    final matchesEff =
                        move.eff?.toLowerCase().contains(q) ?? false;
                    if (!matchesName && !matchesType && !matchesEff) return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No matching moves found',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, idx) {
                    final move = filtered[idx];
                    final isSelected = widget.currentMove != null &&
                        widget.currentMove!.toLowerCase() ==
                            move.name.toLowerCase();
                    final typeColor = AppColors.getTypeColor(move.type);

                    return InkWell(
                      onTap: () {
                        AppFeedback.selectionClick();
                        Navigator.of(context).pop(move.name);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? typeColor.withValues(alpha: 0.15)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? typeColor
                                : (isDark
                                    ? Colors.white10
                                    : Colors.grey.shade200),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Type icon container
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/types/${move.type}.svg',
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, _, _) => Icon(
                                    LucideIcons.zap,
                                    size: 16,
                                    color: typeColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          PokemonHelpers.formatName(move.name),
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      TypePill(move.type, fontSize: 10),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        move.cls.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: typeColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Pwr: ${move.power ?? '--'}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Acc: ${move.acc != null ? '${move.acc}%' : '--'}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'PP: ${move.pp ?? '--'}',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                  ? const Color(0xFF34D399).withValues(alpha: 0.2)
                  : const Color(0xFF059669).withValues(alpha: 0.12))
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : (isDark ? Colors.white12 : Colors.grey.shade300),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected
                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                : null,
          ),
        ),
      ),
    );
  }
}
