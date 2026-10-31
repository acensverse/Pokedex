import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/utils/type_chart.dart';
import 'widgets/tool_widgets.dart';
import 'widgets/type_picker_sheet.dart';
import '../pokedex/widgets/tools_sheet.dart';

/// "Damage taken / Damage dealt" interactive explorer for one or two types.
class TypesScreen extends ConsumerStatefulWidget {
  const TypesScreen({super.key});

  @override
  ConsumerState<TypesScreen> createState() => _TypesScreenState();
}

class _TypesScreenState extends ConsumerState<TypesScreen> {
  String? _type1;
  String? _type2;
  // 0: Defensive (Damage Taken), 1: Offensive (Damage Dealt)
  int _viewMode = 0;
  // Selected attacker when viewing offensive mode with dual types
  int _offensiveTypeSlot = 1;

  Future<void> _pickType(int slot) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TypePickerSheet(
        title: 'Select Type $slot',
        selectedType: slot == 1 ? _type1 : _type2,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final value = picked.isEmpty ? null : picked;
      if (slot == 1) {
        _type1 = value;
      } else {
        _type2 = value;
      }
      if (_type1 != null && _type1 == _type2) {
        _type2 = null;
      }
    });
  }

  void _clearType(int slot) {
    AppFeedback.lightImpact();
    setState(() {
      if (slot == 1) {
        _type1 = _type2;
        _type2 = null;
      } else {
        _type2 = null;
      }
    });
  }

  void _swapTypes() {
    if (_type1 == null || _type2 == null) return;
    AppFeedback.selectionClick();
    setState(() {
      final temp = _type1;
      _type1 = _type2;
      _type2 = temp;
    });
  }

  void _resetAll() {
    AppFeedback.lightImpact();
    setState(() {
      _type1 = null;
      _type2 = null;
      _viewMode = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _type1 != null || _type2 != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Type Coverage'),
        actions: [
          if (hasSelection)
            IconButton(
              icon: Icon(
                LucideIcons.rotateCcw,
                size: 20,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
              ),
              tooltip: 'Reset Types',
              onPressed: _resetAll,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Dual Type Nexus Selector
          _buildTypeSelectorHero(isDark),
          const SizedBox(height: 16),

          if (!hasSelection)
            _buildEmptyState(isDark)
          else ...[
            // Mode Segmented Switcher (Defensive vs Offensive)
            _buildModeSwitcher(isDark),
            const SizedBox(height: 20),

            // Content body based on mode
            if (_viewMode == 0)
              _buildDefensiveView(isDark)
            else
              _buildOffensiveView(isDark),
          ],
        ],
      ),
    );
  }

  // ---- Hero Type Selectors -----------------------------------------------

  Widget _buildTypeSelectorHero(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
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
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTypeSlotCard(
                  slot: 1,
                  type: _type1,
                  placeholder: 'Primary Type',
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      _type1 != null && _type2 != null
                          ? LucideIcons.arrowLeftRight
                          : LucideIcons.plus,
                      size: 15,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildTypeSlotCard(
                  slot: 2,
                  type: _type2,
                  placeholder: 'Secondary',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (_type1 != null && _type2 != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _swapTypes,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.arrowLeftRight,
                          size: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Swap Types',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
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

  Widget _buildTypeSlotCard({
    required int slot,
    required String? type,
    required String placeholder,
    required bool isDark,
  }) {
    final filled = type != null;
    final color = filled ? AppColors.getTypeColor(type) : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        AppFeedback.selectionClick();
        _pickType(slot);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filled
              ? color.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled
                ? color.withValues(alpha: isDark ? 0.8 : 0.6)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: filled ? 1.5 : 1.2,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: filled
            ? Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/types/$type.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type $slot',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.65),
                          ),
                        ),
                        Text(
                          '${type[0].toUpperCase()}${type.substring(1)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : color,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _clearType(slot),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context)
                            .iconTheme
                            .color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.plusCircle,
                      size: 16,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withValues(alpha: 0.45),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ---- Mode Switcher -----------------------------------------------------

  Widget _buildModeSwitcher(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              title: '🛡️ Defensive',
              subtitle: 'Damage Taken',
              isSelected: _viewMode == 0,
              isDark: isDark,
              onTap: () {
                AppFeedback.selectionClick();
                setState(() => _viewMode = 0);
              },
            ),
          ),
          Expanded(
            child: _buildModeTab(
              title: '⚔️ Offensive',
              subtitle: 'Damage Dealt',
              isSelected: _viewMode == 1,
              isDark: isDark,
              onTap: () {
                AppFeedback.selectionClick();
                setState(() => _viewMode = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final activeBg = isDark ? const Color(0xFF2B303E) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Defensive View ----------------------------------------------------

  Widget _buildDefensiveView(bool isDark) {
    final defenders = [?_type1, ?_type2];
    final eff = TypeChart.getEffectiveness(defenders);

    final veryWeak = <String>[];
    final weak = <String>[];
    final resist = <String>[];
    final veryResist = <String>[];
    final immune = <String>[];
    final normal = <String>[];

    eff.forEach((attacker, multiplier) {
      if (multiplier == 4.0) {
        veryWeak.add(attacker);
      } else if (multiplier == 2.0) {
        weak.add(attacker);
      } else if (multiplier == 0.5) {
        resist.add(attacker);
      } else if (multiplier == 0.25) {
        veryResist.add(attacker);
      } else if (multiplier == 0.0) {
        immune.add(attacker);
      } else {
        normal.add(attacker);
      }
    });

    final comboName = defenders
        .map((t) => '${t[0].toUpperCase()}${t.substring(1)}')
        .join(' / ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              Icon(
                LucideIcons.shield,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Defensive Profile: $comboName',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (veryWeak.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Critical Weakness',
            multiplier: '4× DMG',
            description: 'Takes quadruple damage',
            accentColor: const Color(0xFFE53935),
            types: veryWeak,
            isDark: isDark,
          ),
        if (weak.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Weakness',
            multiplier: '2× DMG',
            description: 'Takes double damage',
            accentColor: const Color(0xFFFF7043),
            types: weak,
            isDark: isDark,
          ),
        if (resist.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Resistance',
            multiplier: '½× DMG',
            description: 'Takes half damage',
            accentColor: const Color(0xFF43A047),
            types: resist,
            isDark: isDark,
          ),
        if (veryResist.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Super Resistance',
            multiplier: '¼× DMG',
            description: 'Takes quarter damage',
            accentColor: const Color(0xFF00ACC1),
            types: veryResist,
            isDark: isDark,
          ),
        if (immune.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Immunity',
            multiplier: '0× DMG',
            description: 'Completely immune (no damage)',
            accentColor: const Color(0xFF7E57C2),
            types: immune,
            isDark: isDark,
          ),
        if (normal.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Normal Effectiveness',
            multiplier: '1× DMG',
            description: 'Takes regular damage',
            accentColor: isDark ? Colors.white60 : Colors.blueGrey,
            types: normal,
            isDark: isDark,
          ),
      ],
    );
  }

  // ---- Offensive View ----------------------------------------------------

  Widget _buildOffensiveView(bool isDark) {
    final activeAttacker = (_offensiveTypeSlot == 1 ? _type1 : _type2) ??
        _type1 ??
        _type2;

    if (activeAttacker == null) return const SizedBox.shrink();

    final superEffective = <String>[];
    final notEffective = <String>[];
    final immune = <String>[];
    final normal = <String>[];

    for (final defender in AppColors.typeColors.keys) {
      final multiplier =
          TypeChart.getEffectiveness([defender])[activeAttacker] ?? 1.0;
      if (multiplier > 1.0) {
        superEffective.add(defender);
      } else if (multiplier == 0.5) {
        notEffective.add(defender);
      } else if (multiplier == 0.0) {
        immune.add(defender);
      } else {
        normal.add(defender);
      }
    }

    final attackerName =
        '${activeAttacker[0].toUpperCase()}${activeAttacker.substring(1)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If dual types are present, show sub-tabs for Type 1 vs Type 2
        if (_type1 != null && _type2 != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildAttackerPill(
                  type: _type1!,
                  isSelected: _offensiveTypeSlot == 1,
                  isDark: isDark,
                  onTap: () {
                    AppFeedback.selectionClick();
                    setState(() => _offensiveTypeSlot = 1);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAttackerPill(
                  type: _type2!,
                  isSelected: _offensiveTypeSlot == 2,
                  isDark: isDark,
                  onTap: () {
                    AppFeedback.selectionClick();
                    setState(() => _offensiveTypeSlot = 2);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              Icon(
                LucideIcons.swords,
                size: 16,
                color: AppColors.getTypeColor(activeAttacker),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Offensive Coverage: $attackerName Moves',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (superEffective.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Super Effective Against',
            multiplier: '2× DMG',
            description: 'Deals double damage to these defender types',
            accentColor: const Color(0xFF43A047),
            types: superEffective,
            isDark: isDark,
          ),
        if (notEffective.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Not Very Effective Against',
            multiplier: '½× DMG',
            description: 'Deals half damage to these defender types',
            accentColor: const Color(0xFFFF7043),
            types: notEffective,
            isDark: isDark,
          ),
        if (immune.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'No Effect Against',
            multiplier: '0× DMG',
            description: 'Completely blocked by these defender types',
            accentColor: const Color(0xFF7E57C2),
            types: immune,
            isDark: isDark,
          ),
        if (normal.isNotEmpty)
          _buildEffectivenessGroupCard(
            title: 'Regular Damage To',
            multiplier: '1× DMG',
            description: 'Deals normal standard damage',
            accentColor: isDark ? Colors.white60 : Colors.blueGrey,
            types: normal,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildAttackerPill({
    required String type,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final color = AppColors.getTypeColor(type);
    final name = '${type[0].toUpperCase()}${type.substring(1)}';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.28 : 0.16)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/types/$type.svg', width: 18, height: 18),
            const SizedBox(width: 8),
            Text(
              '$name Attacks',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : color)
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Group Card --------------------------------------------------------

  Widget _buildEffectivenessGroupCard({
    required String title,
    required String multiplier,
    required String description,
    required Color accentColor,
    required List<String> types,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Aesthetic multiplier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  multiplier,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
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
                  '${types.length}',
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
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in types) TypePill(t, fontSize: 12)],
          ),
        ],
      ),
    );
  }

  // ---- Empty State -------------------------------------------------------

  Widget _buildEmptyState(bool isDark) {
    const popularTypes = [
      'fire',
      'water',
      'grass',
      'electric',
      'dragon',
      'steel',
      'fairy',
      'ghost',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: isDark ? 0.16 : 0.08),
            ),
            child: Center(
              child: Icon(
                LucideIcons.shieldCheck,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Type Coverage Matrix',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select a primary type (and optional secondary type) above to analyze defensive weaknesses, resistances, immunities, and offensive advantages.',
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
          const SizedBox(height: 24),
          Text(
            'OR QUICK PICK A POPULAR TYPE',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final t in popularTypes)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    AppFeedback.selectionClick();
                    setState(() => _type1 = t);
                  },
                  child: TypePill(t, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
