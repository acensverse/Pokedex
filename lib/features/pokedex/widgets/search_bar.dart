import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pokedex_provider.dart';

class PokedexSearchBar extends ConsumerStatefulWidget {
  final VoidCallback? onExit;

  const PokedexSearchBar({super.key, this.onExit});

  @override
  ConsumerState<PokedexSearchBar> createState() => _PokedexSearchBarState();
}

class _PokedexSearchBarState extends ConsumerState<PokedexSearchBar> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  void _onChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      ref.read(debouncedSearchQueryProvider.notifier).state = value;
    });
  }

  void _onSuffixTap() {
    if (_controller.text.isNotEmpty) {
      // First tap: clear the text, keep search open.
      _debounce?.cancel();
      _controller.clear();
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(debouncedSearchQueryProvider.notifier).state = '';
    } else {
      // Text already empty: close the search bar.
      widget.onExit?.call();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      // No autofocus: the box slides down on icon tap; tap the box itself
      // to activate typing.
      style: TextStyle(
          fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: 'Search Pokémon...',
        hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            fontSize: 16),
        prefixIcon: query.isEmpty
            ? Icon(LucideIcons.search,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                size: 22)
            : null,
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                    size: 22),
                onPressed: _onSuffixTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onSurface, width: 1.5),
        ),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        isDense: true,
      ),
    );
  }
}
