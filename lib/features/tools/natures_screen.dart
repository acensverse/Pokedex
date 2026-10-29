import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../pokedex/widgets/tools_sheet.dart';
import '../../core/utils/pokemon_helpers.dart';

class NatureEntry {
  final int id;
  final String name;

  /// Stat raised by 10% ("attack", "speed", ...), null for neutral natures.
  final String? inc;

  /// Stat lowered by 10%, null for neutral natures.
  final String? dec;

  /// Berry flavor this nature likes, null when none.
  final String? likes;

  /// Berry flavor this nature dislikes, null when none.
  final String? hates;

  const NatureEntry({
    required this.id,
    required this.name,
    required this.inc,
    required this.dec,
    required this.likes,
    required this.hates,
  });

  factory NatureEntry.fromJson(Map<String, dynamic> json) => NatureEntry(
    id: json['id'] as int,
    name: json['name'] as String,
    inc: json['inc'] as String?,
    dec: json['dec'] as String?,
    likes: json['likes'] as String?,
    hates: json['hates'] as String?,
  );

  bool get isNeutral => inc == null && dec == null;
}

String _statLabel(String stat) {
  switch (stat) {
    case 'attack':
      return 'Attack';
    case 'defense':
      return 'Defense';
    case 'speed':
      return 'Speed';
    case 'special-attack':
      return 'Sp. Atk';
    case 'special-defense':
      return 'Sp. Def';
    default:
      return stat;
  }
}

String _flavorLabel(String flavor) =>
    flavor[0].toUpperCase() + flavor.substring(1);

/// All natures baked from assets/natures_seed.json (offline-first).
final naturesSeedProvider = FutureProvider<List<NatureEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/natures_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => NatureEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

class NaturesScreen extends ConsumerWidget {
  const NaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final naturesAsync = ref.watch(naturesSeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Natures'),
      ),
      body: naturesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              SizedBox(height: 12),
              Text('Could not load natures'),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(naturesSeedProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (natures) {
          final sorted = List.of(natures)
            ..sort((a, b) => a.name.compareTo(b.name)); // A-Z
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: sorted.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) => _NatureCard(nature: sorted[index]),
          );
        },
      ),
    );
  }
}

class _NatureCard extends StatelessWidget {
  final NatureEntry nature;

  const _NatureCard({required this.nature});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.eco, size: 24, color: Color(0xFF43A047)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PokemonHelpers.formatName(nature.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 2),
                // Stat effects: raised stat in green, lowered in red.
                nature.isNeutral
                    ? Text(
                        'Neutral \u00b7 no stat change',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      )
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '+${_statLabel(nature.inc!)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF43A047),
                              ),
                            ),
                            TextSpan(
                              text: '  \u00b7  ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            TextSpan(
                              text: '\u2212${_statLabel(nature.dec!)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE4613E),
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                if (nature.likes != null || nature.hates != null) ...[
                  SizedBox(height: 4),
                  Text(
                    [
                      if (nature.likes != null)
                        'Likes ${_flavorLabel(nature.likes!)}',
                      if (nature.hates != null)
                        'Hates ${_flavorLabel(nature.hates!)}',
                    ].join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
