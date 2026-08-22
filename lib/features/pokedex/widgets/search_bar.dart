import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pokedex_provider.dart';

class PokedexSearchBar extends ConsumerWidget {
  const PokedexSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

    return TextField(
      onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
      autofocus: true,
      style: const TextStyle(fontSize: 18, color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Search Pokémon...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black54),
                onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
              )
            : null,
      ),
    );
  }
}
