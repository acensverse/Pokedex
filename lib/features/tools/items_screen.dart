import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../core/feedback_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../app/theme/app_spacing.dart';
import '../../core/champions.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../pokedex/widgets/tools_sheet.dart';
import 'widgets/tool_widgets.dart';
import '../../core/widgets/app_search_bar.dart';


class ItemEntry {
  final int id;
  final String name;
  final int cost;
  final String cat;
  final String? eff;
  final String? flavor;
  final String? sprite;

  const ItemEntry({
    required this.id,
    required this.name,
    required this.cost,
    required this.cat,
    required this.eff,
    required this.flavor,
    required this.sprite,
  });

  factory ItemEntry.fromJson(Map<String, dynamic> json) => ItemEntry(
        id: json['id'] as int,
        name: json['name'] as String,
        cost: (json['cost'] as int?) ?? 0,
        cat: (json['cat'] as String?) ?? '',
        eff: json['eff'] as String?,
        flavor: json['flavor'] as String?,
        sprite: json['sprite'] as String?,
      );
  String? get description => eff ?? flavor;
}

/// All items baked from assets/items_seed.json (offline-first).
final itemsSeedProvider = FutureProvider<List<ItemEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/items_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => ItemEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  String _query = '';
  bool _isSearching = false;
  String? _catFilter;
  final TextEditingController _searchController = TextEditingController();

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _openFilterSheet(List<String> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryFilterSheet(
        categories: categories,
        selected: _catFilter,
        onSelected: (c) => setState(() => _catFilter = c),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsSeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Items'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 26,
              color: _isSearching ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF26C6DA) : const Color(0xFF0097A7)) : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: Icon(
              Icons.tune,
              size: 26,
              color: _catFilter != null ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF26C6DA) : const Color(0xFF0097A7)) : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
            ),
            onPressed: () {
              final items = ref.read(itemsSeedProvider).value ?? const [];
              final categories = items.map((i) => i.cat).toSet().toList()..sort();
              _openFilterSheet(categories);
            },
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              SizedBox(height: 12),
              Text('Could not load items'),
              SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(itemsSeedProvider),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          final q = _query.toLowerCase();
          final championsMode = ref.watch(championsModeProvider);
          final championItemSlugs =
              ref.watch(championsDataProvider).value?.itemSlugs;
          final filtered = items.where((i) {
            final matchesQuery = q.isEmpty || i.name.replaceAll('-', ' ').contains(q);
            final matchesCat = _catFilter == null || i.cat == _catFilter;
            // Champions mode: the item seed has no Pokemon relation, so
            // legality comes from the Champions legal held-item name set.
            final matchesChampions = !championsMode ||
                (championItemSlugs != null &&
                    championItemSlugs.contains(normalizeItemName(i.name)));
            return matchesQuery && matchesCat && matchesChampions;
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // A-Z
          return Column(
            children: [
              if (championsMode)
                const ChampionsModeBanner(
                  message:
                      'Champions Pok\u00e9dex \u2014 only legal held items are shown',
                ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: AppSearchBar(
                          controller: _searchController,
                          hintText: 'Search items...',
                          autofocus: true,
                          voiceTitle: 'Items Voice Search',
                          voiceHint: 'Say an item name...',
                          onChanged: (v) => setState(() => _query = v),
                          onClear: _clearSearch,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                            'No items match your search or filters',
                            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _ItemCard(item: filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemEntry item;

  const _ItemCard({required this.item});

  String get _catLabel {
    if (item.cat.isEmpty) return 'Item';
    return item.cat[0].toUpperCase() + item.cat.substring(1);
  }

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
              color: (Theme.of(context).brightness == Brightness.dark) ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.sprite == null
                ? Icon(Icons.catching_pokemon, color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey.shade600 : Colors.grey.shade400)
                : Image.network(
                    item.sprite!,
                    fit: BoxFit.contain,
                    cacheWidth: 96,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.catching_pokemon,
                            color: (Theme.of(context).brightness == Brightness.dark) ? Colors.grey.shade600 : Colors.grey.shade400),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PokemonHelpers.formatName(item.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _catLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                if (item.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
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

/// Category filter bottom sheet: scrollable 3-column grid of category pills
/// in the same style as the Moves filter (permanent border, thicker when
/// selected).
class _CategoryFilterSheet extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const _CategoryFilterSheet({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 2.4,
                children: [
                  for (final cat in categories)
                    GestureDetector(
                      onTap: () {
                        AppFeedback.selectionClick();
                        onSelected(selected == cat ? null : cat);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected == cat
                              ? const Color(0xFF0097A7).withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected == cat
                                ? const Color(0xFF0097A7)
                                : Theme.of(context).dividerColor,
                            width: selected == cat ? 3 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat[0].toUpperCase() + cat.substring(1),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: selected == cat
                                  ? const Color(0xFF0097A7)
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
