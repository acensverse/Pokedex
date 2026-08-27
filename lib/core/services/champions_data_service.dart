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
        'learnsets.json',
      ];
      for (final f in files) {
        final file = await _getFile(f);
        if (!await file.exists() || (await file.length()) == 0) return false;
      }
      
      final rosterFile = await _getFile('roster.json');
      final decoded = jsonDecode(await rosterFile.readAsString());
      if (decoded is String) {
        return false;
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
      'learnsets.json':
          'https://raw.githubusercontent.com/otterlyclueless/pokemon-champions-data/main/learnsets/learnsets.json',
    };

    double total = targets.length.toDouble();
    double current = 0;

    for (final entry in targets.entries) {
      final file = await _getFile(entry.key);
      final response = await _dio.get(entry.value);
      if (response.data != null) {
        final dataStr = response.data is String 
            ? response.data as String 
            : jsonEncode(response.data);
        await file.writeAsString(dataStr);
      }
      current += 1.0;
      if (onProgress != null) {
        onProgress(current / total);
      }
    }
  }



  void _injectMissingForms(List rosterRaw) {
    final meowsticBase = rosterRaw.firstWhere((r) => r['name'] == 'Meowstic', orElse: () => null);
    final meowsticMega = rosterRaw.firstWhere((r) => r['name'] == 'Mega Meowstic', orElse: () => null);

    final missingForms = [
      {'name': 'Blaze Breed Paldean Tauros', 'dexNumber': 128, 'types': ['Fighting', 'Fire'], 'form': 'Regional'},
      {'name': 'Aqua Breed Paldean Tauros', 'dexNumber': 128, 'types': ['Fighting', 'Water'], 'form': 'Regional'},
      {'name': 'Heat Rotom', 'dexNumber': 479, 'types': ['Electric', 'Fire'], 'form': 'Regional'},
      {'name': 'Wash Rotom', 'dexNumber': 479, 'types': ['Electric', 'Water'], 'form': 'Regional'},
      {'name': 'Frost Rotom', 'dexNumber': 479, 'types': ['Electric', 'Ice'], 'form': 'Regional'},
      {'name': 'Fan Rotom', 'dexNumber': 479, 'types': ['Electric', 'Flying'], 'form': 'Regional'},
      {'name': 'Mow Rotom', 'dexNumber': 479, 'types': ['Electric', 'Grass'], 'form': 'Regional'},
      {'name': 'Mega Raichu X', 'dexNumber': 26, 'types': ['Electric'], 'form': 'Mega'},
      {'name': 'Mega Raichu Y', 'dexNumber': 26, 'types': ['Electric'], 'form': 'Mega'},
      {'name': 'Midnight Lycanroc', 'dexNumber': 745, 'types': ['Rock'], 'form': 'Regional'},
      {'name': 'Dusk Lycanroc', 'dexNumber': 745, 'types': ['Rock'], 'form': 'Regional'},
      {'name': 'Male Meowstic', 'dexNumber': 678, 'types': ['Psychic'], 'form': 'Base', if (meowsticBase != null) 'abilities': meowsticBase['abilities']},
      {'name': 'Female Meowstic', 'dexNumber': 678, 'types': ['Psychic'], 'form': 'Base', if (meowsticBase != null) 'abilities': meowsticBase['abilities']},
      {'name': 'Mega Meowstic Male', 'dexNumber': 678, 'types': ['Psychic'], 'form': 'Mega', if (meowsticMega != null) 'abilities': meowsticMega['abilities']},
      {'name': 'Mega Meowstic Female', 'dexNumber': 678, 'types': ['Psychic'], 'form': 'Mega', if (meowsticMega != null) 'abilities': meowsticMega['abilities']},
    ];
    
    // Remove generic un-gendered meowstic to avoid duplicates/broken images
    rosterRaw.removeWhere((r) => r['name'] == 'Meowstic' || r['name'] == 'Mega Meowstic');

    for (final m in missingForms) {
      if (!rosterRaw.any((r) => r['name'] == m['name'])) {
        rosterRaw.add(m);
      }
    }
  }

  Future<List<Pokemon>> getPokemonList() async {
    final rosterFile = await _getFile('roster.json');
    final statsFile = await _getFile('stats.json');

    final rosterRaw = jsonDecode(await rosterFile.readAsString()) as List;
    final statsRaw = jsonDecode(await statsFile.readAsString()) as List;

    _injectMissingForms(rosterRaw);

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

    // Ensure order is correct
    rosterRaw.sort((a, b) {
      final dexA = (a['dexNumber'] as int?) ?? 0;
      final dexB = (b['dexNumber'] as int?) ?? 0;
      if (dexA != dexB) return dexA.compareTo(dexB);
      
      final formA = (a['form'] as String?) ?? '';
      final formB = (b['form'] as String?) ?? '';
      if (formA == 'Base' && formB != 'Base') return -1;
      if (formB == 'Base' && formA != 'Base') return 1;
      return formA.compareTo(formB);
    });

    for (var i = 0; i < rosterRaw.length; i++) {
      final r = rosterRaw[i];
      final name = r['name'] as String;
      final dexNumber = r['dexNumber'] as int;
      final form = r['form'] as String;

      final lowerName = name.toLowerCase();
      var mappingName = lowerName;
      // Alias Paldean Tauros to Combat Breed for standard ID mapping
      if (mappingName == 'paldean tauros') {
        mappingName = 'combat breed paldean tauros';
      } else if (mappingName == 'lycanroc') {
        mappingName = 'midday lycanroc';
      }

      // Resolve ID
      var resolvedId = nameToIdMap[mappingName];
      if (resolvedId == null) {
        if (form == 'Base') {
          resolvedId = dexNumber;
        } else {
          // Fallback if standard ID mapping fails
          resolvedId = 10000 + dexNumber + i;
        }
      }

      var statsName = lowerName;
      if (statsName == 'male meowstic' || statsName == 'female meowstic') {
        statsName = 'meowstic';
      } else if (statsName == 'mega meowstic male' || statsName == 'mega meowstic female') {
        statsName = 'mega meowstic';
      }

      final s = statsMap[statsName] ?? {};

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
    _injectMissingForms(rosterRaw);

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
      var lowerName = name.toLowerCase();
      if (lowerName == 'paldean tauros') {
        lowerName = 'combat breed paldean tauros';
      } else if (lowerName == 'lycanroc') {
        lowerName = 'midday lycanroc';
      }
      var resolvedId = nameToIdMap[lowerName];
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

    // Download and load learnsets.json
    final learnsetsFile = await _getFile('learnsets.json');
    Map<String, dynamic> learnsetsMap = {};
    if (await learnsetsFile.exists()) {
      learnsetsMap = jsonDecode(await learnsetsFile.readAsString()) as Map<String, dynamic>;
    }

    // Build reverse map of moves -> list of pokemon IDs that learn it
    final moveLearners = <String, List<int>>{};
    
    // learnsetsMap is keyed by Pokemon name
    learnsetsMap.forEach((pokemonName, data) {
      if (data is Map && data['moves'] is List) {
        final lowerPokemonName = pokemonName.toLowerCase();
        
        // Find standard ID for this pokemon
        var mappingName = lowerPokemonName;
        if (mappingName == 'paldean tauros') {
          mappingName = 'combat breed paldean tauros';
        } else if (mappingName == 'lycanroc') {
          mappingName = 'midday lycanroc';
        }
        
        List<int> pIds = [];
        
        if (mappingName == 'meowstic') {
          if (nameToIdMap['male meowstic'] != null) pIds.add(nameToIdMap['male meowstic']!);
          if (nameToIdMap['female meowstic'] != null) pIds.add(nameToIdMap['female meowstic']!);
        } else if (mappingName == 'mega meowstic') {
          if (nameToIdMap['mega meowstic male'] != null) pIds.add(nameToIdMap['mega meowstic male']!);
          if (nameToIdMap['mega meowstic female'] != null) pIds.add(nameToIdMap['mega meowstic female']!);
        } else {
          var pId = nameToIdMap[mappingName];
          if (pId == null) {
            // Find fallback ID from rosterRaw
            final rIndex = rosterRaw.indexWhere((r) => (r['name'] as String).toLowerCase() == lowerPokemonName);
            if (rIndex >= 0) {
              final r = rosterRaw[rIndex];
              pId = r['form'] == 'Base' ? r['dexNumber'] as int : 10000 + (r['dexNumber'] as int) + rIndex;
            }
          }
          if (pId != null) pIds.add(pId);
        }
        
        for (final pId in pIds) {
          for (final moveObj in data['moves']) {
            if (moveObj is Map && moveObj['name'] is String) {
              final moveName = (moveObj['name'] as String).toLowerCase();
              moveLearners.putIfAbsent(moveName, () => []).add(pId);
            }
          }
        }
      }
    });

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
          pri: priority,
          gen: 'champions',
          ail: 'none',
          eff: desc,
          flavor: desc,
          learn: moveLearners[name.toLowerCase()] ?? [],
          contest: null,
          learnDetails: const [],
        ),
      );
    }
    return list;
  }
}
