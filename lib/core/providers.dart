import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/app_database.dart';
import '../data/api/dio_client.dart';
import '../data/api/poke_api.dart';
import '../data/repositories/pokemon_repository.dart';
import '../models/pokemon.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final pokeApiProvider = Provider<PokeApi>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PokeApi(dioClient.dio);
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  final api = ref.watch(pokeApiProvider);
  final db = ref.watch(databaseProvider);
  final dio = ref.watch(dioClientProvider).dio;
  return PokemonRepository(api, db, dio);
});

/// Full local dex (offline-first). Used by the tool pickers.
final localPokemonListProvider = FutureProvider<List<Pokemon>>((ref) async {
  final repository = ref.watch(pokemonRepositoryProvider);
  return repository.getLocalPokemonList();
});

/// Live team list keyed by a name search query.
final teamsStreamProvider = StreamProvider.family<List<Team>, String>((
  ref,
  query,
) {
  final db = ref.watch(databaseProvider);
  return db.watchTeams(query: query);
});
