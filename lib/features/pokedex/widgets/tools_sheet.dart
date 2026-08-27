import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/providers.dart';
import '../../../core/services/champions_data_service.dart';
import '../pokedex_provider.dart';

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

  void _downloadChampionsData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _DownloadDialog(
        onComplete: () {
          ref.read(isChampionsModeProvider.notifier).state = true;
          // Clear active filters
          ref.read(selectedTypesProvider.notifier).state = [];
          ref.read(genFilterProvider.notifier).state = 0;
          ref.read(searchQueryProvider.notifier).state = '';
          ref.read(debouncedSearchQueryProvider.notifier).state = '';
          ref.read(toolLearnerFilterProvider.notifier).state = null;
          ref.read(toolAbilityFilterProvider.notifier).state = null;
          ref.read(toolMoveFilterProvider.notifier).state = null;
          Navigator.of(dialogCtx).pop(); // close dialog
          Navigator.of(context).pop(); // close sheet
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChampions = ref.watch(isChampionsModeProvider);

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
                isActive: !isChampions,
                onTap: () async {
                  ref.read(isChampionsModeProvider.notifier).state = false;
                  // Clear active filters
                  ref.read(selectedTypesProvider.notifier).state = [];
                  ref.read(genFilterProvider.notifier).state = 0;
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref.read(debouncedSearchQueryProvider.notifier).state = '';
                  ref.read(toolLearnerFilterProvider.notifier).state = null;
                  ref.read(toolAbilityFilterProvider.notifier).state = null;
                  ref.read(toolMoveFilterProvider.notifier).state = null;
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    GoRouter.of(context).go('/');
                  }
                },
              ),
              _SheetButton(
                label: 'Pok\u00e9mon Champions',
                colors: const [Color(0xFF7E57C2), Color(0xFF5E35B1)],
                customIconPath: 'assets/images/pokemon_champions.png',
                height: 56,
                isActive: isChampions,
                onTap: () async {
                  final service = ref.read(championsDataServiceProvider);
                  final downloaded = await service.isDownloaded();
                  if (downloaded) {
                    ref.read(isChampionsModeProvider.notifier).state = true;
                    // Clear active filters
                    ref.read(selectedTypesProvider.notifier).state = [];
                    ref.read(genFilterProvider.notifier).state = 0;
                    ref.read(searchQueryProvider.notifier).state = '';
                    ref.read(debouncedSearchQueryProvider.notifier).state = '';
                    ref.read(toolLearnerFilterProvider.notifier).state = null;
                    ref.read(toolAbilityFilterProvider.notifier).state = null;
                    ref.read(toolMoveFilterProvider.notifier).state = null;
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      GoRouter.of(context).go('/');
                    }
                  } else {
                    if (context.mounted) {
                      _downloadChampionsData(context, ref);
                    }
                  }
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
  final bool isActive;

  const _SheetButton({
    required this.label,
    this.icon,
    this.customIconPath,
    this.colors,
    required this.onTap,
    this.height = 48,
    this.isActive = false,
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
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedScale(
                      scale: isActive ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: isActive ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const _AmbientDot(),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: AnimatedPadding(
                    padding: EdgeInsets.only(left: isActive ? 32.0 : 0.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadDialog extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const _DownloadDialog({required this.onComplete});

  @override
  ConsumerState<_DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends ConsumerState<_DownloadDialog> {
  double _progress = 0;
  String _status = 'Starting download...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() async {
    try {
      final service = ref.read(championsDataServiceProvider);
      await service.downloadAll(
        onProgress: (p) {
          setState(() {
            _progress = p;
            _status =
                'Downloading Pokémon Champions data... (${(p * 100).toInt()}%)';
          });
        },
      );
      widget.onComplete();
    } catch (e) {
      setState(() {
        _hasError = true;
        _status =
            'Failed to download data. Please check your internet connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Downloading Data',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasError) ...[
            CircularProgressIndicator(value: _progress > 0 ? _progress : null),
            const SizedBox(height: 20),
          ] else ...[
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
          ],
          Text(
            _status,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        if (_hasError)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        if (_hasError)
          FilledButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _progress = 0;
                _status = 'Starting download...';
              });
              _startDownload();
            },
            child: const Text('Retry'),
          ),
      ],
    );
  }
}

class _AmbientDot extends StatefulWidget {
  const _AmbientDot();

  @override
  State<_AmbientDot> createState() => _AmbientDotState();
}

class _AmbientDotState extends State<_AmbientDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.9),
                blurRadius: _glowAnimation.value + 4.0,
                spreadRadius: _glowAnimation.value / 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
