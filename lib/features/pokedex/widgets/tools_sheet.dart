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
      _ToolAction('Moves', Icons.shield, const [Color(0xFFF57C00), Color(0xFFFFCA28)]),
      _ToolAction('Abilities', Icons.diamond, const [Color(0xFF26A69A), Color(0xFF66BB6A)]),
      _ToolAction('Natures', Icons.eco, const [Color(0xFF1E88E5), Color(0xFF26C6DA)]),
      _ToolAction('Items', Icons.backpack, const [Color(0xFF2196F3), Color(0xFF00BCD4)]),
      _ToolAction('Locations', Icons.place, const [Color(0xFFEC407A), Color(0xFF8E24AA)]),
      _ToolAction('Types', Icons.layers, const [Color(0xFF3949AB), Color(0xFF7E57C2)], '/tools/types'),
      _ToolAction('Trainers', Icons.workspace_premium, const [Color(0xFFF4511E), Color(0xFFD81B60)]),
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
              onTap: () => Navigator.of(context).pop(),
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
            const SizedBox(height: AppSpacing.lg - 4),
            Column(
              children: [
                const Text(
                  'Trainer tools',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Container(width: 64, height: 3, color: _sheetRed),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SheetButton(
              label: 'Team Builder',
              icon: Icons.hub,
              colors: const [Color(0xFFCDDC39), Color(0xFF26A69A)],
              height: 54,
              onTap: () => _handle(
                context,
                const _ToolAction('Team Builder', Icons.hub,
                    [Color(0xFFCDDC39), Color(0xFF26A69A)], '/tools/teams'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            _SheetButton(
              label: 'My Pok\u00e9dex',
              icon: Icons.fact_check,
              colors: const [Color(0xFFFF9800), Color(0xFFEC407A)],
              height: 54,
              onTap: () => _handle(context, const _ToolAction(
                  'My Pok\u00e9dex', Icons.fact_check, [Colors.orange, Colors.pink])),
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
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
  final double height;

  const _SheetButton({
    required this.label,
    required this.icon,
    required this.colors,
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
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: -6,
                  bottom: -height * 0.22,
                  child: Icon(
                    icon,
                    size: height * 1.05,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                Center(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
