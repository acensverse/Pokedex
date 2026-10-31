import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_search_bar.dart';
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

  void _onClear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(debouncedSearchQueryProvider.notifier).state = '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchBar(
      controller: _controller,
      hintText: 'Search Pokémon by name or #id...',
      voiceTitle: 'Pokémon Voice Search',
      voiceHint: 'Say a Pokémon name or type...',
      onChanged: _onChanged,
      onClear: _onClear,
    );
  }
}
