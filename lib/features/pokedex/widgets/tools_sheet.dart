import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class _ToolAction {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final String? route;

  const _ToolAction(this.label, this.icon, this.colors, [this.route]);
}

const Color _sheetRed = AppColors.primary;

/// Tappable tool-screen header title (label + dropdown dot) that opens the
/// tools menu sheet — same behavior as the POKEDEX title on the home screen.
class ToolsSheetTitle extends StatelessWidget {
  final String label;

  const ToolsSheetTitle({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open tools menu',
      child: GestureDetector(
        onTap: () {
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
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet opened from the POKEDEX header title.
class ToolsSheet extends StatelessWidget {
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
      ..showSnackBar(SnackBar(
        content: Text('${action.label} \u2014 coming soon'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final gridTools = [
      _ToolAction('Moves', Icons.shield, const [Color(0xFFF57C00), Color(0xFFFFCA28)], '/tools/moves'),
      _ToolAction('Abilities', Icons.diamond, const [Color(0xFF26A69A), Color(0xFF66BB6A)], '/tools/abilities'),
      _ToolAction('Natures', Icons.eco, const [Color(0xFF1E88E5), Color(0xFF26C6DA)], '/tools/natures'),
      _ToolAction('Items', Icons.backpack, const [Color(0xFF2196F3), Color(0xFF00BCD4)], '/tools/items'),
      _ToolAction('Breeding', Icons.egg, const [Color(0xFFEC407A), Color(0xFF8E24AA)], '/tools/breeding'),
      _ToolAction('Types', Icons.layers, const [Color(0xFF3949AB), Color(0xFF7E57C2)], '/tools/types'),
      _ToolAction('Team Builder', Icons.hub, const [Color(0xFFCDDC39), Color(0xFF26A69A)], '/tools/teams'),
      _ToolAction(
          'Comparator', Icons.compare_arrows, const [Color(0xFFBA68C8), Color(0xFF7E57C2)], '/tools/comparator'),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go('/');
              },
            ),
            _SheetButton(
              label: 'Pok\u00e9mon Champions',
              colors: const [Color(0xFF7E57C2), Color(0xFF5E35B1)],
              customIconPath: 'assets/images/pokemon_champions.png',
              height: 56,
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Pok\u00e9mon Champions \u2014 coming soon'),
                    duration: Duration(seconds: 2),
                  ));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm + 2,
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

  const _SheetButton({
    required this.label,
    this.icon,
    this.customIconPath,
    this.colors,
    required this.onTap,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: colors ?? [Colors.grey, Colors.grey],
              ),
              borderRadius: BorderRadius.circular(14),
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
                      child: Image.asset(
                        customIconPath!,
                        fit: BoxFit.contain,
                      ),
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
      ),
    );
  }
}
