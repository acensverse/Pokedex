import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/type_chart.dart';
import 'widgets/tool_widgets.dart';
import 'widgets/type_picker_sheet.dart';
import '../pokedex/widgets/tools_sheet.dart';

/// "Damage taken / Damage dealt" explorer for one or two selected types.
class TypesScreen extends ConsumerStatefulWidget {
  const TypesScreen({super.key});

  @override
  ConsumerState<TypesScreen> createState() => _TypesScreenState();
}

class _TypesScreenState extends ConsumerState<TypesScreen> {
  String? _type1;
  String? _type2;

  Future<void> _pickType(int slot) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TypePickerSheet(
        title: 'Type $slot',
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
      if (_type1 != null && _type1 == _type2) _type2 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _type1 != null || _type2 != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Types'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _typePillButton(1, _type1),
              const SizedBox(width: 12),
              _typePillButton(2, _type2),
            ],
          ),
          if (!hasSelection)
            const _EmptyTypesView()
          else ...[
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                _resultsCard(
                  paddingTop: 30,
                  child: _damageTakenBody(_type1, _type2),
                ),
                const SectionHeaderPill('Damage taken'),
              ],
            ),
            if (_type1 != null) ...[
              const SizedBox(height: 28),
              _dealtSection(_type1!),
            ],
            if (_type2 != null) ...[
              const SizedBox(height: 28),
              _dealtSection(_type2!),
            ],
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  Widget _typePillButton(int slot, String? type) {
    final filled = type != null;
    final color = filled ? AppColors.getTypeColor(type) : Colors.grey.shade400;
    return InkWell(
      borderRadius: BorderRadius.circular(21),
      onTap: () => _pickType(slot),
      child: Container(
        height: 42,
        padding: EdgeInsets.symmetric(horizontal: filled ? 16 : 20),
        decoration: BoxDecoration(
          color: filled ? color.withValues(alpha: 0.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(21),
          border: filled ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filled) ...[
              SvgPicture.asset('assets/types/$type.svg', width: 20, height: 20),
              const SizedBox(width: 8),
            ],
            Text(
              filled
                  ? '${type[0].toUpperCase()}${type.substring(1)}'
                  : 'Type $slot',
              style: TextStyle(
                color: filled ? color : Colors.grey.shade600,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultsCard({required Widget child, double paddingTop = 0}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: EdgeInsets.fromLTRB(16, paddingTop + 2, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _EmptyTypesView extends StatelessWidget {
  const _EmptyTypesView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 56),
        const Center(child: ToolsIllustration()),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Select a type to start',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Once selected at least one type, you can check its "
              "weaknesses and strengths",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

extension _DamageBuckets on _TypesScreenState {
  Widget _group(String title, String subtitle, List<String> types) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in types) TypePill(t)],
          ),
        ],
      ),
    );
  }

  Widget _damageTakenBody(String? type1, String? type2) {
    final defenders = [?type1, ?type2];
    final eff = TypeChart.getEffectiveness(defenders);
    final weak = <String>[];
    final veryWeak = <String>[];
    final resist = <String>[];
    final veryResist = <String>[];
    final immune = <String>[];
    final normal = <String>[];
    eff.forEach((attacker, multiplier) {
      // 4x must be split out before the generic >1 check, otherwise dual
      // defenders show 4x matchups mislabeled as 2x.
      if (multiplier == 4.0) {
        veryWeak.add(attacker);
      } else if (multiplier > 1) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _group('Very weak against:', '4x damage', veryWeak),
        _group('Weak against:', '2x damage', weak),
        _group('Resistant against:', '1/2x damage', resist),
        _group('Very resistant against:', '1/4x damage', veryResist),
        _group('Immune to:', '0x damage', immune),
        _group('Normal damage from:', '1x damage', normal),
      ],
    );
  }

  Widget _dealtSection(String attacker) {
    final superEffective = <String>[];
    final weak = <String>[];
    final immune = <String>[];
    final normal = <String>[];
    for (final defender in AppColors.typeColors.keys) {
      final multiplier =
          TypeChart.getEffectiveness([defender])[attacker] ?? 1.0;
      if (multiplier > 1) {
        superEffective.add(defender);
      } else if (multiplier == 0.5) {
        weak.add(defender);
      } else if (multiplier == 0.0) {
        // Immune matchups were previously dropped entirely (Electric vs
        // Ground never appeared on the card).
        immune.add(defender);
      } else {
        normal.add(defender);
      }
    }

    final label = '${attacker[0].toUpperCase()}${attacker.substring(1)}';
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _group('Super effective against:', '2x damage', superEffective),
              _group('Weak against:', '1/2x damage', weak),
              _group('No effect against:', '0x damage', immune),
              _group('Normal damage to:', '1x damage', normal),
            ],
          ),
        ),
        SectionHeaderPill('Damage dealt: $label'),
      ],
    );
  }
}
