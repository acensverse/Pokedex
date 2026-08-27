import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../models/pokemon.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/type_chart.dart';
import 'section_header.dart';

class DefenseTab extends StatelessWidget {
  final List<PokemonTypeSlot> types;
  final Color themeColor;
  final Widget? header;

  const DefenseTab({
    super.key,
    required this.types,
    required this.themeColor,
    this.header,
  });

  Widget _buildDefenseCategory(String title, List<String> typesList, Color titleColor, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: typesList.map((type) {
              final typeColor = AppColors.getTypeColor(type);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(right: 6),
                      child: SvgPicture.asset('assets/types/${type}.svg'),
                    ),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeNames = types.map((t) => t.type.name).toList();
    final effectiveness = TypeChart.getEffectiveness(typeNames);
    
    final weakTo = <String>[];
    final veryWeakTo = <String>[];
    final normalTo = <String>[];
    final resistantTo = <String>[];
    final veryResistantTo = <String>[];
    final immuneTo = <String>[];
    
    effectiveness.forEach((type, multiplier) {
      if (multiplier == 4.0) {
        veryWeakTo.add(type);
      } else if (multiplier == 2.0) {
        weakTo.add(type);
      } else if (multiplier == 1.0) {
        normalTo.add(type);
      } else if (multiplier == 0.5) {
        resistantTo.add(type);
      } else if (multiplier == 0.25) {
        veryResistantTo.add(type);
      } else if (multiplier == 0.0) {
        immuneTo.add(type);
      }
    });

    return Column(
      key: const ValueKey('Defense'),
      children: [
        if (header != null) header!,
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 0, bottom: 16, left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title: 'Type Defenses', themeColor: themeColor),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16 + MediaQuery.paddingOf(context).bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (veryWeakTo.isNotEmpty) _buildDefenseCategory('Very Weak to (4×)', veryWeakTo, Colors.red.shade900, Colors.red.shade50),
                  if (weakTo.isNotEmpty) _buildDefenseCategory('Weak to (2×)', weakTo, Colors.red.shade700, Colors.red.shade50),
                  if (normalTo.isNotEmpty) _buildDefenseCategory('Normal Damage (1×)', normalTo, Colors.blueGrey.shade700, Colors.blueGrey.shade50),
                  if (resistantTo.isNotEmpty) _buildDefenseCategory('Resistant to (½×)', resistantTo, Colors.brown.shade700, Colors.orange.shade50),
                  if (veryResistantTo.isNotEmpty) _buildDefenseCategory('Strongly Resistant to (¼×)', veryResistantTo, Colors.green.shade700, Colors.green.shade50),
                  if (immuneTo.isNotEmpty) _buildDefenseCategory('No Effect (0×)', immuneTo, Colors.grey.shade700, Colors.grey.shade100),
                ],
              ),
            ),
          ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
