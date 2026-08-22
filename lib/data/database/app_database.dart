import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class PokemonCache extends Table {
  IntColumn get id => integer()();
  IntColumn get speciesId => integer().nullable()();
  TextColumn get name => text()();
  TextColumn get species => text().nullable()();
  IntColumn get generation => integer().nullable()();
  TextColumn get types => text()(); // Comma-separated types, e.g., "grass,poison"
  IntColumn get hp => integer().nullable()();
  IntColumn get attack => integer().nullable()();
  IntColumn get defense => integer().nullable()();
  IntColumn get spAttack => integer().nullable()();
  IntColumn get spDefense => integer().nullable()();
  IntColumn get speed => integer().nullable()();
  RealColumn get height => real().nullable()(); // Metres
  RealColumn get weight => real().nullable()(); // Kilograms
  TextColumn get abilities => text().nullable()(); // JSON [{"n":name,"h":hidden}, ...]
  TextColumn get forms => text().nullable()(); // Alternate forms metadata (JSON or text)
  TextColumn get evolutionInfo => text().nullable()(); // Evolution tree metadata (JSON or text)
  TextColumn get flavorText => text().nullable()(); // Official Pokédex flavor text fetched from API
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  // Legacy full-API-payload blob; no longer written or read (see repository).
  // Kept only so old databases do not need a destructive column drop.
  TextColumn get jsonData => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PokemonCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          var recreated = false;
          if (from < 6) {
            // Old dev-era schema was too different to migrate additively.
            // Salvage user favorites before rebuilding so upgrades never
            // destroy the data users actually care about.
            final salvagedFavorites = await _salvageFavorites();
            await m.deleteTable('pokemon_cache');
            await m.createTable(pokemonCache);
            for (final fav in salvagedFavorites) {
              await into(pokemonCache).insert(fav, mode: InsertMode.insertOrIgnore);
            }
            recreated = true;
          }
          // A freshly created table already has every column, so only add
          // columns when we upgraded an existing table in place.
          if (from < 7 && !recreated) {
            await m.addColumn(pokemonCache, pokemonCache.flavorText);
          }
          if (from < 8) {
            // Purge legacy per-row API blobs (up to hundreds of KB each);
            // typed columns are the single source of truth now.
            await customStatement('UPDATE pokemon_cache SET json_data = NULL');
          }
        },
      );

  /// Reads favorite rows from a possibly-outdated table shape. Returns stub
  /// rows carrying at least id/name/types so the next seed can fill in details
  /// while preserving the favorite flag.
  Future<List<PokemonCacheData>> _salvageFavorites() async {
    try {
      final rows = await customSelect(
        'SELECT id, name, COALESCE(types, \'\') AS types FROM pokemon_cache WHERE is_favorite = 1',
        readsFrom: {pokemonCache},
      ).get();
      return rows.map((row) {
        final name = row.data['name'] as String?;
        return PokemonCacheData(
          id: row.data['id'] as int,
          speciesId: null,
          name: name ?? 'Unknown',
          types: (row.data['types'] as String?) ?? '',
          isFavorite: true,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  // Insert or Update database record
  Future<void> cachePokemon(PokemonCacheData pokemon) async {
    await into(pokemonCache).insertOnConflictUpdate(pokemon);
  }

  /// Insert or Update many records in one batched transaction.
  /// Overwrites cached data columns but always preserves the user's
  /// favorites, which must survive re-seeding and refreshes.
  Future<void> cacheAllPokemon(List<PokemonCacheData> pokemons) async {
    final favoriteIds = (await (select(pokemonCache)..where((t) => t.isFavorite.equals(true))).get())
        .map((row) => row.id)
        .toSet();

    await batch((b) {
      b.insertAllOnConflictUpdate(pokemonCache, pokemons);
    });

    if (favoriteIds.isNotEmpty) {
      // Plain UPDATEs only touch the flag; a REPLACE here would wipe the rows.
      for (final id in favoriteIds) {
        await (update(pokemonCache)..where((t) => t.id.equals(id)))
            .write(const PokemonCacheCompanion(isFavorite: Value(true)));
      }
    }
  }

  // Get cached pokemon by ID
  Future<PokemonCacheData?> getPokemonById(int id) {
    return (select(pokemonCache)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(int id, bool isFavoriteValue) async {
    await (update(pokemonCache)..where((t) => t.id.equals(id))).write(
      PokemonCacheCompanion(
        isFavorite: Value(isFavoriteValue),
      ),
    );
  }

  // Search cached pokemon offline.
  // Type matching wraps the CSV column in commas (',grass,poison,' LIKE '%,fire,%')
  // so filters match whole list items instead of substrings.
  // Ordering uses COALESCE(speciesId, id) so form rows with NULL speciesId
  // sort by their own id instead of inconsistently floating to the top.
  Future<List<PokemonCacheData>> searchPokemon(String query, String typeFilter) {
    var querySelect = select(pokemonCache);
    if (query.isNotEmpty) {
      querySelect = querySelect..where((t) => t.name.like('%${query.toLowerCase()}%'));
    }
    if (typeFilter.isNotEmpty) {
      final needle = '%,${typeFilter.toLowerCase()},%';
      querySelect = querySelect..where((t) => (Constant(',') + t.types + const Constant(',')).like(needle));
    }
    querySelect = querySelect..orderBy([
      (t) => OrderingTerm(expression: coalesce([t.speciesId, t.id]), mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
    ]);
    return querySelect.get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pokedex.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
