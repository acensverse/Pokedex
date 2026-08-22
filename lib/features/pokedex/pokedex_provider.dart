import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers.dart';
import '../../models/pokemon.dart';

// Search Query Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Type Filter Provider
final typeFilterProvider = StateProvider<String>((ref) => '');

// Shiny Mode Provider
final shinyModeProvider = StateProvider<bool>((ref) => false);

// Main Pokemon List State
class PokedexState {
  final List<Pokemon> pokemonList;
  final bool isLoading;
  final bool hasError;
  final bool hasReachedMax;
  final int offset;

  PokedexState({
    required this.pokemonList,
    required this.isLoading,
    required this.hasError,
    required this.hasReachedMax,
    required this.offset,
  });

  PokedexState copyWith({
    List<Pokemon>? pokemonList,
    bool? isLoading,
    bool? hasError,
    bool? hasReachedMax,
    int? offset,
  }) {
    return PokedexState(
      pokemonList: pokemonList ?? this.pokemonList,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      offset: offset ?? this.offset,
    );
  }
}

class PokedexNotifier extends StateNotifier<PokedexState> {
  final Ref _ref;

  PokedexNotifier(this._ref)
      : super(PokedexState(
          pokemonList: [],
          isLoading: false,
          hasError: false,
          hasReachedMax: false,
          offset: 0,
        )) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.hasReachedMax) return;

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final repository = _ref.read(pokemonRepositoryProvider);
      final newPokemon = await repository.getLocalPokemonList();

      state = state.copyWith(
        pokemonList: newPokemon,
        isLoading: false,
        hasReachedMax: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> refresh() async {
    state = PokedexState(
      pokemonList: [],
      isLoading: false,
      hasError: false,
      hasReachedMax: false,
      offset: 0,
    );
    await fetchNextPage();
  }
}

final pokedexProvider = StateNotifierProvider<PokedexNotifier, PokedexState>((ref) {
  return PokedexNotifier(ref);
});

// Filtered Pokemon Provider
final filteredPokemonProvider = Provider<List<Pokemon>>((ref) {
  final pokedexState = ref.watch(pokedexProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedType = ref.watch(typeFilterProvider).toLowerCase();

  return pokedexState.pokemonList.where((pokemon) {
    final matchesSearch = pokemon.name.toLowerCase().contains(searchQuery);
    final matchesType = selectedType.isEmpty ||
        pokemon.types.any((t) => t.type.name.toLowerCase() == selectedType);
    return matchesSearch && matchesType;
  }).toList();
});
