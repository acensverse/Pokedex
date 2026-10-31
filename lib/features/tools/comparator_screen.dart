import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../../models/pokemon.dart';
import 'widgets/pokemon_picker_sheet.dart';
import 'widgets/tool_widgets.dart';
import '../pokedex/widgets/tools_sheet.dart';

/// Male/female percentages from the species endpoint; null when unknown,
/// genderless, or offline.
final _genderRatioProvider =
    FutureProvider.family<({double male, double female})?, int>((
      ref,
      speciesId,
    ) async {
      final dio = ref.watch(dioClientProvider).dio;
      try {
        final res = await dio.get(
          'https://pokeapi.co/api/v2/pokemon-species/$speciesId',
        );
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
  int _effViewMode = 0; // 0: All 18 Types Matrix, 1: Categorized Summary

  /// Fixed per-slot theme colors: Slot 1 sapphire blue, Slot 2 ruby red.
  static const Color _p1 = Color(0xFF1E88E5);
  static const Color _p2 = Color(0xFFE53935);

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

  void _swapSlots() {
    if (_a == null && _b == null) return;
    AppFeedback.selectionClick();
    setState(() {
      final temp = _a;
      _a = _b;
      _b = temp;
    });
  }

  void _clearAll() {
    AppFeedback.lightImpact();
    setState(() {
      _a = null;
      _b = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ready = _a != null && _b != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Comparator'),
        actions: [
          if (_a != null || _b != null) ...[
            if (ready)
              IconButton(
                icon: Icon(
                  LucideIcons.arrowLeftRight,
                  size: 20,
                  color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                ),
                tooltip: 'Swap Pokémon',
                onPressed: _swapSlots,
              ),
            IconButton(
              icon: Icon(
                LucideIcons.rotateCcw,
                size: 20,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
              ),
              tooltip: 'Reset Both',
              onPressed: _clearAll,
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // Arena Head-to-Head Cards
            _buildArenaHeader(isDark),
            const SizedBox(height: 20),

            if (!ready)
              _buildEmptyState(isDark)
            else ...[
              // Species & Dimensions Section
              _buildSectionCard(
                title: 'Species',
                icon: LucideIcons.ruler,
                isDark: isDark,
                child: _speciesBody(_a!, _b!, isDark),
              ),
              const SizedBox(height: 20),

              // Base Stats Arena Section
              _buildSectionCard(
                title: 'Stats',
                icon: LucideIcons.barChart3,
                isDark: isDark,
                child: _statsBody(_a!, _b!, isDark),
              ),
              const SizedBox(height: 20),

              // Type Effectiveness Matchups Section
              _buildSectionCard(
                title: 'Type Effectiveness',
                icon: LucideIcons.shieldAlert,
                isDark: isDark,
                child: _effectivenessBody(_a!, _b!, isDark),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---- Arena Header ------------------------------------------------------

  Widget _buildArenaHeader(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _slotCard(1, _a, _p1, isDark)),
            const SizedBox(width: 14),
            Expanded(child: _slotCard(2, _b, _p2, isDark)),
          ],
        ),
        // Center VS Badge
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF263238), Color(0xFF102027)],
            ),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.white,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _slotCard(
    int slotNumber,
    Pokemon? pokemon,
    Color slotColor,
    bool isDark,
  ) {
    if (pokemon == null) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          AppFeedback.selectionClick();
          _pickSlot(slotNumber == 1);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
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
                    ? Colors.black.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
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
                  color: slotColor.withValues(alpha: isDark ? 0.16 : 0.08),
                  border: Border.all(
                    color: slotColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.plus,
                    size: 28,
                    color: slotColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pok\u00e9mon $slotNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 8),
              // Preserves exact text 'TAP TO SELECT' required by comparator_flow_test
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: slotColor.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: slotColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  'TAP TO SELECT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: slotColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final typeList = pokemon.types.map((t) => t.type.name).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        AppFeedback.selectionClick();
        _pickSlot(slotNumber == 1);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E212B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: slotColor.withValues(alpha: isDark ? 0.75 : 0.55),
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: slotColor.withValues(alpha: isDark ? 0.20 : 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row with ID badge & change indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: slotColor.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${pokemon.speciesId.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: slotColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.refreshCw,
                  size: 13,
                  color: Theme.of(context)
                      .iconTheme
                      .color
                      ?.withValues(alpha: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // High-res Home Artwork
            SizedBox(
              width: 86,
              height: 86,
              child: Image.asset(
                PokemonHelpers.getHomeAssetPath(pokemon.id),
                fit: BoxFit.contain,
                cacheWidth: PokemonHelpers.cacheWidth(context, 86),
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                  fit: BoxFit.contain,
                  cacheWidth: PokemonHelpers.cacheWidth(context, 86),
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.catching_pokemon, size: 48, color: slotColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              PokemonHelpers.formatName(pokemon.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final t in typeList)
                  TypePill(t, fontSize: 10.5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- Section Card Wrapper ----------------------------------------------

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          // Section Title Header
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ---- Species Body ------------------------------------------------------

  Widget _speciesBody(Pokemon a, Pokemon b, bool isDark) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _speciesColumn(a, _p1, isDark)),
            Container(
              width: 1,
              height: 120,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
            ),
            Expanded(child: _speciesColumn(b, _p2, isDark)),
          ],
        ),
      ],
    );
  }

  Widget _speciesColumn(Pokemon p, Color slotColor, bool isDark) {
    final genderAsync = ref.watch(_genderRatioProvider(p.speciesId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          _measureBadge(
            icon: LucideIcons.ruler,
            label: 'Height',
            value: _heightLabel(p.height),
            slotColor: slotColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _measureBadge(
            icon: LucideIcons.weight,
            label: 'Weight',
            value: _weightLabel(p.weight),
            slotColor: slotColor,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          genderAsync.when(
            data: (ratio) => ratio == null
                ? const SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        'Genderless',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      GenderDonut(
                        malePercent: ratio.male,
                        femalePercent: ratio.female,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.male, size: 13, color: Colors.blueAccent),
                          Text(
                            ' ${ratio.male.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.female, size: 13, color: Colors.pinkAccent),
                          Text(
                            ' ${ratio.female.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
            loading: () => const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox(height: 48),
          ),
        ],
      ),
    );
  }

  Widget _measureBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color slotColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: slotColor,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
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

  // ---- Stats Arena -------------------------------------------------------

  Widget _statsBody(Pokemon a, Pokemon b, bool isDark) {
    const labels = [
      'HP',
      'Attack',
      'Defense',
      'Sp. Attack',
      'Sp. Defense',
      'Speed',
    ];
    const colorA = _p1;
    const colorB = _p2;

    final totalA = _sumStats(a);
    final totalB = _sumStats(b);
    final totalDiff = (totalA - totalB).abs();

    return Column(
      children: [
        // Mode Selector: Base / Min / Max
        _buildStatsSegmentedControl(isDark),
        const SizedBox(height: 18),

        // Stat by Stat Comparison
        for (var i = 0; i < labels.length; i++) ...[
          _buildCompareStatRow(
            labels[i],
            _statValue(a.stats, labels[i]),
            _statValue(b.stats, labels[i]),
            colorA,
            colorB,
            isDark,
          ),
          if (i < labels.length - 1) const SizedBox(height: 12),
        ],

        const SizedBox(height: 18),
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
        ),
        const SizedBox(height: 14),

        // Base Stat Total (BST) Showdown Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 80,
                child: Text(
                  'Total BST',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  totalA > totalB
                      ? '${PokemonHelpers.formatName(a.name)} wins (+$totalDiff)'
                      : (totalB > totalA
                          ? '${PokemonHelpers.formatName(b.name)} wins (+$totalDiff)'
                          : 'Evenly matched total'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: totalA > totalB
                        ? colorA
                        : (totalB > totalA
                            ? colorB
                            : Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalA',
                    style: TextStyle(
                      color: colorA,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  Text(
                    ' / ',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black26,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$totalB',
                    style: TextStyle(
                      color: colorB,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B303E) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: switch (_statsMode) {
              'Min' => Alignment.center,
              'Max' => Alignment.centerRight,
              _ => Alignment.centerLeft,
            },
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E212B) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (final mode in ['Base', 'Min', 'Max'])
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      AppFeedback.selectionClick();
                      setState(() => _statsMode = mode);
                    },
                    child: Container(
                      height: 32,
                      alignment: Alignment.center,
                      child: Text(
                        mode,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _statsMode == mode
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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

  Widget _buildCompareStatRow(
    String label,
    int baseA,
    int baseB,
    Color colorA,
    Color colorB,
    bool isDark,
  ) {
    final valA = _displayedValue(label, baseA);
    final valB = _displayedValue(label, baseB);
    final max = _maxFor(label);

    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildStatBar(colorA, valA, max, isDark),
              const SizedBox(height: 4),
              _buildStatBar(colorB, valB, max, isDark),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 44,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$valA',
                style: TextStyle(
                  color: colorA,
                  fontWeight: valA >= valB ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Text(
                '$valB',
                style: TextStyle(
                  color: colorB,
                  fontWeight: valB >= valA ? FontWeight.w900 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatBar(Color color, int value, int max, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
        return Stack(
          children: [
            Container(
              height: 7,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 7,
              width: constraints.maxWidth * fraction,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---- Type Effectiveness Body --------------------------------------------

  Widget _effectivenessBody(Pokemon a, Pokemon b, bool isDark) {
    final typesA = a.types.map((t) => t.type.name).toList();
    final typesB = b.types.map((t) => t.type.name).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-switcher: All 18 Types Matrix vs Categorized
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2B303E) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    AppFeedback.selectionClick();
                    setState(() => _effViewMode = 0);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _effViewMode == 0
                          ? (isDark ? const Color(0xFF1E212B) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: _effViewMode == 0
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.08,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'All 18 Types Matrix',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _effViewMode == 0
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _effViewMode == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    AppFeedback.selectionClick();
                    setState(() => _effViewMode = 1);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _effViewMode == 1
                          ? (isDark ? const Color(0xFF1E212B) : Colors.white)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: _effViewMode == 1
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.25 : 0.08,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      'Grouped Categories',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _effViewMode == 1
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _effViewMode == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_effViewMode == 0)
          _buildAll18TypesMatrix(a, b, typesA, typesB, isDark)
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _effectivenessColumn(
                  PokemonHelpers.formatName(a.name),
                  typesA,
                  _p1,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _effectivenessColumn(
                  PokemonHelpers.formatName(b.name),
                  typesB,
                  _p2,
                  isDark,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Complete 18-type head-to-head comparison table
  Widget _buildAll18TypesMatrix(
    Pokemon a,
    Pokemon b,
    List<String> typesA,
    List<String> typesB,
    bool isDark,
  ) {
    final effA = TypeChart.getEffectiveness(typesA);
    final effB = TypeChart.getEffectiveness(typesB);

    const all18Types = [
      'normal',
      'fire',
      'water',
      'grass',
      'electric',
      'ice',
      'fighting',
      'poison',
      'ground',
      'flying',
      'psychic',
      'bug',
      'rock',
      'ghost',
      'dragon',
      'dark',
      'steel',
      'fairy',
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    PokemonHelpers.formatName(a.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _p1,
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Attacking Type',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    PokemonHelpers.formatName(b.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: _p2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
          // 18 Type Rows
          for (var i = 0; i < all18Types.length; i++) ...[
            _buildMatrixTypeRow(
              all18Types[i],
              effA[all18Types[i]] ?? 1.0,
              effB[all18Types[i]] ?? 1.0,
              isDark,
            ),
            if (i < all18Types.length - 1)
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.shade100,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatrixTypeRow(
    String type,
    double multA,
    double multB,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Center(child: _multiplierBadge(multA, _p1, isDark)),
          ),
          Expanded(
            child: Center(child: TypePill(type, fontSize: 10)),
          ),
          SizedBox(
            width: 60,
            child: Center(child: _multiplierBadge(multB, _p2, isDark)),
          ),
        ],
      ),
    );
  }

  Widget _multiplierBadge(double mult, Color slotAccent, bool isDark) {
    final (label, color) = switch (mult) {
      4.0 => ('4×', const Color(0xFFE53935)),
      2.0 => ('2×', const Color(0xFFFF7043)),
      0.5 => ('½×', const Color(0xFF43A047)),
      0.25 => ('¼×', const Color(0xFF00ACC1)),
      0.0 => ('0×', const Color(0xFF7E57C2)),
      _ => ('1×', isDark ? Colors.white60 : Colors.blueGrey.shade600),
    };

    final isNonNormal = mult != 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNonNormal
            ? color.withValues(alpha: isDark ? 0.22 : 0.12)
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(8),
        border: isNonNormal
            ? Border.all(color: color.withValues(alpha: 0.4), width: 1)
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isNonNormal ? FontWeight.w900 : FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _effectivenessColumn(
    String pokemonName,
    List<String> types,
    Color slotColor,
    bool isDark,
  ) {
    final eff = TypeChart.getEffectiveness(types);
    final veryWeak = <String>[];
    final weak = <String>[];
    final normal = <String>[];
    final resist = <String>[];
    final veryResist = <String>[];
    final immune = <String>[];

    for (final type in AppColors.typeColors.keys) {
      final multiplier = eff[type] ?? 1.0;
      if (multiplier == 4.0) {
        veryWeak.add(type);
      } else if (multiplier == 2.0) {
        weak.add(type);
      } else if (multiplier == 0.5) {
        resist.add(type);
      } else if (multiplier == 0.25) {
        veryResist.add(type);
      } else if (multiplier == 0.0) {
        immune.add(type);
      } else {
        normal.add(type);
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: slotColor.withValues(alpha: isDark ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: slotColor.withValues(alpha: isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pokemonName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: slotColor,
            ),
          ),
          const SizedBox(height: 10),
          for (final group in [
            ('Critical (4×):', const Color(0xFFE53935), veryWeak),
            ('Weak (2×):', const Color(0xFFFF7043), weak),
            ('Normal (1×):', isDark ? Colors.white70 : Colors.blueGrey, normal),
            ('Resist (½×):', const Color(0xFF43A047), resist),
            ('Resist (¼×):', const Color(0xFF00ACC1), veryResist),
            ('Immune (0×):', const Color(0xFF7E57C2), immune),
          ])
            if (group.$3.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    group.$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: group.$2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${group.$3.length})',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (final t in group.$3) TypePill(t, fontSize: 10),
                ],
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
  // ---- Empty State -------------------------------------------------------

  Widget _buildEmptyState(bool isDark) {
    return Container(
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
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: isDark ? 0.16 : 0.08),
            ),
            child: Center(
              child: Icon(
                LucideIcons.swords,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Pok\u00e9mon Comparison Arena',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Select any two Pok\u00e9mon above to see head-to-head base stat differences, dimension comparisons, and dual defensive coverage side by side.',
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
        ],
      ),
    );
  }
}
