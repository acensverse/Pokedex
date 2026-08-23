import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../../models/pokemon.dart';
import 'widgets/pokemon_picker_sheet.dart';
import 'widgets/tool_widgets.dart';

/// Male/female percentages from the species endpoint; null when unknown,
/// genderless, or offline.
final _genderRatioProvider =
    FutureProvider.family<({double male, double female})?, int>((ref, speciesId) async {
  final dio = ref.watch(dioClientProvider).dio;
  try {
    final res = await dio.get('https://pokeapi.co/api/v2/pokemon-species/$speciesId');
    final rate = res.data['gender_rate'];
    if (rate is! int || rate < 0) return null;
    return (male: (8 - rate) / 8 * 100, female: rate / 8 * 100);
  } catch (_) {
    return null;
  }
});

class ComparatorScreen extends ConsumerStatefulWidget {
  const ComparatorScreen({super.key});

  @override
  ConsumerState<ComparatorScreen> createState() => _ComparatorScreenState();
}

class _ComparatorScreenState extends ConsumerState<ComparatorScreen> {
  Pokemon? _a;
  Pokemon? _b;
  String _statsMode = 'Base';

  Future<void> _pickSlot(bool slotA) async {
    final picked = await PokemonPickerSheet.show(context);
    if (!mounted || picked == null) return;
    setState(() => slotA ? _a = picked : _b = picked);
    if (_a != null && _a!.id == _b?.id) {
      setState(() {
        if (slotA) _b = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _a != null && _b != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Comparator',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 24)),
        actions: [
          if (ready)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {
                _a = null;
                _b = null;
              }),
            ),
        ],
      ),
      body: !ready
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _slotCard(context, 1, _a)),
                    const SizedBox(width: 12),
                    Expanded(child: _slotCard(context, 2, _b)),
                  ],
                ),
                if (!(_a != null || _b != null)) ...[
                  const SizedBox(height: 48),
                  Center(child: ToolsIllustration()),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Select Pok\u00e9mon to compare',
                        style:
                            TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Choose two Pok\u00e9mon to see their stats and type '
                        'effectiveness side by side',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ],
            )
          : _comparison(),
    );
  }

  Widget _slotCard(BuildContext context, int slotNumber, Pokemon? pokemon) {
    if (pokemon == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _pickSlot(slotNumber == 1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.catching_pokemon, size: 44, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 14),
              Text('Pok\u00e9mon $slotNumber',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                child: Text('TAP TO SELECT',
                    style: TextStyle(
                        fontSize: 9, letterSpacing: 1, color: Colors.grey.shade600)),
              ),
            ],
          ),
        ),
      );
    }

    final typeList = pokemon.types.map((t) => t.type.name).toList();
    final primaryColor = AppColors.getTypeColor(typeList.first);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _pickSlot(slotNumber == 1),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border(bottom: BorderSide(color: primaryColor, width: 5)),
        ),
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 3),
                color: Colors.white.withValues(alpha: 0.7),
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    Icon(Icons.catching_pokemon, size: 40, color: primaryColor),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              PokemonHelpers.formatName(pokemon.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [for (final t in typeList) ...[
                TypeBadgeDot(t, size: 18),
                const SizedBox(width: 4),
              ]],
            ),
            const SizedBox(height: 6),
            Text('#${pokemon.id.toString().padLeft(3, '0')}',
                style: TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _comparison() {
    final a = _a!;
    final b = _b!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _slotCard(context, 1, a)),
              const SizedBox(width: 12),
              Expanded(child: _slotCard(context, 2, b)),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              _whiteCard(paddingTop: 30, child: _speciesBody(a, b)),
              const SectionHeaderPill('Species'),
            ],
          ),
          const SizedBox(height: 28),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              _whiteCard(paddingTop: 30, child: _statsBody(a, b)),
              const SectionHeaderPill('Stats'),
            ],
          ),
          const SizedBox(height: 28),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              _whiteCard(paddingTop: 30, child: _effectivenessBody(a, b)),
              const SectionHeaderPill('Type Effectiveness'),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child, double paddingTop = 0}) {
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

  // ---- Species -----------------------------------------------------------

  Widget _speciesBody(Pokemon a, Pokemon b) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _speciesColumn(a)),
            Expanded(child: _speciesColumn(b)),
          ],
        ),
      ],
    );
  }

  Widget _speciesColumn(Pokemon p) {
    final genderAsync = ref.watch(_genderRatioProvider(p.speciesId));
    return Column(
      children: [
        Image.asset(
          PokemonHelpers.getHomeAssetPath(p.id),
          width: 110,
          height: 110,
          errorBuilder: (_, _, _) => Image.asset(
            PokemonHelpers.getThumbnailAssetPath(p.id),
            width: 90,
            height: 90,
            errorBuilder: (_, _, _) =>
                Icon(Icons.catching_pokemon, size: 64, color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(height: 10),
        _measureRow(Icons.straighten, _heightLabel(p.height)),
        const SizedBox(height: 8),
        _measureRow(Icons.monitor_weight_outlined, _weightLabel(p.weight)),
        const SizedBox(height: 12),
        genderAsync.when(
          data: (ratio) => ratio == null
              ? const SizedBox(height: 56)
              : Column(
                  children: [
                    GenderDonut(malePercent: ratio.male, femalePercent: ratio.female),
                    const SizedBox(height: 4),
                    Text('\u2642 ${ratio.male.toStringAsFixed(1)}%   \u2640 ${ratio.female.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
          loading: () => const SizedBox(
              height: 56, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          error: (_, _) => const SizedBox(height: 56),
        ),
      ],
    );
  }

  String _heightLabel(int decimetres) {
    final totalInches = decimetres / 10.0 * 39.3701;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    final normalizedFeet = inches == 12 ? feet + 1 : feet;
    final normalizedInches = inches == 12 ? 0 : inches;
    return '$normalizedFeet\'$normalizedInches"';
  }

  String _weightLabel(int hectograms) =>
      '${(hectograms / 10.0 * 2.20462).toStringAsFixed(1)} lbs';

  Widget _measureRow(IconData icon, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ---- Stats -------------------------------------------------------------

  Widget _statsBody(Pokemon a, Pokemon b) {
    const labels = ['HP', 'Attack', 'Defense', 'Sp. Attack', 'Sp. Defense', 'Speed'];
    final colorA = AppColors.getTypeColor(a.types.first.type.name);
    final colorB = AppColors.getTypeColor(b.types.first.type.name);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    for (final mode in ['Base', 'Min', 'Max'])
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _statsMode = mode),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: _statsMode == mode ? colorA : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(mode,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _statsMode == mode ? Colors.white : Colors.black45)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Icon(Icons.trending_up, color: colorB, size: 22),
          ],
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < labels.length; i++) ...[
          _compareStatRow(labels[i], _statValue(a.stats, labels[i]),
              _statValue(b.stats, labels[i]), colorA, colorB),
          const SizedBox(height: 12),
        ],
        const Divider(height: 24),
        Row(
          children: [
            const SizedBox(
                width: 78,
                child: Text('Total:',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w800))),
            const Expanded(child: SizedBox()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${_sumStats(a)}', style: TextStyle(color: colorA, fontWeight: FontWeight.w700, fontSize: 12)),
                Text('${_sumStats(b)}', style: TextStyle(color: colorB, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          '*Base stats range from values of 1 to 255. They are the prime '
          'representation of the potential a Pok\u00e9mon species has in battle.',
          style: TextStyle(fontSize: 10.5, color: Colors.black45),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _statValue(List<PokemonStatSlot> stats, String label) {
    const keyByLabel = {
      'HP': 'hp',
      'Attack': 'attack',
      'Defense': 'defense',
      'Sp. Attack': 'special-attack',
      'Sp. Defense': 'special-defense',
      'Speed': 'speed',
    };
    final key = keyByLabel[label]!;
    for (final s in stats) {
      if (s.stat.name == key) return s.baseStat;
    }
    return 0;
  }

  int _sumStats(Pokemon p) {
    var sum = 0;
    for (final s in p.stats) {
      sum += s.baseStat;
    }
    return sum;
  }

  int _displayedValue(String label, int base) {
    switch (_statsMode) {
      case 'Min':
        return label == 'HP' ? base * 2 + 110 : ((base * 2 + 5) * 0.9).toInt();
      case 'Max':
        return label == 'HP' ? base * 2 + 204 : ((base * 2 + 99) * 1.1).toInt();
      default:
        return base;
    }
  }

  int _maxFor(String label) {
    if (_statsMode == 'Base') return 255;
    return label == 'HP' ? 714 : 504;
  }

  Widget _compareStatRow(String label, int baseA, int baseB, Color colorA, Color colorB) {
    return Row(
      children: [
        SizedBox(
            width: 78,
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.black87))),
        Expanded(
          child: Column(
            children: [
              _bar(colorA, _displayedValue(label, baseA), _maxFor(label)),
              const SizedBox(height: 4),
              _bar(colorB, _displayedValue(label, baseB), _maxFor(label)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 34,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${_displayedValue(label, baseA)}',
                  style: TextStyle(color: colorA, fontWeight: FontWeight.w700, fontSize: 12)),
              Text('${_displayedValue(label, baseB)}',
                  style: TextStyle(color: colorB, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar(Color color, int value, int max) {
    return LayoutBuilder(builder: (context, constraints) {
      final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
      return Stack(
        children: [
          Container(
            height: 9,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Container(
            height: 9,
            width: constraints.maxWidth * fraction,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      );
    });
  }

  // ---- Type effectiveness -------------------------------------------------

  Widget _effectivenessBody(Pokemon a, Pokemon b) {
    final typesA = a.types.map((t) => t.type.name).toList();
    final typesB = b.types.map((t) => t.type.name).toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _effectivenessColumn(a, typesA)),
        const SizedBox(width: 12),
        Expanded(child: _effectivenessColumn(b, typesB)),
      ],
    );
  }

  Widget _effectivenessColumn(Pokemon p, List<String> types) {
    final eff = TypeChart.getEffectiveness(types);
    final weak = <String>[];
    final resist = <String>[];
    final veryResist = <String>[];
    final immune = <String>[];
    eff.forEach((type, multiplier) {
      if (multiplier > 1) {
        weak.add(type);
      } else if (multiplier == 0.5) {
        resist.add(type);
      } else if (multiplier == 0.25) {
        veryResist.add(type);
      } else if (multiplier == 0.0) {
        immune.add(type);
      }
    });

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.getTypeColor(types.first).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final group in [
            ('Weak against:', '2x damage', weak),
            ('Resistant against:', '1/2x damage', resist),
            ('Very resistant against:', '1/4x damage', veryResist),
            ('Immune to:', '0x damage', immune),
          ])
            if (group.$3.isNotEmpty) ...[
              Text(group.$1,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              Text(group.$2,
                  style: const TextStyle(fontSize: 10, color: Colors.black45)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final t in group.$3) TypePill(t, fontSize: 11)],
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}
