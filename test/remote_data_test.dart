import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:pokedex_flutter/core/remote_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('validateChampionsPayload', () {
    test('accepts the baked champions seed', () async {
      final data = jsonDecode(
        await rootBundle.loadString(kChampionsAssetPath),
      );
      expect(validateChampionsPayload(data), isNull);
    });

    test('rejects non-objects, empty rosters and malformed entries', () {
      expect(validateChampionsPayload('[]'), isNotNull);
      expect(validateChampionsPayload({'pokemon': []}), isNotNull);
      expect(
        validateChampionsPayload({
          'source': 'x',
          'pokemon': [],
          'items': ['Leftovers'],
        }),
        isNotNull,
        reason: 'empty roster',
      );
      expect(
        validateChampionsPayload({
          'source': 'x',
          'pokemon': [
            {'id': 3, 'name': 'Venusaur'},
          ],
          'items': ['Leftovers'],
        }),
        isNotNull,
        reason: 'entry missing dex',
      );
      expect(
        validateChampionsPayload({
          'source': 'x',
          'pokemon': [
            {'id': '3', 'name': 'Venusaur', 'dex': 3},
          ],
          'items': ['Leftovers'],
        }),
        isNotNull,
        reason: 'string id',
      );
      expect(
        validateChampionsPayload({
          'source': 'x',
          'pokemon': [
            {'id': 3, 'name': 'Venusaur', 'dex': 3},
          ],
          'items': [],
        }),
        isNotNull,
        reason: 'empty items',
      );
      expect(
        validateChampionsPayload({
          'source': '',
          'pokemon': [
            {'id': 3, 'name': 'Venusaur', 'dex': 3},
          ],
          'items': ['Leftovers'],
        }),
        isNotNull,
        reason: 'blank source',
      );
    });

    test('accepts a minimal valid payload', () {
      expect(
        validateChampionsPayload({
          'source': 'projectpokemon/champout@abc123',
          'pokemon': [
            {'id': 3, 'name': 'Venusaur', 'dex': 3},
          ],
          'items': ['Leftovers'],
        }),
        isNull,
      );
    });
  });

  group('validateSpeedTiersPayload', () {
    test('accepts the baked speed tiers', () async {
      final data = jsonDecode(
        await rootBundle.loadString(kSpeedTiersAssetPath),
      );
      expect(validateSpeedTiersPayload(data), isNull);
    });

    test('rejects missing/malformed tiers', () {
      expect(validateSpeedTiersPayload({'tiers': []}), isNotNull);
      expect(
        validateSpeedTiersPayload({
          'source': 'x',
          'tiers': [
            {
              'id': 3,
              'rank': 1,
              'base': 80,
              'noInvest': 100,
              'maxPlus': 145,
              // max missing
              'min': 90,
              'scarf': 217,
              'tailwind': 290,
              'paralyzed': 72,
            },
          ],
        }),
        isNotNull,
      );
      expect(
        validateSpeedTiersPayload({
          'source': 'x',
          'tiers': [
            {
              'id': 3,
              'rank': '1',
              'base': 80,
              'noInvest': 100,
              'maxPlus': 145,
              'max': 132,
              'min': 90,
              'scarf': 217,
              'tailwind': 290,
              'paralyzed': 72,
            },
          ],
        }),
        isNotNull,
        reason: 'string rank',
      );
    });
  });

  group('validateMovesPayload', () {
    test('accepts the baked moves seed', () async {
      final data = jsonDecode(
        await rootBundle.loadString(kMovesAssetPath),
      );
      expect(validateMovesPayload(data), isNull);
    });

    test('rejects empty and malformed entries', () {
      expect(validateMovesPayload([]), isNotNull);
      expect(
        validateMovesPayload([{'id': 1}]),
        isNotNull,
        reason: 'missing name/type/cls',
      );
      expect(
        validateMovesPayload([{'id': '1', 'name': 'pound', 'type': 'normal', 'cls': 'physical'}]),
        isNotNull,
        reason: 'string id',
      );
    });
  });

  group('RemoteDataStore', () {
    late Directory tempDir;
    late RemoteDataStore store;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('remote_data_test');
      store = RemoteDataStore(directory: Future.value(tempDir));
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('read returns null before anything is written', () async {
      expect(await store.read(kRemoteChampionsFile), isNull);
    });

    test('write/read/clear round-trips', () async {
      await store.write(kRemoteChampionsFile, '{"a":1}');
      expect(await store.read(kRemoteChampionsFile), '{"a":1}');
      await store.clear();
      expect(await store.read(kRemoteChampionsFile), isNull);
      // clear() must also be safe when there is nothing to delete.
      await store.clear();
    });
  });

  group('activeChampionsData', () {
    late Directory tempDir;
    late RemoteDataStore store;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('remote_data_test');
      store = RemoteDataStore(directory: Future.value(tempDir));
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('falls back to the baked source without an override', () async {
      final data = await activeChampionsData(store);
      expect(data.fromOverride, isFalse);
      expect(data.source, contains('projectpokemon/champout'));
    });

    test('reports the override source when one is installed', () async {
      await store.write(
        kRemoteChampionsFile,
        jsonEncode({
          'source': 'projectpokemon/champout@deadbeef',
          'pokemon': [
            {'id': 3, 'name': 'Venusaur', 'dex': 3},
          ],
          'items': ['Leftovers'],
        }),
      );
      final data = await activeChampionsData(store);
      expect(data.fromOverride, isTrue);
      expect(data.source, 'projectpokemon/champout@deadbeef');
    });

    test('a corrupt override still counts as active but yields no source',
        () async {
      await store.write(kRemoteChampionsFile, 'not json');
      final data = await activeChampionsData(store);
      expect(data.fromOverride, isTrue);
      expect(data.source, isNull);
    });
  });
}
