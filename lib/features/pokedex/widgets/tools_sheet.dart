import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/feedback_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/champions.dart';
import '../pokedex_provider.dart';

class _ToolAction {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final String? route;

  const _ToolAction(this.label, this.icon, this.colors, [this.route]);
}

const Color _sheetRed = AppColors.primary;

/// Uniform vertical gap between every tab in the sheet — hero buttons and
/// grid rows all use this, so spacing stays identical everywhere.
const double _sheetGap = AppSpacing.md;

/// Purple gradient for the Champions Pokédex button and champions-mode
/// accents across the app.
const List<Color> championsGradient = [
  Color(0xFF9C27B0),
  Color(0xFF6A1B9A),
];

/// Clears every home-screen filter so switching Pokédex modes starts clean.
void _clearPokedexFilters(WidgetRef ref) {
  ref.read(selectedTypesProvider.notifier).state = [];
  ref.read(genFilterProvider.notifier).state = 0;
  ref.read(searchQueryProvider.notifier).state = '';
  ref.read(debouncedSearchQueryProvider.notifier).state = '';
  ref.read(toolLearnerFilterProvider.notifier).state = null;
  ref.read(toolAbilityFilterProvider.notifier).state = null;
  ref.read(toolMoveFilterProvider.notifier).state = null;
}

/// Tappable tool-screen header title (label + dropdown dot) that opens the
/// tools menu sheet — adapts its aesthetic color theme to the specific tool.
class ToolsSheetTitle extends StatelessWidget {
  final String label;
  final Color? color;

  const ToolsSheetTitle({
    super.key,
    required this.label,
    this.color,
  });

  /// Resolves the distinctive aesthetic theme color for each tool.
  static Color getAestheticColor(String label, {required bool isDark}) {
    final clean = label.trim().toLowerCase();
    if (clean.contains('move')) {
      return isDark ? const Color(0xFFFFA726) : const Color(0xFFE65100);
    }
    if (clean.contains('abilit')) {
      return isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00897B);
    }
    if (clean.contains('nature')) {
      return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1976D2);
    }
    if (clean.contains('item')) {
      return isDark ? const Color(0xFF26C6DA) : const Color(0xFF0097A7);
    }
    if (clean.contains('speed')) {
      return isDark ? const Color(0xFF4DB6AC) : const Color(0xFF00796B);
    }
    if (clean.contains('breed')) {
      return isDark ? const Color(0xFFF06292) : const Color(0xFFD81B60);
    }
    if (clean.contains('type')) {
      return isDark ? const Color(0xFF7986CB) : const Color(0xFF3F51B5);
    }
    if (clean.contains('compar')) {
      return isDark ? const Color(0xFFCE93D8) : const Color(0xFF8E24AA);
    }
    if (clean.contains('team')) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    }
    return isDark ? Colors.white : const Color(0xFF1E293B);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = color ?? getAestheticColor(label, isDark: isDark);

    return Semantics(
      button: true,
      label: 'Open tools menu',
      child: GestureDetector(
        onTap: () {
          AppFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const ToolsSheet(),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: themeColor,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: themeColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet opened from the POKEDEX header title.
class ToolsSheet extends ConsumerWidget {
  const ToolsSheet({super.key});

  void _handle(BuildContext context, _ToolAction action) {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (action.route != null) {
      router.push(action.route!);
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${action.label} \u2014 coming soon'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChampions = ref.watch(championsModeProvider);
    final gridTools = [
      _ToolAction('Moves', Icons.shield, const [
        Color(0xFFF57C00),
        Color(0xFFFFCA28),
      ], '/tools/moves'),
      _ToolAction('Abilities', Icons.diamond, const [
        Color(0xFF26A69A),
        Color(0xFF66BB6A),
      ], '/tools/abilities'),
      _ToolAction('Natures', Icons.eco, const [
        Color(0xFF1E88E5),
        Color(0xFF26C6DA),
      ], '/tools/natures'),
      _ToolAction('Items', Icons.backpack, const [
        Color(0xFF2196F3),
        Color(0xFF00BCD4),
      ], '/tools/items'),
      if (isChampions)
        _ToolAction('Speed Tiers', Icons.speed, const [
          Color(0xFF00897B),
          Color(0xFF4DB6AC),
        ], '/tools/speed-tiers')
      else
        _ToolAction('Breeding', Icons.egg, const [
          Color(0xFFEC407A),
          Color(0xFF8E24AA),
        ], '/tools/breeding'),
      _ToolAction('Types', Icons.layers, const [
        Color(0xFF3949AB),
        Color(0xFF7E57C2),
      ], '/tools/types'),
      _ToolAction('Team Builder', Icons.hub, const [
        Color(0xFFCDDC39),
        Color(0xFF26A69A),
      ], '/tools/teams'),
      _ToolAction('Comparator', Icons.compare_arrows, const [
        Color(0xFFBA68C8),
        Color(0xFF7E57C2),
      ], '/tools/comparator'),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _SheetButton(
                label: 'Pok\u00e9dex',
                icon: Icons.catching_pokemon,
                colors: const [Color(0xFFEF5350), _sheetRed],
                height: 56,
                isActive: !isChampions,
                onTap: () async {
                  // Clear active filters and leave champions mode
                  _clearPokedexFilters(ref);
                  ref.read(championsModeProvider.notifier).state = false;
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/');
                  }
                },
              ),
              const SizedBox(height: _sheetGap),
              _SheetButton(
                label: 'Champions Pok\u00e9dex',
                icon: Icons.emoji_events,
                colors: championsGradient,
                height: 56,
                isActive: isChampions,
                onTap: () async {
                  // Clear active filters and scope everything to the
                  // Champions roster
                  _clearPokedexFilters(ref);
                  ref.read(championsModeProvider.notifier).state = true;
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/');
                  }
                },
              ),
              const SizedBox(height: _sheetGap),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: _sheetGap,
                crossAxisSpacing: AppSpacing.sm + 2,
                childAspectRatio: 3.0,
                children: [
                  for (final tool in gridTools)
                    _SheetButton(
                      label: tool.label,
                      icon: tool.icon,
                      colors: tool.colors,
                      onTap: () => _handle(context, tool),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? customIconPath;
  final List<Color>? colors;
  final VoidCallback onTap;
  final double height;
  final bool isActive;

  const _SheetButton({
    required this.label,
    this.icon,
    this.colors,
    required this.onTap,
    this.height = 48,
    this.isActive = false,
  }) : customIconPath = null;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          AppFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: colors ?? [Colors.grey, Colors.grey],
            ),
            borderRadius: BorderRadius.circular(14),
            border: isActive
                ? Border.all(color: Colors.white, width: 2.5)
                : Border.all(color: Colors.transparent, width: 2.5),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              if (icon != null)
                Positioned(
                  right: -6,
                  bottom: -height * 0.22,
                  child: Icon(
                    icon,
                    size: height * 1.05,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              if (customIconPath != null)
                Positioned(
                  right: 8,
                  top: 8,
                  bottom: 8,
                  child: Opacity(
                    opacity: 0.35,
                    child: Image.asset(customIconPath!, fit: BoxFit.contain),
                  ),
                ),

              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      fontSize: 15,
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
}

