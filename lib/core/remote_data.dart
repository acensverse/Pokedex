import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the app fetches regenerated Champions data from: this repo's
/// `assets/` directory on main, refreshed by
/// .github/workflows/update-data.yml (projectpokemon/champout upstream).
const String kRemoteDataBaseUrl =
    'https://raw.githubusercontent.com/acensverse/Pokedex/main/assets/';

/// Baked asset names that can be overridden at runtime.
const String kRemoteChampionsFile = 'champions_seed.json';
const String kRemoteSpeedTiersFile = 'speed_tiers.json';

/// Baked asset paths, used when no override exists.
const String kChampionsAssetPath = 'assets/champions_seed.json';
const String kSpeedTiersAssetPath = 'assets/speed_tiers.json';

/// How long an auto-check result stays trusted before the next app start
/// checks again (manual checks bypass this).
const Duration kRemoteDataCheckInterval = Duration(hours: 6);

// ---------------------------------------------------------------------------
// Validators — pure functions so they can be unit-tested; they also run on the
// baked assets in test/remote_data_test.dart as a release check.
// ---------------------------------------------------------------------------

/// Returns null when [data] matches the champions_seed.json schema, otherwise
/// a human-readable reason it was rejected.
String? validateChampionsPayload(dynamic data) {
  if (data is! Map<String, dynamic>) return 'not a JSON object';
  if (data['source'] is! String || (data['source'] as String).isEmpty) {
    return 'missing source';
  }
  final pokemon = data['pokemon'];
  if (pokemon is! List || pokemon.isEmpty) {
    return 'pokemon roster missing or empty';
  }
  for (final entry in pokemon) {
    if (entry is! Map ||
        entry['id'] is! int ||
        entry['name'] is! String ||
        entry['dex'] is! int) {
      return 'malformed pokemon entry: $entry';
    }
  }
  final items = data['items'];
  if (items is! List || items.isEmpty) {
    return 'items list missing or empty';
  }
  for (final item in items) {
    if (item is! String) return 'malformed item entry: $item';
  }
  return null;
}

/// Returns null when [data] matches the speed_tiers.json schema, otherwise a
/// human-readable reason it was rejected.
String? validateSpeedTiersPayload(dynamic data) {
  if (data is! Map<String, dynamic>) return 'not a JSON object';
  if (data['source'] is! String || (data['source'] as String).isEmpty) {
    return 'missing source';
  }
  final tiers = data['tiers'];
  if (tiers is! List || tiers.isEmpty) return 'tiers missing or empty';
  const keys = [
    'id', 'rank', 'base', 'noInvest', 'maxPlus',
    'max', 'min', 'scarf', 'tailwind', 'paralyzed',
  ];
  for (final entry in tiers) {
    if (entry is! Map) return 'malformed tier entry: $entry';
    for (final key in keys) {
      if (entry[key] is! int) {
        return 'tier ${entry['id']} has no integer "$key"';
      }
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
// Store — override files under the app-support directory. A missing override
// means "use the baked asset", so an interrupted update can never leave the
// app without usable data.
// ---------------------------------------------------------------------------

/// Reads/writes/clears the runtime data overrides in
/// `<applicationSupport>/remote_overrides/`. File names are the asset names.
class RemoteDataStore {
  RemoteDataStore({Future<Directory>? directory}) : _injected = directory;

  /// Test seam: when set, overrides land here instead of app support.
  final Future<Directory>? _injected;

  Future<Directory> _directory() async {
    final injected = _injected;
    if (injected != null) return injected;
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'remote_overrides'));
  }

  /// The override contents for [fileName], or null when absent/empty.
  Future<String?> read(String fileName) async {
    try {
      final file = File(p.join((await _directory()).path, fileName));
      if (!file.existsSync()) return null;
      return file.readAsStringSync();
    } catch (_) {
      // A corrupt/unreadable override is the same as no override.
      return null;
    }
  }

  Future<void> write(String fileName, String contents) async {
    final dir = await _directory();
    dir.createSync(recursive: true);
    File(p.join(dir.path, fileName)).writeAsStringSync(contents, flush: true);
  }

  /// Deletes every override; providers fall back to the baked assets.
  Future<void> clear() async {
    final dir = await _directory();
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}

final remoteDataStoreProvider = Provider<RemoteDataStore>((ref) {
  return RemoteDataStore();
});

/// Bumped whenever the override set changes; the champions and speed-tiers
/// providers watch this so they reload without an app restart.
final remoteDataVersionProvider = StateProvider<int>((ref) => 0);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

enum RemoteDataStatus { idle, checking, upToDate, updated, failed }

/// Downloads regenerated Champions data and installs it as overrides.
///
/// One probe (champions) decides whether anything changed — speed tiers are
/// derived from the same roster, so their `source` moves in lockstep.
class RemoteDataController extends Notifier<RemoteDataStatus> {
  static const String _lastCheckKey = 'remote_data_last_check_ms';

  @override
  RemoteDataStatus build() => RemoteDataStatus.idle;

  /// Auto-check on app start, throttled by [kRemoteDataCheckInterval].
  Future<void> maybeAutoCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_lastCheckKey) ?? 0;
    final elapsed =
        DateTime.now().millisecondsSinceEpoch - last;
    if (elapsed < kRemoteDataCheckInterval.inMilliseconds) return;
    // Stamped before the network work: a flaky connection shouldn't retry on
    // every cold start; the Settings button force-checks regardless.
    await prefs.setInt(
      _lastCheckKey,
      DateTime.now().millisecondsSinceEpoch,
    );
    await checkForUpdates();
  }

  /// Checks upstream and installs overrides when the `source` moved ahead.
  /// Returns the resulting [RemoteDataStatus]; forces the network round-trip.
  Future<RemoteDataStatus> checkForUpdates() async {
    if (state == RemoteDataStatus.checking) return state;
    state = RemoteDataStatus.checking;
    try {
      final store = ref.read(remoteDataStoreProvider);
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.plain,
        ),
      );

      final championsRes =
          await dio.get<String>('$kRemoteDataBaseUrl$kRemoteChampionsFile');
      final championsData =
          jsonDecode(championsRes.data as String) as Map<String, dynamic>;
      final championsError = validateChampionsPayload(championsData);
      if (championsError != null) {
        throw FormatException('champions payload rejected: $championsError');
      }

      final activeSource = await _activeChampionsSource(store);
      if (championsData['source'] == activeSource) {
        state = RemoteDataStatus.upToDate;
        return state;
      }

      // New source: fetch the companion file too, validate both, then install.
      final tiersRes =
          await dio.get<String>('$kRemoteDataBaseUrl$kRemoteSpeedTiersFile');
      final tiersData =
          jsonDecode(tiersRes.data as String) as Map<String, dynamic>;
      final tiersError = validateSpeedTiersPayload(tiersData);
      if (tiersError != null) {
        throw FormatException('speed tiers payload rejected: $tiersError');
      }
      if (tiersData['source'] != championsData['source']) {
        throw StateError(
          'speed tiers source ${tiersData['source']} does not match champions source ${championsData['source']}',
        );
      }

      await store.write(kRemoteChampionsFile, jsonEncode(championsData));
      await store.write(kRemoteSpeedTiersFile, jsonEncode(tiersData));
      ref.read(remoteDataVersionProvider.notifier).state++;
      state = RemoteDataStatus.updated;
      return state;
    } catch (_) {
      state = RemoteDataStatus.failed;
      return state;
    }
  }

  /// Deletes the overrides so providers fall back to the baked assets again.
  Future<void> revertToBaked() async {
    await ref.read(remoteDataStoreProvider).clear();
    ref.read(remoteDataVersionProvider.notifier).state++;
    state = RemoteDataStatus.idle;
  }

  /// The `source` of the champions data providers are currently serving:
  /// the override when present, else the baked asset's source. Lives here
  /// (not in champions.dart) to keep the import direction one-way.
  Future<String?> _activeChampionsSource(RemoteDataStore store) async {
    final data = await activeChampionsData(store);
    return data.source;
  }
}

