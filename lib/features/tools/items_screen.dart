import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../pokedex/widgets/tools_sheet.dart';


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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const ToolsSheetTitle(label: 'Items'),
        actions: [
          IconButton(
            icon: Icon(
              LucideIcons.search,
              size: 26,
              color: _isSearching ? AppColors.primary : Colors.black54,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: Icon(
              Icons.tune,
              size: 26,
              color: _catFilter != null ? AppColors.primary : Colors.black54,
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text('Could not load items'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(itemsSeedProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          final q = _query.toLowerCase();
          final filtered = items.where((i) {
            final matchesQuery = q.isEmpty || i.name.replaceAll('-', ' ').contains(q);
            final matchesCat = _catFilter == null || i.cat == _catFilter;
            return matchesQuery && matchesCat;
          }).toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // A-Z
          return Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _isSearching
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) => setState(() => _query = v),
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(LucideIcons.search,
                                color: Colors.black54),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    icon: const Icon(Icons.close,
                                        color: Colors.black54, size: 20),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                            'No items match your search or filters',
                            style: TextStyle(color: Colors.grey.shade500)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.sprite == null
                ? Icon(Icons.catching_pokemon, color: Colors.grey.shade300)
                : Image.network(
                    item.sprite!,
                    fit: BoxFit.contain,
                    cacheWidth: 96,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.catching_pokemon,
                            color: Colors.grey.shade300),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PokemonHelpers.formatName(item.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _catLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                        fontSize: 12, height: 1.3, color: Colors.grey.shade700),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                        onSelected(selected == cat ? null : cat);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selected == cat
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected == cat
                                ? AppColors.primary
                                : Colors.grey.shade400,
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
                                  ? AppColors.primary
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
