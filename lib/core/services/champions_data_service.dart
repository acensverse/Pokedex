import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/pokemon.dart';
import '../../features/tools/abilities_screen.dart';
import '../../features/tools/items_screen.dart';
import '../../features/tools/moves_screen.dart';
import '../providers.dart';

final championsDataServiceProvider = Provider<ChampionsDataService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return ChampionsDataService(dio, ref);
});

class ChampionsDataService {
  final Dio _dio;
  final Ref _ref;

  ChampionsDataService(this._dio, this._ref);

  Future<File> _getFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/champions_$filename');
  }

  Future<bool> isDownloaded() async {
    try {
      final files = [
        'roster.json',
        'stats.json',
        'abilities.json',
        'items.json',
        'moves.json',
      ];
      for (final f in files) {
        final file = await _getFile(f);
        if (!await file.exists() || (await file.length()) == 0) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> downloadAll({void Function(double progress)? onProgress}) async {
    final targets = {
      'roster.json':
          'https://raw.githubusercontent.com/otterlyclueless/pokemon-champions-data/main/pokemon/roster.json',
      'stats.json':
          'https://raw.githubusercontent.com/otterlyclueless/pokemon-champions-data/main/pokemon/base-stats.json',
      'abilities.json':
          'https://raw.githubusercontent.com/otterlyclueless/pokemon-champions-data/main/abilities/abilities.json',
      'items.json':
          'https://raw.githubusercontent.com/otterlyclueless/pokemon-champions-data/main/items/items.json',
      'moves.json':
          'https://raw.githubusercontent.com/otterlyclueless/pokemon-champions-data/main/moves/moves.json',
    };

    double total = targets.length.toDouble();
    double current = 0;

    for (final entry in targets.entries) {
      final file = await _getFile(entry.key);
      final response = await _dio.get(entry.value);
      if (response.data != null) {
        await file.writeAsString(jsonEncode(response.data));
      }
      current += 1.0;
      if (onProgress != null) {
        onProgress(current / total);
      }
    }
  }

  Future<List<Pokemon>> getPokemonList() async {
    final rosterFile = await _getFile('roster.json');
    final statsFile = await _getFile('stats.json');

    final rosterRaw = jsonDecode(await rosterFile.readAsString()) as List;
    final statsRaw = jsonDecode(await statsFile.readAsString()) as List;

    // Load standard database pokemon list to map names to correct standard IDs
    final standardList = await _ref
        .read(pokemonRepositoryProvider)
        .getLocalPokemonList();
    final nameToIdMap = <String, int>{};
    for (final p in standardList) {
      nameToIdMap[p.name.toLowerCase()] = p.id;
      if (p.forms != null) {
        try {
          final formsJson = jsonDecode(p.forms!) as List;
          for (final f in formsJson) {
            if (f is Map && f['name'] is String && f['id'] is int) {
              nameToIdMap[(f['name'] as String).toLowerCase()] = f['id'] as int;
            }
          }
        } catch (_) {}
      }
    }

    final statsMap = {
      for (final item in statsRaw) (item['name'] as String).toLowerCase(): item,
    };

    final mappedList = <Pokemon>[];

    for (var i = 0; i < rosterRaw.length; i++) {
      final r = rosterRaw[i];
      final name = r['name'] as String;
      final dexNumber = r['dexNumber'] as int;
      final form = r['form'] as String;

      final lowerName = name.toLowerCase();
      // Resolve ID
      var resolvedId = nameToIdMap[lowerName];
      if (resolvedId == null) {
        if (form == 'Base') {
          resolvedId = dexNumber;
        } else {
          // Fallback if standard ID mapping fails
          resolvedId = 10000 + dexNumber + i;
        }
      }

      final s = statsMap[lowerName] ?? {};

      final typesList =
          (r['types'] as List?)
              ?.map(
                (t) => PokemonTypeSlot(
                  slot: 1,
                  type: PokemonType(name: (t as String).toLowerCase(), url: ''),
                ),
              )
              .toList() ??
          [];

      final statsList = [
        PokemonStatSlot(
          baseStat: (s['hp'] as int?) ?? 0,
          effort: 0,
          stat: const PokemonStat(name: 'hp', url: ''),
        ),
        PokemonStatSlot(
          baseStat: (s['atk'] as int?) ?? 0,
          effort: 0,
          stat: const PokemonStat(name: 'attack', url: ''),
        ),
        PokemonStatSlot(
          baseStat: (s['def'] as int?) ?? 0,
          effort: 0,
          stat: const PokemonStat(name: 'defense', url: ''),
        ),
        PokemonStatSlot(
          baseStat: (s['spa'] as int?) ?? 0,
          effort: 0,
          stat: const PokemonStat(name: 'special-attack', url: ''),
        ),
        PokemonStatSlot(
          baseStat: (s['spd'] as int?) ?? 0,
          effort: 0,
          stat: const PokemonStat(name: 'special-defense', url: ''),
        ),
        PokemonStatSlot(
          baseStat: (s['spe'] as int?) ?? 0,
          effort: 0,
          stat: const PokemonStat(name: 'speed', url: ''),
        ),
      ];

      // Parse abilities
      final abilitiesMap = r['abilities'] as Map?;
      final abilitiesList = <PokemonAbilitySlot>[];
      if (abilitiesMap != null) {
        var slotIndex = 1;
        abilitiesMap.forEach((key, val) {
          abilitiesList.add(
            PokemonAbilitySlot(
              isHidden: key == 'H',
              slot: slotIndex++,
              ability: PokemonAbilityInfo(
                name: (val as String).toLowerCase().replaceAll(' ', '-'),
                url: '',
              ),
            ),
          );
        });
      }

      mappedList.add(
        Pokemon(
          id: resolvedId,
          speciesId: dexNumber,
          name: name,
          height: 10,
          weight: 100,
          baseExperience: 100,
          types: typesList,
          stats: statsList,
          abilities: abilitiesList,
          moves: const [],
          forms: null,
          evolutionInfo: null,
        ),
      );
    }

    return mappedList;
  }

  Future<List<AbilityEntry>> getAbilities() async {
    final file = await _getFile('abilities.json');
    final raw = jsonDecode(await file.readAsString()) as List;

    final rosterFile = await _getFile('roster.json');
    final rosterRaw = jsonDecode(await rosterFile.readAsString()) as List;

    // Build mapping: ability name -> pokemon IDs
    final standardList = await _ref
        .read(pokemonRepositoryProvider)
        .getLocalPokemonList();
    final nameToIdMap = <String, int>{};
    for (final p in standardList) {
      nameToIdMap[p.name.toLowerCase()] = p.id;
      if (p.forms != null) {
        try {
          final formsJson = jsonDecode(p.forms!) as List;
          for (final f in formsJson) {
            if (f is Map && f['name'] is String && f['id'] is int) {
              nameToIdMap[(f['name'] as String).toLowerCase()] = f['id'] as int;
            }
          }
        } catch (_) {}
      }
    }

    final abilityPokemonMap = <String, List<int>>{};
    final abilityHiddenMap = <String, List<int>>{};

    for (var i = 0; i < rosterRaw.length; i++) {
      final r = rosterRaw[i];
      final name = r['name'] as String;
      final dexNumber = r['dexNumber'] as int;
      final form = r['form'] as String;
      var resolvedId = nameToIdMap[name.toLowerCase()];
      if (resolvedId == null) {
        resolvedId = form == 'Base' ? dexNumber : 10000 + dexNumber + i;
      }

      final abilitiesMap = r['abilities'] as Map?;
      if (abilitiesMap != null) {
        abilitiesMap.forEach((key, val) {
          final abName = (val as String).toLowerCase();
          final isHidden = key == 'H';
          if (isHidden) {
            abilityHiddenMap.putIfAbsent(abName, () => []).add(resolvedId!);
          }
          abilityPokemonMap.putIfAbsent(abName, () => []).add(resolvedId!);
        });
      }
    }

    final list = <AbilityEntry>[];
    for (var i = 0; i < raw.length; i++) {
      final a = raw[i];
      final abName = a['name'] as String;
      final normName = abName.toLowerCase();
      list.add(
        AbilityEntry(
          id: i + 1,
          name: abName,
          gen: 'champions',
          eff: a['description'] as String?,
          flavor: a['description'] as String?,
          pokemon: abilityPokemonMap[normName] ?? [],
          hidden: abilityHiddenMap[normName] ?? [],
        ),
      );
    }
    return list;
  }

  Future<List<ItemEntry>> getItems() async {
    final file = await _getFile('items.json');
    final raw = jsonDecode(await file.readAsString()) as List;
    final list = <ItemEntry>[];
    for (var i = 0; i < raw.length; i++) {
      final item = raw[i];
      list.add(
        ItemEntry(
          id: i + 1,
          name: item['name'] as String,
          cost: 0,
          cat: 'champions',
          eff: item['description'] as String?,
          flavor: item['description'] as String?,
          sprite: null,
        ),
      );
    }
    return list;
  }

  Future<List<MoveEntry>> getMoves() async {
    final file = await _getFile('moves.json');
    final raw = jsonDecode(await file.readAsString()) as List;

    final rosterFile = await _getFile('roster.json');
    final rosterRaw = jsonDecode(await rosterFile.readAsString()) as List;

    // Load standard database pokemon list to map names to correct standard IDs
    final standardList = await _ref
        .read(pokemonRepositoryProvider)
        .getLocalPokemonList();
    final nameToIdMap = <String, int>{};
    for (final p in standardList) {
      nameToIdMap[p.name.toLowerCase()] = p.id;
      if (p.forms != null) {
        try {
          final formsJson = jsonDecode(p.forms!) as List;
          for (final f in formsJson) {
            if (f is Map && f['name'] is String && f['id'] is int) {
              nameToIdMap[(f['name'] as String).toLowerCase()] = f['id'] as int;
            }
          }
        } catch (_) {}
      }
    }

    // Since we don't have explicit move learnsets for Pokemon in moves.json (it's in learnsets/),
    // and learning moves isn't strictly used by anything other than detail lists,
    // we can default the learn list or leave it empty, or we can check learnsets/ if needed.
    // However, the user said "same with moves only show which are in api" which is handled by filtering inChampions.
    final list = <MoveEntry>[];
    for (var i = 0; i < raw.length; i++) {
      final m = raw[i];
      final inChampions = m['inChampions'] as bool? ?? false;
      if (!inChampions) continue;

      final name = m['name'] as String;
      final type = (m['type'] as String).toLowerCase();
      final category = (m['category'] as String).toLowerCase();
      final power = m['power'] as int? ?? 0;
      final accuracy = m['accuracy'] as int? ?? 100;
      final pp = m['pp'] as int? ?? 0;
      final priority = m['priority'] as int? ?? 0;
      final desc = m['description'] as String?;

      list.add(
        MoveEntry(
          id: i + 1,
          name: name,
          type: type,
          cls: category,
          power: power,
          acc: accuracy,
          pp: pp,
          prior: priority,
          ail: 'none',
          eff: desc,
          flavor: desc,
          learn: const [],
          contest: null,
          learnDetails: const [],
        ),
      );
    }
    return list;
  }
}
