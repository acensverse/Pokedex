import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers.dart';
import '../../models/pokemon.dart';

// Search Query Provider (immediate, drives the TextField)
final searchQueryProvider = StateProvider<String>((ref) => '');

final debouncedSearchQueryProvider = StateProvider<String>((ref) => '');
final searchClearTriggerProvider = StateProvider<int>((ref) => 0);

// Type Filter Providers
// Holds 0-2 selected types: max 1 in single mode, max 2 in dual mode.
final selectedTypesProvider = StateProvider<List<String>>((ref) => []);

// Dual-type switch: when ON, two types can be picked and a Pokemon must
// have BOTH to match.
final dualTypeModeProvider = StateProvider<bool>((ref) => false);

// Favorites-only toggle
final favoritesOnlyProvider = StateProvider<bool>((ref) => false);

/// Live set of favorite IDs straight from SQLite. Drift re-emits whenever the
/// table changes, so toggling a favorite on a detail screen instantly updates
/// any favorites-filtered grid without manual refreshes.
final favoriteIdsProvider = StreamProvider<Set<int>>((ref) {
  final db = ref.watch(databaseProvider);
  final query = db.select(db.pokemonCache)
    ..where((t) => t.isFavorite.equals(true));
  return query.watch().map((rows) => rows.map((r) => r.id).toSet());
});

// Generation Filter Provider (0 = All, 1-9 = Gen number)
final genFilterProvider = StateProvider<int>((ref) => 0);

/// When non-null, the home grid shows only the Pokemon linked to a tool
/// entity (Pokemon that learn a move / have an ability). Set from the Moves
/// or Abilities tool's POKEMON LIST button; cleared via the chip on the home
/// screen. [kind] renders the chip prefix ("MOVE"/"ABILITY").
final toolLearnerFilterProvider =
    StateProvider<({String kind, String name, Set<int> ids})?>((ref) => null);

/// Ability filter from Pokemon detail page: shows only Pokemon that have
/// [name] as an ability. [mode] is 'all' | 'normal' | 'hidden'.
/// Stores all three ID sets so mode switching is instant.
final toolAbilityFilterProvider =
    StateProvider<
      ({
        String name,
        String mode,
        Set<int> allIds,
        Set<int> normalIds,
        Set<int> hiddenIds,
        String flavor,
        String eff,
      })?
    >((ref) => null);

/// Move filter from Pokemon detail page: shows only Pokemon that learn [name]
final toolMoveFilterProvider =
    StateProvider<
      ({
        String name,
        String flavor,
        String? type,
        String? category,
        int? power,
        int? accuracy,
        int? pp,
        Set<int> ids,
      })?
    >((ref) => null);

/// Returns the correct ID set for the given ability filter mode.
Set<int> _abilityIdsForMode(
  ({
    String name,
    String mode,
    Set<int> allIds,
    Set<int> normalIds,
    Set<int> hiddenIds,
    String flavor,
    String eff,
  })
  filter,
) {
  switch (filter.mode) {
    case 'normal':
      return filter.normalIds;
    case 'hidden':
      return filter.hiddenIds;
    default:
      return filter.allIds;
  }
}

// Gen ID ranges (inclusive)
const Map<int, List<int>> genRanges = {
  1: [1, 151],
  2: [152, 251],
  3: [252, 386],
  4: [387, 493],
  5: [494, 649],
  6: [650, 721],
  7: [722, 809],
  8: [810, 905],
  9: [906, 1025],
};

// Shiny Mode Provider
final shinyModeProvider = StateProvider<bool>((ref) => false);

// Main Pokemon List State - honest offline model: one seeded load, no paging.
class PokedexState {
  final List<Pokemon> pokemonList;
  final bool isLoading;
  final bool hasError;

  PokedexState({
    required this.pokemonList,
    required this.isLoading,
    required this.hasError,
  });

