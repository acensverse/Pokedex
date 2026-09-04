import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/providers.dart';
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

  @override
  void initState() {
    super.initState();
    _checkDevModeUnlocked();
  }

  Future<void> _checkDevModeUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_devModePrefKey) ?? false) {
      setState(() {
        _devOptionsUnlocked = true;
      });
    }
  }

  void _onVersionTapped() async {
    if (_devOptionsUnlocked) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛠️ Developer options are already enabled!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _versionTapCount++;
    });

    final remaining = 7 - _versionTapCount;

    if (remaining <= 3 && remaining > 0) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You are $remaining step${remaining > 1 ? 's' : ''} away from being a developer!',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (remaining <= 0) {
      setState(() {
        _devOptionsUnlocked = true;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_devModePrefKey, true);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Developer options enabled! See section below.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleBackupExport() async {
    setState(() => _isExporting = true);
    try {
      final db = ref.read(databaseProvider);

      // 1. Get favorite IDs
      final favoriteRows = await (db.select(
        db.pokemonCache,
      )..where((t) => t.isFavorite.equals(true))).get();
      final favoriteIds = favoriteRows.map((r) => r.id).toList();

      // 2. Get Teams
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

      final backupData = {
        'app': 'Pokédex',
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'themeMode': themeStr,
        'favorites': favoriteIds,
        'teams': teamsData,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backupData);

      if (!mounted) return;
      setState(() => _isExporting = false);

      _showBackupDialog(jsonStr, favoriteIds.length, teamsData.length);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isExporting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate backup: $e')));
    }
  }

  void _showBackupDialog(String jsonStr, int favCount, int teamCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cloud_download_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Backup Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary:\n• Favorites: $favCount Pokémon\n• Custom Teams: $teamCount Teams',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Copy your JSON backup string to restore it anytime on any device:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 140),
              width: double.maxFinite,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonStr));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📋 Backup copied to clipboard!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.settings_backup_restore_rounded,
              color: AppColors.primary,
            ),
            SizedBox(width: 10),
            Text('Restore Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paste your JSON backup data below to restore your saved favorites and custom teams:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              decoration: InputDecoration(
                hintText:
                    '{\n  "app": "Pokédex",\n  "favorites": [...],\n  "teams": [...]\n}',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final rawJson = textController.text.trim();
              if (rawJson.isEmpty) return;

              Navigator.of(ctx).pop();
              await _handleRestoreImport(rawJson);
            },
            icon: const Icon(Icons.restore_rounded, size: 18),
            label: const Text('Restore Data'),
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

      // Restore ThemeMode if available
      if (data.containsKey('themeMode') && data['themeMode'] is String) {
        final tm = data['themeMode'];
        if (tm == 'light') {
          ThemeHelper.setTheme(ref, ThemeMode.light);
        } else if (tm == 'dark') {
          ThemeHelper.setTheme(ref, ThemeMode.dark);
        } else if (tm == 'system') {
          ThemeHelper.setTheme(ref, ThemeMode.system);
        }
      }

      // Refresh providers
      ref.invalidate(localPokemonListProvider);

      if (!mounted) return;
      setState(() => _isRestoring = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Restore successful! Restored $restoredFavs favorites & $restoredTeams custom teams.',
          ),
          backgroundColor: AppColors.primary,
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // SECTION 1: THEME CARDS (3 IN A ROW)
            // -----------------------------------------------------------------
            _buildSectionHeader('Theme Mode', Icons.palette_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildThemeCard(
                    context: context,
                    mode: ThemeMode.light,
                    title: 'Light',
                    icon: Icons.wb_sunny_rounded,
                    isSelected: activeThemeMode == ThemeMode.light,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeCard(
                    context: context,
                    mode: ThemeMode.dark,
                    title: 'Dark',
                    icon: Icons.nightlight_round,
                    isSelected: activeThemeMode == ThemeMode.dark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeCard(
                    context: context,
                    mode: ThemeMode.system,
                    title: 'System',
                    icon: Icons.settings_brightness_rounded,
                    isSelected: activeThemeMode == ThemeMode.system,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // SECTION 2: BACKUP & RESTORE
            // -----------------------------------------------------------------
            _buildSectionHeader(
              'Data Backup & Restore',
              Icons.cloud_sync_outlined,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Offline Data Safeguard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can easily backup all your saved Pokédex data—including your favorite Pokémon, custom built battle teams, and user preferences—to a portable JSON format, or restore it anytime.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed:
                                _isExporting ? null : _handleBackupExport,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: _isExporting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.upload_file_rounded,
                                    size: 18,
                                  ),
                            label: const Text('Export Backup'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isRestoring ? null : _showRestoreDialog,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                : const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Restore Backup'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // -----------------------------------------------------------------
            // SECTION 3: APP INFO, VERSION & COPYRIGHT
            // -----------------------------------------------------------------
            _buildSectionHeader(
              'App Info & Copyright',
              Icons.info_outline_rounded,
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // App Logo Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.catching_pokemon,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pokédex',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Offline-First Pokémon Companion',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Version Row (Tappable 7 times for Easter Egg!)
                    InkWell(
                      onTap: _onVersionTapped,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'App Version',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'v1.0.0 (Build 1)',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24),

                    // Copyright & Legal Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Legal & Content Copyright Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pokémon and Pokémon character names are registered trademarks of Nintendo, Creatures Inc., GAME FREAK inc., and The Pokémon Company.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'This application is an independent, non-commercial fan project built strictly for educational and informational reference purposes. No copyright or trademark infringement is intended.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // SECTION 4: DEVELOPER OPTIONS (UNLOCKED AFTER 7 TAPS)
            // -----------------------------------------------------------------
            if (_devOptionsUnlocked) ...[
              const SizedBox(height: 24),
              _buildSectionHeader(
                '🛠️ Developer Options',
                Icons.developer_mode_rounded,
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: isDark
                    ? const Color(0xFF1E261E)
                    : const Color(0xFFF4FAF4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Colors.green.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DEV MODE ACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                _devOptionsUnlocked = false;
                                _versionTapCount = 0;
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove(_devModePrefKey);
                            },
                            child: const Text(
                              'Lock / Hide',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Dev Tool 1: Re-seed DB
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.green,
                        ),
                        title: const Text(
                          'Re-seed Database',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Reloads seed assets while maintaining favorites.',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final repo = ref.read(pokemonRepositoryProvider);
                            final messenger = ScaffoldMessenger.of(context);
                            await repo.forceReseedDatabase();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Database re-seeded successfully!',
                                ),
                              ),
                            );
                          },
                          child: const Text('Re-seed'),
                        ),
                      ),

                      const Divider(),

                      // Dev Tool 2: Clear Image Cache
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.cleaning_services_outlined,
                          color: Colors.amber,
                        ),
                        title: const Text(
                          'Clear Memory Cache',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Evicts in-memory image and sprite caches.',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () {
                            PaintingBinding.instance.imageCache.clear();
                            PaintingBinding
                                .instance
                                .imageCache
                                .clearLiveImages();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🧹 Memory image cache cleared!'),
                              ),
                            );
                          },
                          child: const Text('Clear'),
                        ),
                      ),

                      const Divider(),

                      // Dev Tool 3: Live Stats
                      const Text(
                        'Database & Diagnostics Stats',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder(
                        future: _fetchDevStats(),
                        builder: (ctx, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 40,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }
                          final stats = snapshot.data as Map<String, int>;
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildDevStatChip(
                                'Total Pokémon',
                                '${stats['total']}',
                              ),
                              _buildDevStatChip(
                                'Favorites',
                                '${stats['favs']}',
                              ),
                              _buildDevStatChip('Teams', '${stats['teams']}'),
                              _buildDevStatChip('Asset Rev', 'v1'),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        ThemeHelper.setTheme(ref, mode);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.1)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
