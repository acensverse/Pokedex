import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/champions.dart';
import '../../core/feedback_service.dart';
import '../../core/providers.dart';
import '../../core/remote_data.dart';
import '../../data/database/app_database.dart';

const String _devModePrefKey = 'dev_mode_unlocked_flag';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _versionTapCount = 0;
  bool _devOptionsUnlocked = false;
  bool _isExporting = false;
  bool _isRestoring = false;
  bool _legalExpanded = false;

  int _favCount = 0;
  int _teamCount = 0;

  @override
  void initState() {
    super.initState();
    _checkDevModeUnlocked();
    _loadQuickStats();
  }

  Future<void> _checkDevModeUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_devModePrefKey) ?? false) {
      if (mounted) {
        setState(() => _devOptionsUnlocked = true);
      }
    }
  }

  Future<void> _loadQuickStats() async {
    try {
      final db = ref.read(databaseProvider);
      final favRows = await (db.select(
        db.pokemonCache,
      )..where((t) => t.isFavorite.equals(true))).get();
      final teamRows = await (db.select(db.teams)).get();
      if (mounted) {
        setState(() {
          _favCount = favRows.length;
          _teamCount = teamRows.length;
        });
      }
    } catch (_) {}
  }

  void _onVersionTapped() async {
    AppFeedback.lightImpact();

    if (_devOptionsUnlocked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(LucideIcons.wrench, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Developer options are already active!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _versionTapCount++);

    final remaining = 7 - _versionTapCount;

    if (remaining <= 3 && remaining > 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Almost there! $remaining more tap${remaining > 1 ? 's' : ''} to unlock developer mode.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 900),
        ),
      );
    } else if (remaining <= 0) {
      setState(() => _devOptionsUnlocked = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_devModePrefKey, true);

      if (mounted) {
        AppFeedback.mediumImpact();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.terminal, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Developer Options Unlocked!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleBackupExport() async {
    setState(() => _isExporting = true);
    try {
      final db = ref.read(databaseProvider);

      final favoriteRows = await (db.select(
        db.pokemonCache,
      )..where((t) => t.isFavorite.equals(true))).get();
      final favoriteIds = favoriteRows.map((r) => r.id).toList();

      final teamRows = await (db.select(db.teams)).get();
      final teamsData = teamRows
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'slot1': t.slot1,
              'slot2': t.slot2,
              'slot3': t.slot3,
              'slot4': t.slot4,
              'slot5': t.slot5,
              'slot6': t.slot6,
            },
          )
          .toList();

      final currentTheme = ref.read(themeModeProvider);
      final themeStr = currentTheme == ThemeMode.light
          ? 'light'
          : (currentTheme == ThemeMode.dark ? 'dark' : 'system');

      final currentLayout = ref.read(pokedexLayoutProvider);
      final layoutStr =
          currentLayout == PokedexLayoutMode.grid ? 'grid' : 'list';

      final currentDefaultDex = ref.read(defaultPokedexModeProvider);
      final defaultDexStr =
          currentDefaultDex == DefaultPokedexMode.champions
              ? 'champions'
              : 'national';

      final backupData = {
        'app': 'Pokédex',
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'themeMode': themeStr,
        'layoutMode': layoutStr,
        'defaultPokedex': defaultDexStr,
        'favorites': favoriteIds,
        'teams': teamsData,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);

      if (!mounted) return;
      setState(() {
        _isExporting = false;
        _favCount = favoriteIds.length;
        _teamCount = teamsData.length;
      });

      _showBackupDialog(jsonStr, favoriteIds.length, teamsData.length);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate backup: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showBackupDialog(String jsonStr, int favCount, int teamCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.cloudUpload, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Backup Ready',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatPill(
                  icon: LucideIcons.heart,
                  label: '$favCount Favorites',
                  color: const Color(0xFFE53935),
                  isDark: isDark,
                ),
                _buildStatPill(
                  icon: LucideIcons.users,
                  label: '$teamCount Teams',
                  color: Colors.blue.shade600,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Copy this JSON backup to transfer your favorites, teams, and settings to any device:',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              width: double.maxFinite,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14171E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.of(ctx).pop();
              AppFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(LucideIcons.checkCheck, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Backup copied to clipboard!'),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(LucideIcons.copy, size: 16),
            label: const Text('Copy to Clipboard', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final textController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.cloudDownload,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Restore Backup',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your exported JSON backup data below to restore your Pokémon favorites, custom battle teams, and settings:',
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: InputDecoration(
                hintText:
                    '{\r\n  "app": "Pokédex",\r\n  "favorites": [...],\r\n  "teams": [...]\r\n}',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF14171E) : Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () async {
              final rawJson = textController.text.trim();
              if (rawJson.isEmpty) return;

              Navigator.of(ctx).pop();
              await _handleRestoreImport(rawJson);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Restore Data', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRestoreImport(String jsonStr) async {
    setState(() => _isRestoring = true);
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      final db = ref.read(databaseProvider);

      int restoredFavs = 0;
      int restoredTeams = 0;

      // Restore Favorites
      if (data.containsKey('favorites') && data['favorites'] is List) {
        final List favList = data['favorites'];
        for (final item in favList) {
          if (item is int) {
            await db.toggleFavorite(item, true);
            restoredFavs++;
          }
        }
      }

      // Restore Teams
      if (data.containsKey('teams') && data['teams'] is List) {
        final List teamList = data['teams'];
        for (final item in teamList) {
          if (item is Map) {
            final team = Team(
              id: (item['id'] as num?)?.toInt() ?? 0,
              name: (item['name'] as String?) ?? 'Restored Team',
              slot1: (item['slot1'] as num?)?.toInt(),
              slot2: (item['slot2'] as num?)?.toInt(),
              slot3: (item['slot3'] as num?)?.toInt(),
              slot4: (item['slot4'] as num?)?.toInt(),
              slot5: (item['slot5'] as num?)?.toInt(),
              slot6: (item['slot6'] as num?)?.toInt(),
            );
            await db.restoreTeam(team);
            restoredTeams++;
          }
        }
      }

      // Restore ThemeMode
      if (data.containsKey('themeMode') && data['themeMode'] is String) {
        final tm = data['themeMode'];
        if (tm == 'light') {
          await ThemeHelper.setTheme(ref, ThemeMode.light);
        } else if (tm == 'dark') {
          await ThemeHelper.setTheme(ref, ThemeMode.dark);
        } else if (tm == 'system') {
          await ThemeHelper.setTheme(ref, ThemeMode.system);
        }
      }

      // Restore LayoutMode
      if (data.containsKey('layoutMode') && data['layoutMode'] is String) {
        final lm = data['layoutMode'];
        if (lm == 'grid') {
          await LayoutHelper.setLayout(ref, PokedexLayoutMode.grid);
        } else if (lm == 'list') {
          await LayoutHelper.setLayout(ref, PokedexLayoutMode.list);
        }
      }

      // Restore Default Pokédex
      if (data.containsKey('defaultPokedex') &&
          data['defaultPokedex'] is String) {
        final dp = data['defaultPokedex'];
        if (dp == 'champions') {
          await DefaultPokedexHelper.setDefaultPokedex(
            ref,
            DefaultPokedexMode.champions,
          );
        } else if (dp == 'national') {
          await DefaultPokedexHelper.setDefaultPokedex(
            ref,
            DefaultPokedexMode.national,
          );
        }
      }

      // Refresh providers
      ref.invalidate(localPokemonListProvider);
      await _loadQuickStats();

      if (!mounted) return;
      setState(() => _isRestoring = false);

      AppFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCheck, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Restore successful! Restored $restoredFavs favorites & $restoredTeams teams.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRestoring = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid backup JSON: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _checkChampionsData() async {
    AppFeedback.lightImpact();
    final status = await ref
        .read(remoteDataControllerProvider.notifier)
        .checkForUpdates();
    if (!mounted) return;
    final (message, isError) = switch (status) {
      RemoteDataStatus.updated => ('Champions tournament data updated!', false),
      RemoteDataStatus.upToDate => ('Champions data is already up to date.', false),
      RemoteDataStatus.failed => (
        'Update check failed — check your network connection.',
        true,
      ),
      _ => (null, false),
    };
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _revertChampionsData() async {
    AppFeedback.lightImpact();
    await ref
        .read(remoteDataControllerProvider.notifier)
        .revertToBaked();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Reverted to bundled app Champions data.'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeThemeMode = ref.watch(themeModeProvider);
    final activeLayoutMode = ref.watch(pokedexLayoutProvider);
    final activeDefaultDex = ref.watch(defaultPokedexModeProvider);
    final remoteDataStatus = ref.watch(remoteDataControllerProvider);
    final championsDataInfo = ref.watch(activeChampionsDataProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // HERO HEADER CARD
                // -------------------------------------------------------------
                _buildHeroBanner(isDark),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION 1: APPEARANCE & THEME
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Appearance',
                  subtitle: 'Personalize colors and display theme',
                  icon: LucideIcons.palette,
                  color: const Color(0xFFE53935),
                ),
                const SizedBox(height: 10),
                _buildThemeSelector(activeThemeMode, isDark),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION 2: POKÉDEX VIEW LAYOUT
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Pokédex View',
                  subtitle: 'Choose card density for Pokémon lists',
                  icon: LucideIcons.layoutGrid,
                  color: const Color(0xFF1E88E5),
                ),
                const SizedBox(height: 10),
                _buildLayoutSelector(activeLayoutMode, isDark),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION 3: DEFAULT POKÉDEX CATALOG
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Default Pokédex',
                  subtitle: 'Select catalog loaded on launch',
                  icon: LucideIcons.trophy,
                  color: const Color(0xFF9C27B0),
                ),
                const SizedBox(height: 10),
                _buildDefaultDexSelector(activeDefaultDex, isDark),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION: HAPTICS & SOUND
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Touch & Feedback',
                  subtitle: 'Vibration and tap sound preferences',
                  icon: LucideIcons.vibrate,
                  color: const Color(0xFF00897B),
                ),
                const SizedBox(height: 10),
                _buildFeedbackSettingsCard(isDark),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION 4: DATA SAFEGUARD & BACKUP
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Data & Backup',
                  subtitle: 'Export and restore your offline favorites & teams',
                  icon: LucideIcons.shieldCheck,
                  color: const Color(0xFF43A047),
                ),
                const SizedBox(height: 10),
                _buildBackupCard(isDark),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION 5: CHAMPIONS LIVE DATA SYNC
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Champions Meta Sync',
                  subtitle: 'Live tournament roster and legality data',
                  icon: LucideIcons.cloud,
                  color: const Color(0xFF8E24AA),
                ),
                const SizedBox(height: 10),
                _buildChampionsSyncCard(
                  remoteDataStatus,
                  championsDataInfo,
                  isDark,
                ),

                const SizedBox(height: 24),

                // -------------------------------------------------------------
                // SECTION 6: APP INFO, VERSION & LEGAL
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'About Pokédex',
                  subtitle: 'Version details & copyright disclaimers',
                  icon: LucideIcons.info,
                  color: const Color(0xFF757575),
                ),
                const SizedBox(height: 10),
                _buildAboutCard(isDark),

                // -------------------------------------------------------------
                // SECTION 7: DEVELOPER OPTIONS (UNLOCKED ON 7 TAPS)
                // -------------------------------------------------------------
                if (_devOptionsUnlocked) ...[
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    title: 'Developer Console',
                    subtitle: 'Database diagnostics & internal debugging tools',
                    icon: LucideIcons.terminal,
                    color: Colors.greenAccent.shade700,
                  ),
                  const SizedBox(height: 10),
                  _buildDevOptionsCard(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HERO BANNER WIDGET
  // ===========================================================================
  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF261514),
                  const Color(0xFF1A1C24),
                ]
              : [
                  const Color(0xFFFFF4F1),
                  const Color(0xFFFFFFFF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Pokédex icon
              Image.asset(
                'assets/pokedex.png',
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Pokédex',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Offline Pokémon encyclopedia & battle companion',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Quick Live Summary Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderStat(
                  icon: LucideIcons.database,
                  label: 'Indexed',
                  value: '1,025',
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                _buildHeaderStat(
                  icon: LucideIcons.heart,
                  label: 'Favorites',
                  value: '$_favCount',
                  color: const Color(0xFFE53935),
                  isDark: isDark,
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                _buildHeaderStat(
                  icon: LucideIcons.users,
                  label: 'Teams',
                  value: '$_teamCount',
                  color: Colors.blue.shade600,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION HEADER COMPONENT
  // ===========================================================================
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // THEME SELECTOR WIDGET (LIGHT, DARK, SYSTEM)
  // ===========================================================================
  Widget _buildThemeSelector(ThemeMode activeMode, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildThemeTile(
              title: 'Light',
              subtitle: 'Day mode',
              icon: LucideIcons.sun,
              accentColor: const Color(0xFFFFA000),
              isSelected: activeMode == ThemeMode.light,
              onTap: () => ThemeHelper.setTheme(ref, ThemeMode.light),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildThemeTile(
              title: 'Dark',
              subtitle: 'Night mode',
              icon: LucideIcons.moon,
              accentColor: const Color(0xFF7E57C2),
              isSelected: activeMode == ThemeMode.dark,
              onTap: () => ThemeHelper.setTheme(ref, ThemeMode.dark),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildThemeTile(
              title: 'System',
              subtitle: 'Auto-sync',
              icon: LucideIcons.monitor,
              accentColor: const Color(0xFF26A69A),
              isSelected: activeMode == ThemeMode.system,
              onTap: () => ThemeHelper.setTheme(ref, ThemeMode.system),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        AppFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? accentColor.withValues(alpha: 0.16)
                  : accentColor.withValues(alpha: 0.08))
              : (isDark
                  ? const Color(0xFF171920)
                  : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isSelected ? 0.22 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // POKÉDEX LAYOUT SELECTOR (GRID VS LIST)
  // ===========================================================================
  Widget _buildLayoutSelector(PokedexLayoutMode activeLayout, bool isDark) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildLayoutTile(
              title: 'Grid Layout',
              subtitle: 'Compact 2+ columns view',
              icon: LucideIcons.layoutGrid,
              isSelected: activeLayout == PokedexLayoutMode.grid,
              onTap: () => LayoutHelper.setLayout(ref, PokedexLayoutMode.grid),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildLayoutTile(
              title: 'List Layout',
              subtitle: 'Detailed full-width cards',
              icon: LucideIcons.layoutList,
              isSelected: activeLayout == PokedexLayoutMode.list,
              onTap: () => LayoutHelper.setLayout(ref, PokedexLayoutMode.list),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    const activeColor = Color(0xFF1E88E5);

    return GestureDetector(
      onTap: () {
        AppFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? activeColor.withValues(alpha: 0.16)
                  : activeColor.withValues(alpha: 0.08))
              : (isDark ? const Color(0xFF171920) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: activeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DEFAULT POKÉDEX SELECTOR (NATIONAL VS CHAMPIONS)
  // ===========================================================================
  Widget _buildDefaultDexSelector(
    DefaultPokedexMode activeDex,
    bool isDark,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildDefaultDexTile(
              title: 'National Dex',
              subtitle: '1,025 All-Gens',
              icon: Icons.catching_pokemon,
              activeColor: AppColors.primary,
              isSelected: activeDex == DefaultPokedexMode.national,
              onTap: () => DefaultPokedexHelper.setDefaultPokedex(
                ref,
                DefaultPokedexMode.national,
              ),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDefaultDexTile(
              title: 'Champions Dex',
              subtitle: 'Tournament Roster',
              icon: LucideIcons.trophy,
              activeColor: const Color(0xFF9C27B0),
              isSelected: activeDex == DefaultPokedexMode.champions,
              onTap: () => DefaultPokedexHelper.setDefaultPokedex(
                ref,
                DefaultPokedexMode.champions,
              ),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultDexTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {
        AppFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? activeColor.withValues(alpha: 0.16)
                  : activeColor.withValues(alpha: 0.08))
              : (isDark ? const Color(0xFF171920) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: activeColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color:
                          isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? activeColor : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HAPTIC & SOUND FEEDBACK CARD
  // ===========================================================================
  Widget _buildFeedbackSettingsCard(bool isDark) {
    final feedbackSettings = ref.watch(feedbackSettingsProvider);
    final tealColor = const Color(0xFF00897B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171920) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vibration / Haptic Feedback Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: tealColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(LucideIcons.vibrate, color: tealColor, size: 20),
            ),
            title: Text(
              'Touch Vibration',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Haptic feedback on card selection, tabs & buttons',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            activeThumbColor: tealColor,
            value: feedbackSettings.hapticsEnabled,
            onChanged: (val) {
              FeedbackHelper.setHapticsEnabled(ref, val);
              if (val) {
                AppFeedback.selectionClick();
              }
            },
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          // Touch Sound Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.volume2, color: Color(0xFF1E88E5), size: 20),
            ),
            title: Text(
              'Touch Sound',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Play subtle click sound effect when tapping controls',
              style: TextStyle(
                fontSize: 11.5,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            activeThumbColor: const Color(0xFF1E88E5),
            value: feedbackSettings.soundEnabled,
            onChanged: (val) {
              FeedbackHelper.setSoundEnabled(ref, val);
              if (val) {
                AppFeedback.selectionClick();
              }
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BACKUP & RESTORE CARD
  // ===========================================================================
  Widget _buildBackupCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171920) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF43A047).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.hardDrive,
                  color: Color(0xFF43A047),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Offline Data Safeguard',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Keep your Pokémon collection secure. Export your favorites, custom battle teams, and personal settings to a portable JSON backup, or restore them anytime.',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isExporting ? null : _handleBackupExport,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.cloudUpload, size: 17),
                  label: const Text(
                    'Export Backup',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isRestoring ? null : _showRestoreDialog,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                  ),
                  icon: _isRestoring
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(LucideIcons.cloudDownload, size: 17),
                  label: const Text(
                    'Restore Backup',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CHAMPIONS DATA SYNC CARD
  // ===========================================================================
  Widget _buildChampionsSyncCard(
    RemoteDataStatus status,
    ActiveChampionsData? info,
    bool isDark,
  ) {
    final isChecking = status == RemoteDataStatus.checking;
    final isOverride = info?.fromOverride ?? false;

    final (statusLabel, statusColor, statusIcon) = switch (status) {
      RemoteDataStatus.checking => (
        'Checking GitHub for data updates…',
        Colors.blue,
        LucideIcons.refreshCw,
      ),
      RemoteDataStatus.updated => (
        'Champions tournament data is fresh & updated.',
        Colors.green,
        LucideIcons.checkCheck,
      ),
      RemoteDataStatus.upToDate => (
        'Up to date with the latest tournament data.',
        Colors.green,
        LucideIcons.checkCheck,
      ),
      RemoteDataStatus.failed => (
        'Update check failed. Check internet connection.',
        Colors.redAccent,
        LucideIcons.cloud,
      ),
      _ => isOverride
          ? (
              'Using active online Champions dataset.',
              const Color(0xFF9C27B0),
              LucideIcons.sparkles,
            )
          : (
              'Using bundled offline Champions dataset.',
              Colors.grey.shade600,
              LucideIcons.database,
            ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171920) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              if (isChecking)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'The Champions Pokédex, item legality, and competitive speed tiers automatically synchronize with game meta shifts.',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          if (info?.source case final source?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Data source: $source',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isChecking ? null : _checkChampionsData,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(
                      color: const Color(0xFF9C27B0).withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    LucideIcons.refreshCw,
                    size: 17,
                    color: Color(0xFF9C27B0),
                  ),
                  label: const Text(
                    'Check for Updates',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF9C27B0),
                    ),
                  ),
                ),
              ),
              if (isOverride) ...[
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: isChecking ? null : _revertChampionsData,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                    foregroundColor: Colors.redAccent,
                  ),
                  icon: const Icon(LucideIcons.refreshCw, size: 15),
                  label: const Text(
                    'Revert',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ABOUT, VERSION & LEGAL NOTICE CARD
  // ===========================================================================
  Widget _buildAboutCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171920) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Version Row (Interactive 7-Tap Easter Egg)
          InkWell(
            onTap: _onVersionTapped,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Image.asset(
                    'assets/pokedex.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Version',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Release v1.0.0 • Build 1',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          const SizedBox(height: 12),

          // Collapsible Legal & Copyright Notice
          InkWell(
            onTap: () {
              AppFeedback.selectionClick();
              setState(() => _legalExpanded = !_legalExpanded);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.shieldCheck,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Legal & Content Copyright Notice',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Icon(
                    _legalExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12, left: 4, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pokémon and all character names, distinctive likenesses, and related indicia are registered trademarks of Nintendo, Creatures Inc., GAME FREAK Inc., and The Pokémon Company.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This application is an independent, non-commercial fan project built strictly for educational, research, and offline reference purposes. No copyright infringement or trademark dilution is intended.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _legalExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DEVELOPER OPTIONS CARD (EASTER EGG)
  // ===========================================================================
  Widget _buildDevOptionsCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF142416) : const Color(0xFFF1FBF2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 16,
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.terminal, color: Colors.white, size: 12),
                    SizedBox(width: 5),
                    Text(
                      'DEV MODE ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () async {
                  AppFeedback.lightImpact();
                  setState(() {
                    _devOptionsUnlocked = false;
                    _versionTapCount = 0;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove(_devModePrefKey);
                },
                icon: const Icon(LucideIcons.wrench, size: 14, color: Colors.redAccent),
                label: const Text(
                  'Lock & Hide',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action 1: Re-seed Database
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.refreshCw, color: Colors.green, size: 18),
            ),
            title: const Text(
              'Force Re-seed Database',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Reloads all asset seeds while preserving user favorites.',
              style: TextStyle(fontSize: 11),
            ),
            trailing: OutlinedButton(
              onPressed: () async {
                AppFeedback.mediumImpact();
                final repo = ref.read(pokemonRepositoryProvider);
                final messenger = ScaffoldMessenger.of(context);
                await repo.forceReseedDatabase();
                await _loadQuickStats();
                messenger.showSnackBar(
                  SnackBar(
                    content: const Text('Database re-seeded successfully!'),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.green.shade600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Re-seed'),
            ),
          ),

          const Divider(height: 16),

          // Action 2: Clear Image & Sprite Cache
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.sparkles, color: Colors.amber.shade700, size: 18),
            ),
            title: const Text(
              'Evict Memory Image Cache',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Frees memory used by cached Pokémon sprites.',
              style: TextStyle(fontSize: 11),
            ),
            trailing: OutlinedButton(
              onPressed: () {
                AppFeedback.lightImpact();
                PaintingBinding.instance.imageCache.clear();
                PaintingBinding.instance.imageCache.clearLiveImages();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Memory image cache cleared!'),
                    backgroundColor: Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.amber.shade700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Clear'),
            ),
          ),

          const Divider(height: 16),

          // Diagnostic stats
          const Text(
            'Live Database Diagnostics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: _fetchDevStats(),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(
                  height: 36,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final stats = snapshot.data as Map<String, int>;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDevStatChip('Total Pokémon', '${stats['total']}'),
                  _buildDevStatChip('Favorites', '${stats['favs']}'),
                  _buildDevStatChip('Custom Teams', '${stats['teams']}'),
                  _buildDevStatChip('Asset Schema', 'v9'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<Map<String, int>> _fetchDevStats() async {
    final db = ref.read(databaseProvider);
    final totalRows = await (db.select(db.pokemonCache)).get();
    final favRows = await (db.select(
      db.pokemonCache,
    )..where((t) => t.isFavorite.equals(true))).get();
    final teamRows = await (db.select(db.teams)).get();

    return {
      'total': totalRows.length,
      'favs': favRows.length,
      'teams': teamRows.length,
    };
  }

  Widget _buildDevStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