  PokedexState copyWith({
    List<Pokemon>? pokemonList,
    bool? isLoading,
    bool? hasError,
  }) {
    return PokedexState(
      pokemonList: pokemonList ?? this.pokemonList,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }
}

class PokedexNotifier extends StateNotifier<PokedexState> {
  final Ref _ref;

  PokedexNotifier(this._ref)
    : super(PokedexState(pokemonList: [], isLoading: false, hasError: false)) {
    load();
  }

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final repository = _ref.read(pokemonRepositoryProvider);
      final allPokemon = await repository.getLocalPokemonList();

      state = state.copyWith(pokemonList: allPokemon, isLoading: false);
    } catch (e, st) {
      print('POKEDEX LOAD ERROR: $e');
      print(st);
      state = state.copyWith(isLoading: false, hasError: true);
    }
  }

  Future<void> refresh() async {
    state = PokedexState(pokemonList: [], isLoading: false, hasError: false);
    await load();
  }
}

final pokedexProvider = StateNotifierProvider<PokedexNotifier, PokedexState>((
  ref,
) {
  return PokedexNotifier(ref);
});

// Filtered Pokemon Provider
final filteredPokemonProvider = Provider<List<Pokemon>>((ref) {
  final pokedexState = ref.watch(pokedexProvider);
  final searchQuery = ref.watch(debouncedSearchQueryProvider).toLowerCase();
  final selectedTypes = ref.watch(selectedTypesProvider);
  final selectedGen = ref.watch(genFilterProvider);
  final favoritesOnly = ref.watch(favoritesOnlyProvider);
  final favoriteIds = ref.watch(favoriteIdsProvider).value ?? const <int>{};
  final learnerFilter = ref.watch(toolLearnerFilterProvider);
  final abilityFilter = ref.watch(toolAbilityFilterProvider);
  final moveFilter = ref.watch(toolMoveFilterProvider);

  return pokedexState.pokemonList.where((pokemon) {
    final matchesSearch =
        pokemon.name.toLowerCase().contains(searchQuery) ||
        pokemon.abilities.any(
          (a) => a.ability.name
              .toLowerCase()
              .replaceAll('-', ' ')
              .contains(searchQuery.replaceAll('-', ' ')),
        );

    bool matchesType;
    if (selectedTypes.isEmpty) {
      matchesType = true;
    } else if (selectedTypes.length == 1) {
      final t = selectedTypes.first.toLowerCase();
      matchesType = pokemon.types.any(
        (slot) => slot.type.name.toLowerCase() == t,
      );
    } else {
      // Dual mode: the Pokemon must carry both selected types.
      final pokemonTypes = pokemon.types
          .map((s) => s.type.name.toLowerCase())
          .toSet();
      matchesType = selectedTypes.every(
        (t) => pokemonTypes.contains(t.toLowerCase()),
      );
    }

    bool matchesGen = true;
    if (selectedGen > 0) {
      final range = genRanges[selectedGen];
      if (range != null) {
        matchesGen =
            pokemon.speciesId >= range[0] && pokemon.speciesId <= range[1];
      }
    }

    final matchesFavorite = !favoritesOnly || favoriteIds.contains(pokemon.id);
    final matchesLearner = learnerFilter == null ||
        learnerFilter.ids.contains(pokemon.id) ||
        learnerFilter.ids.contains(pokemon.speciesId);
    final matchesAbility = abilityFilter == null ||
        _abilityIdsForMode(abilityFilter).contains(pokemon.id) ||
        _abilityIdsForMode(abilityFilter).contains(pokemon.speciesId);
    final matchesMove = moveFilter == null ||
        moveFilter.ids.contains(pokemon.id) ||
        moveFilter.ids.contains(pokemon.speciesId);

    return matchesSearch &&
        matchesType &&
        matchesGen &&
        matchesFavorite &&
        matchesLearner &&
        matchesAbility &&
        matchesMove;
  }).toList();
});