final remoteDataControllerProvider =
    NotifierProvider<RemoteDataController, RemoteDataStatus>(
  RemoteDataController.new,
);

/// What champions data the app is currently serving.
class ActiveChampionsData {
  final String? source;
  final bool fromOverride;
  const ActiveChampionsData({required this.source, required this.fromOverride});
}

/// Which champions data set the app is currently serving: the override source
/// when one is installed, otherwise the baked asset's source (null when even
/// the baked file is unreadable). Watches [remoteDataVersionProvider] so it
/// re-evaluates after updates and reverts.
final activeChampionsDataProvider = FutureProvider<ActiveChampionsData>(
  (ref) async {
    ref.watch(remoteDataVersionProvider);
    final store = ref.read(remoteDataStoreProvider);
    final override = await store.read(kRemoteChampionsFile);
    if (override != null) {
      String? source;
      try {
        final data = jsonDecode(override);
        if (data is Map<String, dynamic> &&
            data['source'] is String &&
            (data['source'] as String).isNotEmpty) {
          source = data['source'] as String;
        }
      } catch (_) {}
      return ActiveChampionsData(source: source, fromOverride: true);
    }
    final baked = await _bakedChampionsSource();
    return ActiveChampionsData(source: baked, fromOverride: false);
  },
);

Future<String?> _bakedChampionsSource() async {
  try {
    final data = jsonDecode(await rootBundle.loadString(kChampionsAssetPath))
        as Map<String, dynamic>;
    return data['source'] as String?;
  } catch (_) {
    return null;
  }
}

/// Resolves what champions data is active: override first (its own source),
/// else the baked asset's source.
Future<ActiveChampionsData> activeChampionsData(
  RemoteDataStore store,
) async {
  final override = await store.read(kRemoteChampionsFile);
  if (override != null) {
    String? source;
    try {
      final data = jsonDecode(override);
      if (data is Map<String, dynamic> &&
          data['source'] is String &&
          (data['source'] as String).isNotEmpty) {
        source = data['source'] as String;
      }
    } catch (_) {}
    return ActiveChampionsData(source: source, fromOverride: true);
  }
  final baked = await _bakedChampionsSource();
  return ActiveChampionsData(source: baked, fromOverride: false);
}
