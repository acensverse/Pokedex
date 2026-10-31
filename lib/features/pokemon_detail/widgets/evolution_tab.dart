import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/feedback_service.dart';
import '../../../core/providers.dart';
import '../../../core/utils/pokemon_helpers.dart';
import '../../../models/pokemon.dart';

class EvoNode {
  final int pokemonId;
  final String condition;
  final List<EvoNode> evolvesTo;
  Pokemon? pokemon;
  List<Pokemon> altForms = [];

  EvoNode({
    required this.pokemonId,
    required this.condition,
    required this.evolvesTo,
  });
}

class RegionalEvoSpec {
  final int parentId;
  final String parentLabel;
  final List<RegionalChildSpec> children;

  const RegionalEvoSpec({
    required this.parentId,
    this.parentLabel = 'Regional Form',
    required this.children,
  });
}

class RegionalChildSpec {
  final int childId;
  final String condition;
  final String label;

  const RegionalChildSpec({
    required this.childId,
    required this.condition,
    this.label = 'Regional Evolution',
  });
}

const _knownRegionalChains = <int, RegionalEvoSpec>{
  // Slowpoke split evolution
  79: RegionalEvoSpec(
    parentId: 10164,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 10165,
        condition: 'Use Galarica Cuff',
        label: 'Galarian Evolution',
      ),
      RegionalChildSpec(
        childId: 10172,
        condition: 'Use Galarica Wreath',
        label: 'Galarian Evolution',
      ),
    ],
  ),
  // Meowth
  52: RegionalEvoSpec(
    parentId: 10161,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 863,
        condition: 'Level 28',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Zigzagoon
  263: RegionalEvoSpec(
    parentId: 10174,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 10175,
        condition: 'Level 20',
        label: 'Galarian Form',
      ),
      RegionalChildSpec(
        childId: 862,
        condition: 'Level 35 at Night',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Farfetch'd
  83: RegionalEvoSpec(
    parentId: 10166,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 865,
        condition: 'Land 3 Critical Hits in 1 Battle',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Corsola
  222: RegionalEvoSpec(
    parentId: 10173,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 864,
        condition: 'Level 38',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Yamask
  562: RegionalEvoSpec(
    parentId: 10179,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 867,
        condition: 'Take 49+ Damage & Walk Under Stone Arch',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Mr. Mime / Mime Jr.
  122: RegionalEvoSpec(
    parentId: 10168,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 866,
        condition: 'Level 42',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Wooper
  194: RegionalEvoSpec(
    parentId: 10253,
    parentLabel: 'Paldean Form',
    children: [
      RegionalChildSpec(
        childId: 980,
        condition: 'Level 20',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Qwilfish
  211: RegionalEvoSpec(
    parentId: 10234,
    parentLabel: 'Hisuian Form',
    children: [
      RegionalChildSpec(
        childId: 904,
        condition: 'Use Barb Barrage 20x in Strong Style',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Sneasel
  215: RegionalEvoSpec(
    parentId: 10235,
    parentLabel: 'Hisuian Form',
    children: [
      RegionalChildSpec(
        childId: 903,
        condition: 'Use Razor Claw during Day',
        label: 'Regional Evolution',
      ),
    ],
  ),
  // Voltorb
  100: RegionalEvoSpec(
    parentId: 10231,
    parentLabel: 'Hisuian Form',
    children: [
      RegionalChildSpec(
        childId: 10232,
        condition: 'Use Leaf Stone',
        label: 'Hisuian Form',
      ),
    ],
  ),
  // Zorua
  570: RegionalEvoSpec(
    parentId: 10238,
    parentLabel: 'Hisuian Form',
    children: [
      RegionalChildSpec(
        childId: 10239,
        condition: 'Level 30',
        label: 'Hisuian Form',
      ),
    ],
  ),
  // Growlithe
  58: RegionalEvoSpec(
    parentId: 10229,
    parentLabel: 'Hisuian Form',
    children: [
      RegionalChildSpec(
        childId: 10230,
        condition: 'Use Fire Stone',
        label: 'Hisuian Form',
      ),
    ],
  ),
  // Ponyta
  77: RegionalEvoSpec(
    parentId: 10162,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 10163,
        condition: 'Level 40',
        label: 'Galarian Form',
      ),
    ],
  ),
  // Darumaka
  554: RegionalEvoSpec(
    parentId: 10176,
    parentLabel: 'Galarian Form',
    children: [
      RegionalChildSpec(
        childId: 10177,
        condition: 'Use Ice Stone',
        label: 'Galarian Form',
      ),
    ],
  ),
  // Sandshrew
  27: RegionalEvoSpec(
    parentId: 10101,
    parentLabel: 'Alolan Form',
    children: [
      RegionalChildSpec(
        childId: 10102,
        condition: 'Use Ice Stone',
        label: 'Alolan Form',
      ),
    ],
  ),
  // Vulpix
  37: RegionalEvoSpec(
    parentId: 10103,
    parentLabel: 'Alolan Form',
    children: [
      RegionalChildSpec(
        childId: 10104,
        condition: 'Use Ice Stone',
        label: 'Alolan Form',
      ),
    ],
  ),
  // Diglett
  50: RegionalEvoSpec(
    parentId: 10105,
    parentLabel: 'Alolan Form',
    children: [
      RegionalChildSpec(
        childId: 10106,
        condition: 'Level 26',
        label: 'Alolan Form',
      ),
    ],
  ),
  // Geodude
  74: RegionalEvoSpec(
    parentId: 10109,
    parentLabel: 'Alolan Form',
    children: [
      RegionalChildSpec(
        childId: 10110,
        condition: 'Level 25',
        label: 'Alolan Form',
      ),
      RegionalChildSpec(
        childId: 10111,
        condition: 'Trade',
        label: 'Alolan Form',
      ),
    ],
  ),
  // Grimer
  88: RegionalEvoSpec(
    parentId: 10112,
    parentLabel: 'Alolan Form',
    children: [
      RegionalChildSpec(
        childId: 10113,
        condition: 'Level 38',
        label: 'Alolan Form',
      ),
    ],
  ),
};

class EvoEntrySpec {
  final int id;
  final int? evolvesFrom;
  final String condition;

  const EvoEntrySpec({
    required this.id,
    this.evolvesFrom,
    required this.condition,
  });
}

const _customEvoChains = <int, List<EvoEntrySpec>>{
  // Eevee line (#133 - 8 Eeveelutions with Leaf Stone & Ice Stone)
  133: [
    EvoEntrySpec(id: 133, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 134, evolvesFrom: 133, condition: 'Use Water Stone'),
    EvoEntrySpec(id: 135, evolvesFrom: 133, condition: 'Use Thunder Stone'),
    EvoEntrySpec(id: 136, evolvesFrom: 133, condition: 'Use Fire Stone'),
    EvoEntrySpec(id: 196, evolvesFrom: 133, condition: 'Happiness Daytime'),
    EvoEntrySpec(id: 197, evolvesFrom: 133, condition: 'Happiness Nighttime'),
    EvoEntrySpec(id: 470, evolvesFrom: 133, condition: 'Use Leaf Stone'),
    EvoEntrySpec(id: 471, evolvesFrom: 133, condition: 'Use Ice Stone'),
    EvoEntrySpec(id: 700, evolvesFrom: 133, condition: 'Affection knowing a Fairy move'),
  ],
  // Eevee line (#133 - 8 Eeveelutions with Leaf Stone & Ice Stone)
  
  // Goomy line (#704)
  704: [
    EvoEntrySpec(id: 704, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 705, evolvesFrom: 704, condition: 'Level 40'),
    EvoEntrySpec(id: 10241, evolvesFrom: 704, condition: 'Level 40 in Hisui'), // 10241 = Hisuian Sliggoo
    EvoEntrySpec(id: 706, evolvesFrom: 705, condition: 'Level 50 in Rain'),
    EvoEntrySpec(id: 10242, evolvesFrom: 10241, condition: 'Level 50 in Rain'), // 10242 = Hisuian Goodra
  ],
  // Cyndaquil line (#155)
  155: [
    EvoEntrySpec(id: 155, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 156, evolvesFrom: 155, condition: 'Level 14'),
    EvoEntrySpec(id: 157, evolvesFrom: 156, condition: 'Level 36'),
    EvoEntrySpec(id: 10233, evolvesFrom: 156, condition: 'Level 36 in Hisui'), // 10233 = Hisuian Typhlosion
  ],
  // Oshawott line (#501)
  501: [
    EvoEntrySpec(id: 501, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 502, evolvesFrom: 501, condition: 'Level 17'),
    EvoEntrySpec(id: 503, evolvesFrom: 502, condition: 'Level 36'),
    EvoEntrySpec(id: 10236, evolvesFrom: 502, condition: 'Level 36 in Hisui'), // 10236 = Hisuian Samurott
  ],
  // Rowlet line (#722)
  722: [
    EvoEntrySpec(id: 722, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 723, evolvesFrom: 722, condition: 'Level 17'),
    EvoEntrySpec(id: 724, evolvesFrom: 723, condition: 'Level 34'),
    EvoEntrySpec(id: 10244, evolvesFrom: 723, condition: 'Level 34 in Hisui'), // 10244 = Hisuian Decidueye
  ],
  // Petilil (#548)
  548: [
    EvoEntrySpec(id: 548, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 549, evolvesFrom: 548, condition: 'Use Sun Stone'),
    EvoEntrySpec(id: 10237, evolvesFrom: 548, condition: 'Use Sun Stone in Hisui'), // 10237 = Hisuian Lilligant
  ],
  // Rufflet (#627)
  627: [
    EvoEntrySpec(id: 627, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 628, evolvesFrom: 627, condition: 'Level 54'),
    EvoEntrySpec(id: 10240, evolvesFrom: 627, condition: 'Level 54 in Hisui'), // 10240 = Hisuian Braviary
  ],
  // Bergmite (#712)
  712: [
    EvoEntrySpec(id: 712, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 713, evolvesFrom: 712, condition: 'Level 37'),
    EvoEntrySpec(id: 10243, evolvesFrom: 712, condition: 'Level 37 in Hisui'), // 10243 = Hisuian Avalugg
  ],
  // Koffing (#109)
  109: [
    EvoEntrySpec(id: 109, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 110, evolvesFrom: 109, condition: 'Level 35'),
    EvoEntrySpec(id: 10167, evolvesFrom: 109, condition: 'Level 35 in Galar'),
  ],
  // Exeggcute (#102)
  102: [
    EvoEntrySpec(id: 102, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 103, evolvesFrom: 102, condition: 'Use Leaf Stone'),
    EvoEntrySpec(id: 10114, evolvesFrom: 102, condition: 'Use Leaf Stone in Alola'),
  ],
  // Cubone (#104)
  104: [
    EvoEntrySpec(id: 104, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 105, evolvesFrom: 104, condition: 'Level 28'),
    EvoEntrySpec(id: 10115, evolvesFrom: 104, condition: 'Level 28 Night in Alola'),
  ],
  // Pikachu line (Pichu -> Pikachu -> Raichu / Alolan Raichu)
  172: [
    EvoEntrySpec(id: 172, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 25, evolvesFrom: 172, condition: 'High Friendship'),
    EvoEntrySpec(id: 26, evolvesFrom: 25, condition: 'Use Thunder Stone'),
    EvoEntrySpec(id: 10100, evolvesFrom: 25, condition: 'Use Thunder Stone in Alola'),
  ],
  // Scyther (#123)
  123: [
    EvoEntrySpec(id: 123, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 212, evolvesFrom: 123, condition: 'Trade holding Metal Coat'),
    EvoEntrySpec(id: 900, evolvesFrom: 123, condition: 'Use Black Augurite'),
  ],
  // Stantler (#234)
  234: [
    EvoEntrySpec(id: 234, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 899, evolvesFrom: 234, condition: 'Psyshield Bash 20x'),
  ],
  // Teddiursa (#216)
  216: [
    EvoEntrySpec(id: 216, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 217, evolvesFrom: 216, condition: 'Level 30'),
    EvoEntrySpec(id: 901, evolvesFrom: 217, condition: 'Use Peat Block in Full Moon'),
  ],
  // Basculin (#550)
  550: [
    EvoEntrySpec(id: 550, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 902, evolvesFrom: 550, condition: '294+ Recoil Damage'),
  ],

  // Parallel Regional Chains:
  10091: [
    EvoEntrySpec(id: 10091, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10092, evolvesFrom: 10091, condition: 'Level 20 Night'),
  ],
  10101: [
    EvoEntrySpec(id: 10101, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10102, evolvesFrom: 10101, condition: 'Use Ice Stone'),
  ],
  10103: [
    EvoEntrySpec(id: 10103, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10104, evolvesFrom: 10103, condition: 'Use Ice Stone'),
  ],
  10105: [
    EvoEntrySpec(id: 10105, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10106, evolvesFrom: 10105, condition: 'Level 26'),
  ],
  10107: [
    EvoEntrySpec(id: 10107, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10108, evolvesFrom: 10107, condition: 'High Friendship'),
  ],
  10161: [
    EvoEntrySpec(id: 10161, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 863, evolvesFrom: 10161, condition: 'Level 28'),
  ],
  10229: [
    EvoEntrySpec(id: 10229, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10230, evolvesFrom: 10229, condition: 'Use Fire Stone'),
  ],
  10109: [
    EvoEntrySpec(id: 10109, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10110, evolvesFrom: 10109, condition: 'Level 25'),
    EvoEntrySpec(id: 10111, evolvesFrom: 10110, condition: 'Trade'),
  ],
  10162: [
    EvoEntrySpec(id: 10162, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10163, evolvesFrom: 10162, condition: 'Level 40'),
  ],
  10164: [
    EvoEntrySpec(id: 10164, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10165, evolvesFrom: 10164, condition: 'Use Galarica Cuff'),
    EvoEntrySpec(id: 10172, evolvesFrom: 10164, condition: 'Use Galarica Wreath'),
  ],
  10166: [
    EvoEntrySpec(id: 10166, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 865, evolvesFrom: 10166, condition: 'Land 3 Critical Hits'),
  ],
  10112: [
    EvoEntrySpec(id: 10112, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10113, evolvesFrom: 10112, condition: 'Level 38'),
  ],
  10231: [
    EvoEntrySpec(id: 10231, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10232, evolvesFrom: 10231, condition: 'Use Leaf Stone'),
  ],
  439: [
    EvoEntrySpec(id: 439, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 122, evolvesFrom: 439, condition: 'Level Up with Mimic'),
    EvoEntrySpec(id: 10168, evolvesFrom: 439, condition: 'Level Up with Mimic in Galar'),
    EvoEntrySpec(id: 866, evolvesFrom: 10168, condition: 'Level 42'),
  ],
  10253: [
    EvoEntrySpec(id: 10253, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 980, evolvesFrom: 10253, condition: 'Level 20'),
  ],
  10234: [
    EvoEntrySpec(id: 10234, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 904, evolvesFrom: 10234, condition: 'Use Barb Barrage 20x'),
  ],
  10235: [
    EvoEntrySpec(id: 10235, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 903, evolvesFrom: 10235, condition: 'Use Razor Claw Day'),
  ],
  10173: [
    EvoEntrySpec(id: 10173, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 864, evolvesFrom: 10173, condition: 'Level 38'),
  ],
  10174: [
    EvoEntrySpec(id: 10174, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10175, evolvesFrom: 10174, condition: 'Level 20'),
    EvoEntrySpec(id: 862, evolvesFrom: 10175, condition: 'Level 35 Night'),
  ],
  10176: [
    EvoEntrySpec(id: 10176, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10177, evolvesFrom: 10176, condition: 'Use Ice Stone'),
  ],
  10179: [
    EvoEntrySpec(id: 10179, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 867, evolvesFrom: 10179, condition: '49+ DMG & Stone Arch'),
  ],
  10238: [
    EvoEntrySpec(id: 10238, evolvesFrom: null, condition: ''),
    EvoEntrySpec(id: 10239, evolvesFrom: 10238, condition: 'Level 30'),
  ],
};

final _childToRootMap = <int, int>{
  for (final entry in _customEvoChains.entries)
    for (final node in entry.value) node.id: entry.key,
};

class EvoChainParam {
  final String json;
  final int? pokemonId;
  final int? speciesId;

  const EvoChainParam({
    required this.json,
    this.pokemonId,
    this.speciesId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvoChainParam &&
          runtimeType == other.runtimeType &&
          json == other.json &&
          pokemonId == other.pokemonId &&
          speciesId == other.speciesId;

  @override
  int get hashCode => json.hashCode ^ pokemonId.hashCode ^ speciesId.hashCode;
}

/// Builds the evolution tree from baked seed data, resolving accurate Pokemon models offline.
final evolutionChainProvider = FutureProvider.family<EvoNode?, EvoChainParam>((
  ref,
  param,
) async {
  final repo = ref.read(pokemonRepositoryProvider);
  final targetId = param.pokemonId ?? param.speciesId;

  List<Map<String, dynamic>> rawEntries = [];

  if (targetId != null && _childToRootMap.containsKey(targetId)) {
    final rootId = _childToRootMap[targetId]!;
    final specs = _customEvoChains[rootId]!;
    rawEntries = specs
        .map(
          (s) => {
            'id': s.id,
            'name': '',
            'evolves_from': s.evolvesFrom,
            'condition': s.condition,
          },
        )
        .toList();
  } else {
    String rawJson = param.json;
    if ((rawJson.isEmpty || rawJson == '[]') && param.speciesId != null) {
      try {
        final speciesP = await repo.getPokemonDetails(param.speciesId!);
        if (speciesP.evolutionInfo != null && speciesP.evolutionInfo!.isNotEmpty) {
          rawJson = speciesP.evolutionInfo!;
        }
      } catch (_) {}
    }

    final parsed = (jsonDecode(rawJson) as List? ?? const []).cast<Map>();
    rawEntries = parsed
        .map(
          (e) {
            final id = e['id'] as int;
            String cond = (e['condition'] ?? '') as String;
            if (id == 470 && (cond.isEmpty || cond.toLowerCase().contains('level'))) {
              cond = 'Use Leaf Stone';
            } else if (id == 471 && (cond.isEmpty || cond.toLowerCase().contains('level'))) {
              cond = 'Use Ice Stone';
            }
            return {
              'id': id,
              'name': (e['name'] ?? '') as String,
              'evolves_from': e['evolves_from'] as int?,
              'condition': cond,
            };
          },
        )
        .toList();
  }

  if (rawEntries.isEmpty) return null;

  // Create nodes, linking children to parents
  final nodes = <int, EvoNode>{
    for (final e in rawEntries)
      e['id'] as int: EvoNode(
        pokemonId: e['id'] as int,
        condition: e['condition'] as String,
        evolvesTo: [],
      ),
  };

  EvoNode? root;
  for (final e in rawEntries) {
    final node = nodes[e['id'] as int]!;
    final from = e['evolves_from'] as int?;
    if (from == null) {
      root ??= node;
    } else {
      nodes[from]?.evolvesTo.add(node);
    }
  }

  if (root == null) return null;

  // Resolve display models from DB
  Future<void> resolveModels(EvoNode node) async {
    try {
      node.pokemon = await repo.getPokemonDetails(node.pokemonId);
    } catch (_) {
      node.pokemon = Pokemon(
        id: node.pokemonId,
        speciesId: node.pokemonId,
        name: '',
        height: 0,
        weight: 0,
        types: const [],
        stats: const [],
        abilities: const [],
        moves: const [],
      );
    }

    // 2. Resolve regional parent and child forms for defined regional chains
    if (_knownRegionalChains.containsKey(node.pokemonId)) {
      final spec = _knownRegionalChains[node.pokemonId]!;
      try {
        final parentP = await repo.getPokemonDetails(spec.parentId);
        if (!node.altForms.any((p) => p.id == spec.parentId)) {
          node.altForms.add(parentP);
        }
      } catch (_) {}

      for (final childSpec in spec.children) {
        try {
          final childP = await repo.getPokemonDetails(childSpec.childId);
          if (!node.altForms.any((p) => p.id == childSpec.childId)) {
            node.altForms.add(childP);
          }
        } catch (_) {}
      }
    }

    // 3. Resolve all alternate forms from forms JSON
    if (node.pokemon?.forms != null && node.pokemon!.forms!.isNotEmpty) {
      try {
        final parsedForms = jsonDecode(node.pokemon!.forms!);
        if (parsedForms is List) {
          for (final f in parsedForms) {
            if (f is Map) {
              final rawId = f['id'];
              final fId = rawId is num ? rawId.toInt() : int.tryParse(rawId.toString());
              if (fId != null && fId != node.pokemonId) {
                if (!node.altForms.any((p) => p.id == fId)) {
                  try {
                    final altP = await repo.getPokemonDetails(fId);
                    node.altForms.add(altP);
                  } catch (_) {}
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    for (final child in node.evolvesTo) {
      await resolveModels(child);
    }
  }

  await resolveModels(root);
  return root;
});

// =============================================================================
// PARSED EVOLUTION CONDITION & FORMATTER
// =============================================================================

class ParsedEvoCondition {
  final String text;
  final IconData icon;
  final String? itemImageUrl;
  final IconData? genderIcon;

  const ParsedEvoCondition({
    required this.text,
    required this.icon,
    this.itemImageUrl,
    this.genderIcon,
  });
}

const _itemSpriteBase = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items';

ParsedEvoCondition parseEvoCondition(String raw) {
  if (raw.trim().isEmpty) {
    return const ParsedEvoCondition(text: 'Evolves', icon: LucideIcons.sparkles);
  }

  final lower = raw.toLowerCase().trim();

  // Levels: "Level 16", "Level 32", "Lv. 20"
  final levelMatch = RegExp(r'(?:level|lv\.?)\s*(\d+)', caseSensitive: false).firstMatch(lower);
  if (levelMatch != null) {
    final lvl = levelMatch.group(1);
    final isFemale = lower.contains('female');
    final isMale = lower.contains('male') && !isFemale;
    final genderIcon = isFemale ? Icons.female : (isMale ? Icons.male : null);

    if (lower.contains('night')) {
      return ParsedEvoCondition(text: 'Lv. $lvl', icon: LucideIcons.moon, genderIcon: genderIcon);
    }
    if (lower.contains('day')) {
      return ParsedEvoCondition(text: 'Lv. $lvl', icon: LucideIcons.sun, genderIcon: genderIcon);
    }
    if (lower.contains('rain')) {
      return ParsedEvoCondition(text: 'Lv. $lvl (Rain)', icon: LucideIcons.cloudRain, genderIcon: genderIcon);
    }
    if (lower.contains('hisui')) {
      return ParsedEvoCondition(text: 'Lv. $lvl in Hisui', icon: LucideIcons.mapPin, genderIcon: genderIcon);
    }
    if (lower.contains('galar')) {
      return ParsedEvoCondition(text: 'Lv. $lvl in Galar', icon: LucideIcons.mapPin, genderIcon: genderIcon);
    }
    if (lower.contains('alola')) {
      return ParsedEvoCondition(text: 'Lv. $lvl in Alola', icon: LucideIcons.mapPin, genderIcon: genderIcon);
    }
    return ParsedEvoCondition(text: 'Lv. $lvl', icon: LucideIcons.chevronsUp, genderIcon: genderIcon);
  }

  // Trade
  if (lower.contains('trade')) {
    if (lower.contains('metal coat')) {
      return const ParsedEvoCondition(
        text: 'Trade + Metal Coat',
        icon: LucideIcons.arrowLeftRight,
        itemImageUrl: '$_itemSpriteBase/metal-coat.png',
      );
    }
    if (lower.contains('kings rock') || lower.contains("king's rock")) {
      return const ParsedEvoCondition(
        text: "Trade + King's Rock",
        icon: LucideIcons.arrowLeftRight,
        itemImageUrl: '$_itemSpriteBase/kings-rock.png',
      );
    }
    return const ParsedEvoCondition(text: 'Trade', icon: LucideIcons.arrowLeftRight);
  }

  // Stones / Items
  if (lower.contains('stone') ||
      lower.contains('apple') ||
      lower.contains('rock') ||
      lower.contains('block') ||
      lower.contains('cuff') ||
      lower.contains('wreath') ||
      lower.contains('teacup') ||
      lower.contains('pot') ||
      lower.contains('armor') ||
      lower.contains('alloy') ||
      lower.contains('claw') ||
      lower.contains('fang') ||
      lower.contains('augurite')) {
    if (lower.contains('thunder stone')) {
      return const ParsedEvoCondition(
        text: 'Thunder Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/thunder-stone.png',
      );
    }
    if (lower.contains('water stone')) {
      return const ParsedEvoCondition(
        text: 'Water Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/water-stone.png',
      );
    }
    if (lower.contains('fire stone')) {
      return const ParsedEvoCondition(
        text: 'Fire Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/fire-stone.png',
      );
    }
    if (lower.contains('moon stone')) {
      return const ParsedEvoCondition(
        text: 'Moon Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/moon-stone.png',
      );
    }
    if (lower.contains('sun stone')) {
      if (lower.contains('hisui')) {
        return const ParsedEvoCondition(
          text: 'Sun Stone (Hisui)',
          icon: LucideIcons.gem,
          itemImageUrl: '$_itemSpriteBase/sun-stone.png',
        );
      }
      return const ParsedEvoCondition(
        text: 'Sun Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/sun-stone.png',
      );
    }
    if (lower.contains('shiny stone')) {
      return const ParsedEvoCondition(
        text: 'Shiny Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/shiny-stone.png',
      );
    }
    if (lower.contains('dusk stone')) {
      return const ParsedEvoCondition(
        text: 'Dusk Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/dusk-stone.png',
      );
    }
    if (lower.contains('dawn stone')) {
      if (lower.contains('female')) {
        return const ParsedEvoCondition(
          text: 'Dawn Stone',
          icon: LucideIcons.gem,
          itemImageUrl: '$_itemSpriteBase/dawn-stone.png',
          genderIcon: Icons.female,
        );
      }
      return const ParsedEvoCondition(
        text: 'Dawn Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/dawn-stone.png',
        genderIcon: Icons.male,
      );
    }
    if (lower.contains('ice stone')) {
      return const ParsedEvoCondition(
        text: 'Ice Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/ice-stone.png',
      );
    }
    if (lower.contains('leaf stone')) {
      if (lower.contains('alola')) {
        return const ParsedEvoCondition(
          text: 'Leaf Stone (Alola)',
          icon: LucideIcons.gem,
          itemImageUrl: '$_itemSpriteBase/leaf-stone.png',
        );
      }
      if (lower.contains('hisui')) {
        return const ParsedEvoCondition(
          text: 'Leaf Stone (Hisui)',
          icon: LucideIcons.gem,
          itemImageUrl: '$_itemSpriteBase/leaf-stone.png',
        );
      }
      return const ParsedEvoCondition(
        text: 'Leaf Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/leaf-stone.png',
      );
    }
    if (lower.contains('moss') || lower.contains('mossy')) {
      return const ParsedEvoCondition(
        text: 'Leaf Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/leaf-stone.png',
      );
    }
    if (lower.contains('ice rock') || lower.contains('icy rock')) {
      return const ParsedEvoCondition(
        text: 'Ice Stone',
        icon: LucideIcons.gem,
        itemImageUrl: '$_itemSpriteBase/ice-stone.png',
      );
    }
    if (lower.contains('oval stone')) {
      return const ParsedEvoCondition(
        text: 'Oval Stone',
        icon: LucideIcons.sun,
        itemImageUrl: '$_itemSpriteBase/oval-stone.png',
      );
    }
    if (lower.contains('auspicious armor')) {
      return const ParsedEvoCondition(text: 'Auspicious Armor', icon: LucideIcons.shield);
    }
    if (lower.contains('malicious armor')) {
      return const ParsedEvoCondition(text: 'Malicious Armor', icon: LucideIcons.shield);
    }
    if (lower.contains('metal alloy')) {
      return const ParsedEvoCondition(text: 'Metal Alloy', icon: LucideIcons.gem);
    }
    if (lower.contains('cracked pot') || lower.contains('pot')) {
      return const ParsedEvoCondition(text: 'Cracked Pot', icon: LucideIcons.gem);
    }
    if (lower.contains('tart apple')) {
      return const ParsedEvoCondition(text: 'Tart Apple', icon: LucideIcons.gem);
    }
    if (lower.contains('sweet apple')) {
      return const ParsedEvoCondition(text: 'Sweet Apple', icon: LucideIcons.gem);
    }
    if (lower.contains('syrupy apple')) {
      return const ParsedEvoCondition(text: 'Syrupy Apple', icon: LucideIcons.gem);
    }
    if (lower.contains('teacup')) {
      return const ParsedEvoCondition(text: 'Teacup', icon: LucideIcons.gem);
    }
    if (lower.contains('galarica cuff')) {
      return const ParsedEvoCondition(text: 'Galarica Cuff', icon: LucideIcons.gem);
    }
    if (lower.contains('galarica wreath')) {
      return const ParsedEvoCondition(text: 'Galarica Wreath', icon: LucideIcons.gem);
    }
    if (lower.contains('black augurite')) {
      return const ParsedEvoCondition(text: 'Black Augurite', icon: LucideIcons.gem);
    }
    if (lower.contains('peat block')) {
      return const ParsedEvoCondition(text: 'Peat Block', icon: LucideIcons.moon);
    }
    if (lower.contains('razor claw')) {
      if (lower.contains('day')) {
        return const ParsedEvoCondition(
          text: 'Razor Claw',
          icon: LucideIcons.sun,
          itemImageUrl: '$_itemSpriteBase/razor-claw.png',
        );
      }
      return const ParsedEvoCondition(
        text: 'Razor Claw',
        icon: LucideIcons.moon,
        itemImageUrl: '$_itemSpriteBase/razor-claw.png',
      );
    }
    if (lower.contains('razor fang')) {
      return const ParsedEvoCondition(
        text: 'Razor Fang',
        icon: LucideIcons.moon,
        itemImageUrl: '$_itemSpriteBase/razor-fang.png',
      );
    }
    return const ParsedEvoCondition(text: 'Evolution Item', icon: LucideIcons.gem);
  }

  // Friendship / Happiness / Affection
  if (lower.contains('happiness') || lower.contains('friendship') || lower.contains('affection')) {
    if (lower.contains('night')) {
      return const ParsedEvoCondition(text: 'Friendship', icon: LucideIcons.moon);
    }
    if (lower.contains('day')) {
      return const ParsedEvoCondition(text: 'Friendship', icon: LucideIcons.sun);
    }
    if (lower.contains('fairy')) {
      return const ParsedEvoCondition(
        text: 'Affection +\nFairy Move',
        icon: LucideIcons.heart,
      );
    }
    return const ParsedEvoCondition(text: 'Friendship', icon: LucideIcons.heart);
  }

  // Moves
  if (lower.contains('dragon cheer')) {
    return const ParsedEvoCondition(text: 'Dragon Cheer Move', icon: LucideIcons.swords);
  }
  if (lower.contains('mimic')) {
    return const ParsedEvoCondition(text: 'Mimic Move', icon: LucideIcons.swords);
  }
  if (lower.contains('psyshield bash')) {
    return const ParsedEvoCondition(text: 'Psyshield Bash 20x', icon: LucideIcons.swords);
  }
  if (lower.contains('barb barrage')) {
    return const ParsedEvoCondition(text: 'Barb Barrage 20x', icon: LucideIcons.swords);
  }

  // Special conditions
  if (lower.contains('critical hits')) {
    return const ParsedEvoCondition(text: '3 Critical Hits in Battle', icon: LucideIcons.swords);
  }
  if (lower.contains('damage') || lower.contains('recoil')) {
    return const ParsedEvoCondition(text: 'Special Battle Condition', icon: LucideIcons.sparkles);
  }

  final clean = raw.replaceAll('\n', ' • ').trim();
  final isFemale = lower.contains('female');
  final isMale = lower.contains('male') && !isFemale;
  final genderIcon = isFemale ? Icons.female : (isMale ? Icons.male : null);
  final display = clean.length > 22 ? '${clean.substring(0, 20)}...' : clean;
  return ParsedEvoCondition(text: display, icon: LucideIcons.sparkles, genderIcon: genderIcon);
}

// =============================================================================
// ADAPTIVE GRAPH ANALYZER
// =============================================================================

enum EvolutionLayoutStrategy {
  linear,
  directMultiBranch,
  multiStageBranch,
  intermediateBranch,
  single,
  complexTree,
}

class EvolutionGraphAnalyzer {
  static EvolutionLayoutStrategy determineStrategy(EvoNode root) {
    if (root.evolvesTo.isEmpty) {
      return EvolutionLayoutStrategy.single;
    }

    final allNodes = <EvoNode>[];
    final queue = <EvoNode>[root];
    int maxChildren = 0;
    bool hasIntermediateBranch = false;
    bool hasMultiStageBranch = false;

    while (queue.isNotEmpty) {
      final node = queue.removeAt(0);
      allNodes.add(node);
      if (node.evolvesTo.length > maxChildren) {
        maxChildren = node.evolvesTo.length;
      }
      if (node != root && node.evolvesTo.length > 1) {
        hasIntermediateBranch = true;
      }
      for (final child in node.evolvesTo) {
        queue.add(child);
      }
    }

    if (root.evolvesTo.length > 1) {
      final childrenWithChildren = root.evolvesTo.where((c) => c.evolvesTo.isNotEmpty).toList();
      if (childrenWithChildren.length >= 2) {
        hasMultiStageBranch = true;
      }
    }

    final allRootChildrenAreLeaves = root.evolvesTo.every((c) => c.evolvesTo.isEmpty);
    if (root.evolvesTo.length >= 3 && allRootChildrenAreLeaves) {
      return EvolutionLayoutStrategy.directMultiBranch;
    }

    if (hasMultiStageBranch) {
      return EvolutionLayoutStrategy.multiStageBranch;
    }

    if (hasIntermediateBranch || (root.evolvesTo.length > 1 && !allRootChildrenAreLeaves)) {
      return EvolutionLayoutStrategy.intermediateBranch;
    }

    if (root.evolvesTo.length == 2 && allRootChildrenAreLeaves) {
      return EvolutionLayoutStrategy.intermediateBranch;
    }

    if (maxChildren <= 1) {
      return EvolutionLayoutStrategy.linear;
    }

    return EvolutionLayoutStrategy.complexTree;
  }

  static List<int> findPathToRoot(EvoNode root, int targetId) {
    final path = <int>[];

    bool search(EvoNode current) {
      path.add(current.pokemonId);
      if (current.pokemonId == targetId) return true;
      for (final child in current.evolvesTo) {
        if (search(child)) return true;
      }
      path.removeLast();
      return false;
    }

    if (search(root)) {
      return path;
    }
    return [root.pokemonId];
  }
}

// =============================================================================
// REUSABLE POKEMON NODE COMPONENT
// =============================================================================

class EvolutionPokemonNode extends StatelessWidget {
  final EvoNode node;
  final bool isSelected;
  final bool isCurrent;
  final bool isPathActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double? height;
  final bool compact;
  final String? conditionText;
  final IconData? conditionIcon;
  final String? conditionItemImageUrl;
  final IconData? conditionGenderIcon;
  final bool isCenter;

  const EvolutionPokemonNode({
    super.key,
    required this.node,
    required this.isSelected,
    required this.isCurrent,
    required this.isPathActive,
    required this.onTap,
    this.onLongPress,
    this.width = 88.0,
    this.height,
    this.compact = false,
    this.conditionText,
    this.conditionIcon,
    this.conditionItemImageUrl,
    this.conditionGenderIcon,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final pokemon = node.pokemon;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageSize = compact ? (width * 0.48).clamp(34.0, 48.0) : (width * 0.60).clamp(46.0, 68.0);
    final name = pokemon != null ? PokemonHelpers.formatName(pokemon.name) : '...';
    final speciesStr = pokemon != null ? '#${pokemon.speciesId.toString().padLeft(3, '0')}' : '#---';

    final aestheticColor = (pokemon != null && pokemon.types.isNotEmpty)
        ? AppColors.getTypeColor(pokemon.types.first.type.name)
        : const Color(0xFF1E88E5);

    final baseCardColor = isDark ? const Color(0xFF1E212D) : Colors.white;
    final cardBg = isSelected
        ? Color.alphaBlend(
            aestheticColor.withValues(alpha: isDark ? 0.16 : 0.08),
            baseCardColor,
          )
        : (isPathActive
            ? Color.alphaBlend(
                aestheticColor.withValues(alpha: isDark ? 0.08 : 0.04),
                baseCardColor,
              )
            : baseCardColor);

    final borderColor = isSelected
        ? aestheticColor
        : (isPathActive
            ? aestheticColor.withValues(alpha: isDark ? 0.65 : 0.45)
            : (isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08)));

    final borderWidth = isSelected ? 2.0 : (isPathActive ? 1.5 : 1.0);

    return Semantics(
      button: true,
      label: '$name $speciesStr',
      child: GestureDetector(
        onTap: () {
          AppFeedback.selectionClick();
          onTap();
        },
        onLongPress: onLongPress != null
            ? () {
                AppFeedback.heavyImpact();
                onLongPress!();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: width,
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 5 : 8,
            vertical: compact ? 7 : 10,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                            // Optional Condition Pill (e.g. for grid views)
              if (conditionText != null && conditionText!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282C3D) : const Color(0xFFF0F2F8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (conditionItemImageUrl != null) ...[
                        Image.network(
                          conditionItemImageUrl!,
                          width: 10,
                          height: 10,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => (conditionIcon != null)
                              ? Icon(conditionIcon, size: 7.5, color: aestheticColor)
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 2.5),
                      ] else if (conditionIcon != null) ...[
                        Icon(conditionIcon, size: 7.5, color: aestheticColor),
                        const SizedBox(width: 2.0),
                      ],
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            conditionText!,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                              fontSize: compact ? 6.5 : 7.2,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      if (conditionGenderIcon != null) ...[
                        const SizedBox(width: 2.0),
                        Icon(
                          conditionGenderIcon,
                          size: 9.0,
                          color: conditionGenderIcon == Icons.female
                              ? const Color(0xFFEC407A)
                              : const Color(0xFF1E88E5),
                        ),
                      ],
                    ],
                  ),
                )
              else if (isCenter)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: aestheticColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: aestheticColor.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'BASE',
                      style: TextStyle(
                        color: aestheticColor,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              // Pokemon Home 3D Artwork
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: Center(
                  child: Image.asset(
                    PokemonHelpers.getHomeAssetPath(node.pokemonId),
                    fit: BoxFit.contain,
                    cacheWidth: PokemonHelpers.cacheWidth(context, imageSize),
                    errorBuilder: (_, _, _) => Image.asset(
                      PokemonHelpers.getThumbnailAssetPath(node.pokemonId),
                      fit: BoxFit.contain,
                      cacheWidth: PokemonHelpers.cacheWidth(context, imageSize),
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.catching_pokemon,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // Pokedex number
              Text(
                speciesStr,
                style: TextStyle(
                  fontSize: compact ? 9.5 : 10.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 2),

              // Pokemon name
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isSelected
                      ? aestheticColor
                      : (isDark ? Colors.white : const Color(0xFF1B1D28)),
                ),
              ),

              if (pokemon != null && pokemon.types.isNotEmpty) ...[
                const SizedBox(height: 5),
                // Types row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pokemon.types.take(2).map((t) {
                      final typeName = t.type.name;
                      final typeColor = AppColors.getTypeColor(typeName);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.45),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/types/$typeName.svg',
                              width: 9,
                              height: 9,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              typeName[0].toUpperCase() + typeName.substring(1),
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w800,
                                fontSize: compact ? 7.5 : 8.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REUSABLE EVOLUTION CONNECTORS
// =============================================================================

class HorizontalEvolutionConnector extends StatelessWidget {
  final String condition;
  final bool isActive;
  final double? width;
  final Color? activeColor;

  const HorizontalEvolutionConnector({
    super.key,
    required this.condition,
    this.isActive = false,
    this.width,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsed = parseEvoCondition(condition);
    final effectiveActiveColor = activeColor ?? const Color(0xFF1E88E5);

    final lineColor = isActive
        ? effectiveActiveColor
        : (isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.15));

    final effectiveWidth = width ?? 82.0;

    return Container(
      width: effectiveWidth,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Condition pill
          if (condition.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222634) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? effectiveActiveColor.withValues(alpha: 0.6)
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (parsed.itemImageUrl != null) ...[
                    Image.network(
                      parsed.itemImageUrl!,
                      width: 10,
                      height: 10,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        parsed.icon,
                        size: 8.5,
                        color: isActive ? effectiveActiveColor : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 3),
                  ] else ...[
                    Icon(
                      parsed.icon,
                      size: 8.5,
                      color: isActive ? effectiveActiveColor : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 3),
                  ],
                  Flexible(
                    child: Text(
                      parsed.text,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? effectiveActiveColor
                            : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      ),
                    ),
                  ),
                  if (parsed.genderIcon != null) ...[
                    const SizedBox(width: 2.5),
                    Icon(
                      parsed.genderIcon,
                      size: 9.5,
                      color: parsed.genderIcon == Icons.female
                          ? const Color(0xFFEC407A)
                          : const Color(0xFF1E88E5),
                    ),
                  ],
                ],
              ),
            ),

          // Horizontal arrow line
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_right_rounded,
                color: lineColor,
                size: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VerticalEvolutionConnector extends StatelessWidget {
  final String condition;
  final bool isActive;
  final double? height;
  final Color? activeColor;

  const VerticalEvolutionConnector({
    super.key,
    required this.condition,
    this.isActive = false,
    this.height,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsed = parseEvoCondition(condition);
    final hasCondition = condition.trim().isNotEmpty;
    final effectiveActiveColor = activeColor ?? const Color(0xFF1E88E5);

    final lineColor = isActive
        ? effectiveActiveColor
        : (isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.15));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 2,
            height: hasCondition ? 14 : 20,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          if (hasCondition) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222634) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? effectiveActiveColor.withValues(alpha: 0.6)
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (parsed.itemImageUrl != null) ...[
                    Image.network(
                      parsed.itemImageUrl!,
                      width: 11,
                      height: 11,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        parsed.icon,
                        size: 9.5,
                        color: isActive ? effectiveActiveColor : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else ...[
                    Icon(
                      parsed.icon,
                      size: 9.5,
                      color: isActive ? effectiveActiveColor : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    parsed.text,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? effectiveActiveColor
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                    ),
                  ),
                  if (parsed.genderIcon != null) ...[
                    const SizedBox(width: 3),
                    Icon(
                      parsed.genderIcon,
                      size: 10.5,
                      color: parsed.genderIcon == Icons.female
                          ? const Color(0xFFEC407A)
                          : const Color(0xFF1E88E5),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 2,
              height: 14,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: lineColor,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class BranchingForkPainter extends CustomPainter {
  final int childCount;
  final int activeIndex;
  final Color inactiveColor;
  final Color activeColor;

  BranchingForkPainter({
    required this.childCount,
    required this.activeIndex,
    required this.inactiveColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (childCount <= 0) return;

    final paintInactive = Paint()
      ..color = inactiveColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintActive = Paint()
      ..color = activeColor
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowPaintInactive = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill;

    final arrowPaintActive = Paint()
      ..color = activeColor
      ..style = PaintingStyle.fill;

    final double midY = size.height * 0.45;
    final double centerX = size.width / 2.0;

    // Stem from top center down to midY
    final stemIsActive = activeIndex >= 0;
    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, midY),
      stemIsActive ? paintActive : paintInactive,
    );

    // Compute center X of each child column
    final colWidth = size.width / childCount;
    final childCenters = List.generate(childCount, (i) => (i + 0.5) * colWidth);

    // Horizontal rail from first child center to last child center
    final startX = childCenters.first;
    final endX = childCenters.last;
    canvas.drawLine(
      Offset(startX, midY),
      Offset(endX, midY),
      paintInactive,
    );

    // If active branch, highlight the rail segment connecting center to active child
    if (activeIndex >= 0 && activeIndex < childCount) {
      final activeX = childCenters[activeIndex];
      canvas.drawLine(
        Offset(centerX, midY),
        Offset(activeX, midY),
        paintActive,
      );
    }

    // Drop lines down to each child
    for (int i = 0; i < childCount; i++) {
      final x = childCenters[i];
      final isChildActive = i == activeIndex;
      final lineP = isChildActive ? paintActive : paintInactive;
      final arrowP = isChildActive ? arrowPaintActive : arrowPaintInactive;

      // Vertical line
      canvas.drawLine(
        Offset(x, midY),
        Offset(x, size.height - 4),
        lineP,
      );

      // Downward arrow head
      final arrowPath = Path()
        ..moveTo(x - 4, size.height - 6)
        ..lineTo(x + 4, size.height - 6)
        ..lineTo(x, size.height)
        ..close();
      canvas.drawPath(arrowPath, arrowP);
    }
  }

  @override
  bool shouldRepaint(covariant BranchingForkPainter oldDelegate) {
    return oldDelegate.childCount != childCount ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.activeColor != activeColor;
  }
}

// =============================================================================
// RADIAL CONSTELLATION PAINTER & REUSABLE RADIAL LAYOUT
// =============================================================================

class RadialConstellationPainter extends CustomPainter {
  final Offset center;
  final List<Offset> nodePositions;
  final int activeIndex;
  final bool isDark;
  final Color primaryColor;
  final double centerRadius;
  final double outerRadius;

  RadialConstellationPainter({
    required this.center,
    required this.nodePositions,
    required this.activeIndex,
    required this.isDark,
    required this.primaryColor,
    this.centerRadius = 42.0,
    this.outerRadius = 36.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.isEmpty) return;

    final inactiveLinePaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.16) : Colors.black.withValues(alpha: 0.12)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeLinePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activeGlowPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.35 : 0.22)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    final orbitPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final starPointInactive = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.32) : Colors.black.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final starPointActive = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    // 1. Draw celestial constellation orbit linking outer star nodes if N >= 3
    if (nodePositions.length >= 3) {
      final path = Path();
      path.moveTo(nodePositions.first.dx, nodePositions.first.dy);
      for (int i = 1; i < nodePositions.length; i++) {
        path.lineTo(nodePositions[i].dx, nodePositions[i].dy);
      }
      path.close();
      canvas.drawPath(path, orbitPaint);
    }

    // 2. Radial connectors from center to each outer node (center circle removed per user request)
    for (int i = 0; i < nodePositions.length; i++) {
      final target = nodePositions[i];
      final isActive = i == activeIndex;
      final dir = target - center;
      final distance = dir.distance;
      if (distance <= 0) continue;
      final unit = Offset(dir.dx / distance, dir.dy / distance);

      final start = center + unit * centerRadius;
      final end = target - unit * outerRadius;

      if ((end - start).distance > 4) {
        if (isActive) {
          canvas.drawLine(start, end, activeGlowPaint);
          canvas.drawLine(start, end, activeLinePaint);
        } else {
          canvas.drawLine(start, end, inactiveLinePaint);
        }

        // Draw directional chevron marker pointing toward outer evolution
        final markerPos = start + (end - start) * 0.62;
        final perp = Offset(-unit.dy, unit.dx);
        final markerPaint = isActive ? starPointActive : starPointInactive;

        final markerPath = Path()
          ..moveTo(markerPos.dx + unit.dx * 5, markerPos.dy + unit.dy * 5)
          ..lineTo(markerPos.dx - unit.dx * 3 + perp.dx * 3.5, markerPos.dy - unit.dy * 3 + perp.dy * 3.5)
          ..lineTo(markerPos.dx - unit.dx * 1, markerPos.dy - unit.dy * 1)
          ..lineTo(markerPos.dx - unit.dx * 3 - perp.dx * 3.5, markerPos.dy - unit.dy * 3 - perp.dy * 3.5)
          ..close();

        canvas.drawPath(markerPath, markerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadialConstellationPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.activeIndex != activeIndex ||
        oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.nodePositions.length != nodePositions.length;
  }
}

class RadialEvolutionLayout extends StatelessWidget {
  final EvoNode root;
  final int? selectedPokemonId;
  final int? currentPokemonId;
  final List<int> activePath;
  final ValueChanged<int> onSelect;
  final void Function(int pokemonId, String? name)? onLongPress;
  final double availableWidth;
  final Color? themeColor;

  const RadialEvolutionLayout({
    super.key,
    required this.root,
    required this.selectedPokemonId,
    required this.currentPokemonId,
    required this.activePath,
    required this.onSelect,
    this.onLongPress,
    required this.availableWidth,
    this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final children = root.evolvesTo;
    final int n = children.length;

    // Node sizing based on branch density and available screen width
    final double centerWidth = availableWidth < 360 ? 80.0 : 84.0;

    final double nodeWidth;
    final bool compact;

    if (n >= 7) {
      // e.g. Eevee (8 evolutions)
      nodeWidth = availableWidth < 360 ? 68.0 : 70.0;
      compact = true;
    } else if (n >= 5) {
      nodeWidth = 74.0;
      compact = true;
    } else if (n >= 3) {
      // e.g. Tyrogue (3 branches)
      nodeWidth = 80.0;
      compact = true;
    } else {
      nodeWidth = 86.0;
      compact = false;
    }

    final double cx = availableWidth / 2.0;
    final nodeCenters = <Offset>[];
    final double totalHeight;
    final double cy;

    if (n == 8) {
      // EEVEE 8-EVOLUTION CONSTELLATION:
      // Mathematically positioned so NO two cards overlap in any direction!
      // Center and outer nodes are centered with FractionalTranslation, ensuring
      // exact, perfectly symmetrical distances: distance(Eevee, Vaporeon) == distance(Eevee, Umbreon)
      final double rx = ((availableWidth - nodeWidth - 10.0) / 2.0).clamp(118.0, 150.0);
      const double ySide = 138.0;
      const double ry = 205.0;
      const double cardHalfHeight = 65.0;
      cy = ry + cardHalfHeight + 12.0;
      totalHeight = 2 * ry + 2 * cardHalfHeight + 24.0;

      nodeCenters.addAll([
        Offset(cx, cy - ry),             // 0: Top (Vaporeon)
        Offset(cx + rx, cy - ySide),     // 1: Upper Right (Jolteon)
        Offset(cx + rx, cy),             // 2: Mid Right (Flareon)
        Offset(cx + rx, cy + ySide),     // 3: Lower Right (Espeon)
        Offset(cx, cy + ry),             // 4: Bottom (Umbreon)
        Offset(cx - rx, cy + ySide),     // 5: Lower Left (Leafeon)
        Offset(cx - rx, cy),             // 6: Mid Left (Glaceon)
        Offset(cx - rx, cy - ySide),     // 7: Upper Left (Sylveon)
      ]);
    } else if (n == 3) {
      // TYROGUE (3 branches):
      // Equilateral trifecta constellation
      final double rx = ((availableWidth - nodeWidth - 20.0) / 2.0).clamp(100.0, 138.0);
      const double ry = 135.0;
      const double cardHalfHeight = 65.0;
      cy = ry + cardHalfHeight + 12.0;
      totalHeight = 2 * ry + 2 * cardHalfHeight + 24.0;

      nodeCenters.addAll([
        Offset(cx, cy - ry),                        // Top
        Offset(cx + rx, cy + ry * 0.72),            // Lower Right
        Offset(cx - rx, cy + ry * 0.72),            // Lower Left
      ]);
    } else if (n == 2) {
      // 2 branches: opposite sides
      final double rx = ((availableWidth - 2 * nodeWidth - 20.0) / 2.0).clamp(85.0, 120.0);
      const double cardHalfHeight = 65.0;
      cy = cardHalfHeight + 16.0;
      totalHeight = 2 * cardHalfHeight + 32.0;

      nodeCenters.addAll([
        Offset(cx - rx, cy),
        Offset(cx + rx, cy),
      ]);
    } else if (n == 4) {
      // 4 branches: diamond cross
      final double rx = ((availableWidth - nodeWidth - 16.0) / 2.0).clamp(104.0, 140.0);
      const double ry = 145.0;
      const double cardHalfHeight = 65.0;
      cy = ry + cardHalfHeight + 12.0;
      totalHeight = 2 * ry + 2 * cardHalfHeight + 24.0;

      nodeCenters.addAll([
        Offset(cx, cy - ry),     // Top
        Offset(cx + rx, cy),     // Right
        Offset(cx, cy + ry),     // Bottom
        Offset(cx - rx, cy),     // Left
      ]);
    } else {
      // General N branches
      final double rx = ((availableWidth - nodeWidth - 16.0) / 2.0).clamp(104.0, 145.0);
      final double ry = (140.0 + (n - 4) * 20.0).clamp(140.0, 240.0);
      const double cardHalfHeight = 65.0;
      cy = ry + cardHalfHeight + 12.0;
      totalHeight = 2 * ry + 2 * cardHalfHeight + 24.0;

      for (int i = 0; i < n; i++) {
        final double theta = -math.pi / 2.0 + i * (2.0 * math.pi / n);
        nodeCenters.add(Offset(cx + rx * math.cos(theta), cy + ry * math.sin(theta)));
      }
    }

    final activeIndex = children.indexWhere((c) => activePath.contains(c.pokemonId));

    return SizedBox(
      width: availableWidth,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Constellation connector paths and celestial orbit
          Positioned.fill(
            child: CustomPaint(
              size: Size(availableWidth, totalHeight),
              painter: RadialConstellationPainter(
                center: Offset(cx, cy),
                nodePositions: nodeCenters,
                activeIndex: activeIndex,
                isDark: isDark,
                primaryColor: () {
                  final activePokemon = (activeIndex >= 0 && activeIndex < children.length)
                      ? children[activeIndex].pokemon
                      : null;
                  if (activePokemon != null && activePokemon.types.isNotEmpty) {
                    return AppColors.getTypeColor(activePokemon.types.first.type.name);
                  }
                  if (root.pokemon != null && root.pokemon!.types.isNotEmpty) {
                    return AppColors.getTypeColor(root.pokemon!.types.first.type.name);
                  }
                  return themeColor ?? const Color(0xFF1E88E5);
                }(),
                centerRadius: centerWidth * 0.48,
                outerRadius: nodeWidth * 0.44,
              ),
            ),
          ),

          // 2. Center Prominent Base Pokémon Node (No circle overlay)
          Positioned(
            left: cx,
            top: cy,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: EvolutionPokemonNode(
                node: root,
                isSelected: root.pokemonId == selectedPokemonId,
                isCurrent: root.pokemonId == currentPokemonId,
                isPathActive: activePath.contains(root.pokemonId),
                width: centerWidth,
                isCenter: true,
                onTap: () => onSelect(root.pokemonId),
                onLongPress: onLongPress != null
                    ? () => onLongPress!(root.pokemonId, root.pokemon?.name)
                    : null,
              ),
            ),
          ),

          // 3. Orbiting Evolution Nodes
          for (int i = 0; i < n; i++) ...[
            Builder(
              builder: (context) {
                final child = children[i];
                final pos = nodeCenters[i];
                final isSelected = child.pokemonId == selectedPokemonId;
                final isCurrent = child.pokemonId == currentPokemonId;
                final isPathActive = activePath.contains(child.pokemonId);
                final parsed = parseEvoCondition(child.condition);

                return Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: EvolutionPokemonNode(
                      node: child,
                      isSelected: isSelected,
                      isCurrent: isCurrent,
                      isPathActive: isPathActive,
                      width: nodeWidth,
                      compact: compact,
                      conditionText: parsed.text,
                      conditionIcon: parsed.icon,
                      conditionItemImageUrl: parsed.itemImageUrl,
                      conditionGenderIcon: parsed.genderIcon,
                      onTap: () => onSelect(child.pokemonId),
                      onLongPress: onLongPress != null
                          ? () => onLongPress!(child.pokemonId, child.pokemon?.name)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// MAIN EVOLUTION TAB WIDGET
// =============================================================================

class EvolutionTab extends ConsumerStatefulWidget {
  final String evolutionInfoJson;
  final int? pokemonId;
  final int? speciesId;
  final Widget? header;
  final Color? themeColor;

  const EvolutionTab({
    super.key,
    required this.evolutionInfoJson,
    this.pokemonId,
    this.speciesId,
    this.header,
    this.themeColor,
  });

  @override
  ConsumerState<EvolutionTab> createState() => _EvolutionTabState();
}

class _EvolutionTabState extends ConsumerState<EvolutionTab> {
  int? _selectedPokemonId;
  bool _showAlternateForm = false;

  @override
  void initState() {
    super.initState();
    _selectedPokemonId = widget.pokemonId ?? widget.speciesId;
  }

  @override
  void didUpdateWidget(covariant EvolutionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pokemonId != oldWidget.pokemonId) {
      setState(() {
        _selectedPokemonId = widget.pokemonId ?? widget.speciesId;
      });
    }
  }

  void _handlePokemonLongPress(BuildContext context, int pokemonId, String? name) {
    AppFeedback.heavyImpact();
    if (pokemonId == widget.pokemonId) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF222634)
                  : const Color(0xFF1E212D))
              .withValues(alpha: 0.95),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.checkCircle2, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Currently viewing ${name != null ? PokemonHelpers.formatName(name) : 'this Pokémon'}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    } else {
      context.push('/pokemon/$pokemonId');
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncChain = ref.watch(
      evolutionChainProvider(
        EvoChainParam(
          json: widget.evolutionInfoJson,
          pokemonId: widget.pokemonId,
          speciesId: widget.speciesId,
        ),
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: asyncChain.when(
            data: (root) {
              if (root == null) {
                return const Center(
                  child: Text(
                    'No evolution chain available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final altFormsCount = _countAltForms(root);
              final activePath = EvolutionGraphAnalyzer.findPathToRoot(
                root,
                _selectedPokemonId ?? root.pokemonId,
              );

              final navBarHeight = kBottomNavigationBarHeight + MediaQuery.paddingOf(context).bottom;

              return Column(
                children: [
                  // Top Mode Switcher & info button
                  if (altFormsCount > 0)
                    _buildTopModeSwitcher(isDark, altFormsCount)
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildInfoButton(isDark),
                      ),
                    ),

                  // Tree or Forms Content
                  Expanded(
                    child: _showAlternateForm
                        ? _buildAlternateFormsView(context, root, navBarHeight)
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final contentWidth = math.max(0.0, constraints.maxWidth - 32.0);
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(16, 8, 16, navBarHeight + 24),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: contentWidth,
                                    minHeight: math.max(0, constraints.maxHeight - 120),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildAdaptiveTree(
                                        context,
                                        root,
                                        BoxConstraints(
                                          maxWidth: contentWidth,
                                          maxHeight: constraints.maxHeight,
                                        ),
                                        activePath,
                                        isDark,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, st) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ADAPTIVE TREE DISPATCHER
  // ---------------------------------------------------------------------------

  Widget _buildAdaptiveTree(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    List<int> activePath,
    bool isDark,
  ) {
    final strategy = EvolutionGraphAnalyzer.determineStrategy(root);

    switch (strategy) {
      case EvolutionLayoutStrategy.linear:
        return _buildLinearLayout(context, root, constraints, activePath, isDark);
      case EvolutionLayoutStrategy.directMultiBranch:
        return _buildDirectMultiBranchLayout(context, root, constraints, activePath, isDark);
      case EvolutionLayoutStrategy.multiStageBranch:
        return _buildMultiStageBranchLayout(context, root, constraints, activePath, isDark);
      case EvolutionLayoutStrategy.intermediateBranch:
        return _buildIntermediateBranchLayout(context, root, constraints, activePath, isDark);
      case EvolutionLayoutStrategy.single:
        return _buildSingleLayout(context, root, constraints, isDark);
      case EvolutionLayoutStrategy.complexTree:
        return _buildIntermediateBranchLayout(context, root, constraints, activePath, isDark);
    }
  }

  // ---------------------------------------------------------------------------
  // LAYOUT A: LINEAR CHAIN (Bulbasaur, Charmander, Poltchageist, Magikarp)
  // ---------------------------------------------------------------------------

  Widget _buildLinearLayout(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    List<int> activePath,
    bool isDark,
  ) {
    final stages = <EvoNode>[root];
    var curr = root;
    while (curr.evolvesTo.isNotEmpty) {
      curr = curr.evolvesTo.first;
      stages.add(curr);
    }

    final stageCount = stages.length;
    final colChildren = <Widget>[];

    for (int i = 0; i < stageCount; i++) {
      final node = stages[i];
      final isSelected = node.pokemonId == _selectedPokemonId;
      final isCurrent = node.pokemonId == widget.pokemonId;
      final isPathActive = activePath.contains(node.pokemonId);

      colChildren.add(
        EvolutionPokemonNode(
          node: node,
          isSelected: isSelected,
          isCurrent: isCurrent,
          isPathActive: isPathActive,
          width: 96.0,
          onTap: () => setState(() => _selectedPokemonId = node.pokemonId),
          onLongPress: () => _handlePokemonLongPress(context, node.pokemonId, node.pokemon?.name),
        ),
      );

      if (i < stageCount - 1) {
        final nextNode = stages[i + 1];
        final connectorActive = activePath.contains(node.pokemonId) && activePath.contains(nextNode.pokemonId);
        final nextColor = (nextNode.pokemon != null && nextNode.pokemon!.types.isNotEmpty)
            ? AppColors.getTypeColor(nextNode.pokemon!.types.first.type.name)
            : (node.pokemon != null && node.pokemon!.types.isNotEmpty
                ? AppColors.getTypeColor(node.pokemon!.types.first.type.name)
                : (widget.themeColor ?? const Color(0xFF1E88E5)));
        colChildren.add(
          VerticalEvolutionConnector(
            condition: nextNode.condition,
            isActive: connectorActive,
            height: 38.0,
            activeColor: nextColor,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: colChildren,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LAYOUT B: RADIAL CONSTELLATION (Eevee 8-orbit, Tyrogue 3-star, Direct Branches)
  // ---------------------------------------------------------------------------

  Widget _buildDirectMultiBranchLayout(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    List<int> activePath,
    bool isDark,
  ) {
    return _buildRadialConstellationLayout(context, root, constraints, activePath, isDark);
  }

  Widget _buildRadialConstellationLayout(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    List<int> activePath,
    bool isDark,
  ) {
    return RadialEvolutionLayout(
      root: root,
      selectedPokemonId: _selectedPokemonId,
      currentPokemonId: widget.pokemonId,
      activePath: activePath,
      availableWidth: constraints.maxWidth,
      themeColor: widget.themeColor,
      onSelect: (id) => setState(() => _selectedPokemonId = id),
      onLongPress: (id, name) => _handlePokemonLongPress(context, id, name),
    );
  }

  // ---------------------------------------------------------------------------
  // LAYOUT C: MULTI-STAGE BRANCHING (Wurmple -> Silcoon/Cascoon -> Beautifly/Dustox)
  // ---------------------------------------------------------------------------

  Widget _buildMultiStageBranchLayout(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    List<int> activePath,
    bool isDark,
  ) {
    final branches = root.evolvesTo;
    final activeIndex = branches.indexWhere((c) => activePath.contains(c.pokemonId));
    final availableWidth = constraints.maxWidth;
    final colWidth = ((availableWidth - 24) / 2).clamp(130.0, 160.0);
    final forkWidth = colWidth * 2;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Wurmple at top center
        EvolutionPokemonNode(
          node: root,
          isSelected: root.pokemonId == _selectedPokemonId,
          isCurrent: root.pokemonId == widget.pokemonId,
          isPathActive: activePath.contains(root.pokemonId),
          width: 88.0,
          onTap: () => setState(() => _selectedPokemonId = root.pokemonId),
          onLongPress: () => _handlePokemonLongPress(context, root.pokemonId, root.pokemon?.name),
        ),

        // Fork Header splitting into 2 columns
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SizedBox(
            width: forkWidth,
            height: 24,
            child: CustomPaint(
              painter: BranchingForkPainter(
                childCount: 2,
                activeIndex: activeIndex,
                inactiveColor: isDark ? Colors.white24 : Colors.black12,
                activeColor: (activeIndex >= 0 && activeIndex < branches.length && branches[activeIndex].pokemon != null && branches[activeIndex].pokemon!.types.isNotEmpty)
                    ? AppColors.getTypeColor(branches[activeIndex].pokemon!.types.first.type.name)
                    : (widget.themeColor ?? (root.pokemon != null && root.pokemon!.types.isNotEmpty
                        ? AppColors.getTypeColor(root.pokemon!.types.first.type.name)
                        : const Color(0xFF1E88E5))),
              ),
            ),
          ),
        ),

        // Two balanced columns (Silcoon -> Beautifly & Cascoon -> Dustox)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: branches.map((branch) {
            final isSelected = branch.pokemonId == _selectedPokemonId;
            final isCurrent = branch.pokemonId == widget.pokemonId;
            final isPathActive = activePath.contains(branch.pokemonId);
            final parsed = parseEvoCondition(branch.condition);
            final branchAestheticColor = (branch.pokemon != null && branch.pokemon!.types.isNotEmpty)
                ? AppColors.getTypeColor(branch.pokemon!.types.first.type.name)
                : (widget.themeColor ?? const Color(0xFF1E88E5));

            return Container(
              width: colWidth,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Condition pill for branch
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222634) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPathActive
                            ? branchAestheticColor.withValues(alpha: 0.6)
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (parsed.itemImageUrl != null) ...[
                          Image.network(
                            parsed.itemImageUrl!,
                            width: 9,
                            height: 9,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              parsed.icon,
                              size: 8.5,
                              color: isPathActive ? branchAestheticColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 3),
                        ] else ...[
                          Icon(parsed.icon, size: 8.5, color: isPathActive ? branchAestheticColor : Colors.grey),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          parsed.text,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: isPathActive
                                ? branchAestheticColor
                                : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                          ),
                        ),
                        if (parsed.genderIcon != null) ...[
                          const SizedBox(width: 2.5),
                          Icon(
                            parsed.genderIcon,
                            size: 9.0,
                            color: parsed.genderIcon == Icons.female
                                ? const Color(0xFFEC407A)
                                : const Color(0xFF1E88E5),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Stage 2 Node (Silcoon / Cascoon)
                  EvolutionPokemonNode(
                    node: branch,
                    isSelected: isSelected,
                    isCurrent: isCurrent,
                    isPathActive: isPathActive,
                    width: 86.0,
                    onTap: () => setState(() => _selectedPokemonId = branch.pokemonId),
                    onLongPress: () => _handlePokemonLongPress(context, branch.pokemonId, branch.pokemon?.name),
                  ),

                  // Downstream stage (Beautifly / Dustox)
                  if (branch.evolvesTo.isNotEmpty) ...[
                    ...branch.evolvesTo.map((leaf) {
                      final leafSelected = leaf.pokemonId == _selectedPokemonId;
                      final leafCurrent = leaf.pokemonId == widget.pokemonId;
                      final leafPathActive = activePath.contains(leaf.pokemonId);
                      final leafConnActive = isPathActive && leafPathActive;
                      final leafAestheticColor = (leaf.pokemon != null && leaf.pokemon!.types.isNotEmpty)
                          ? AppColors.getTypeColor(leaf.pokemon!.types.first.type.name)
                          : branchAestheticColor;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VerticalEvolutionConnector(
                            condition: leaf.condition,
                            isActive: leafConnActive,
                            activeColor: leafAestheticColor,
                          ),
                          EvolutionPokemonNode(
                            node: leaf,
                            isSelected: leafSelected,
                            isCurrent: leafCurrent,
                            isPathActive: leafPathActive,
                            width: 86.0,
                            onTap: () => setState(() => _selectedPokemonId = leaf.pokemonId),
                            onLongPress: () => _handlePokemonLongPress(context, leaf.pokemonId, leaf.pokemon?.name),
                          ),
                        ],
                      );
                    }),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LAYOUT D: INTERMEDIATE BRANCH (Ralts, Oddish, Slowpoke, Applin)
  // ---------------------------------------------------------------------------

  Widget _buildIntermediateBranchLayout(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    List<int> activePath,
    bool isDark,
  ) {
    // Find linear chain down to the branching node
    final linearStages = <EvoNode>[root];
    var branchNode = root;

    while (branchNode.evolvesTo.length == 1) {
      branchNode = branchNode.evolvesTo.first;
      linearStages.add(branchNode);
    }

    final children = branchNode.evolvesTo;
    final branchCount = children.length;
    final availableWidth = constraints.maxWidth;
    final activeIndex = children.indexWhere((c) => activePath.contains(c.pokemonId));

    final branchWidth = ((availableWidth - ((branchCount - 1) * 10.0) - 24) / math.max(1, branchCount))
        .clamp(78.0, 96.0);
    final forkWidth = branchWidth * branchCount + (branchCount - 1) * 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Upstream linear stages (e.g. Ralts -> Kirlia)
        for (int i = 0; i < linearStages.length; i++) ...[
          EvolutionPokemonNode(
            node: linearStages[i],
            isSelected: linearStages[i].pokemonId == _selectedPokemonId,
            isCurrent: linearStages[i].pokemonId == widget.pokemonId,
            isPathActive: activePath.contains(linearStages[i].pokemonId),
            width: 88.0,
            onTap: () => setState(() => _selectedPokemonId = linearStages[i].pokemonId),
            onLongPress: () => _handlePokemonLongPress(context, linearStages[i].pokemonId, linearStages[i].pokemon?.name),
          ),
          if (i < linearStages.length - 1)
            VerticalEvolutionConnector(
              condition: linearStages[i + 1].condition,
              isActive: activePath.contains(linearStages[i].pokemonId) &&
                  activePath.contains(linearStages[i + 1].pokemonId),
              activeColor: (linearStages[i + 1].pokemon != null && linearStages[i + 1].pokemon!.types.isNotEmpty)
                  ? AppColors.getTypeColor(linearStages[i + 1].pokemon!.types.first.type.name)
                  : (linearStages[i].pokemon != null && linearStages[i].pokemon!.types.isNotEmpty
                      ? AppColors.getTypeColor(linearStages[i].pokemon!.types.first.type.name)
                      : (widget.themeColor ?? const Color(0xFF1E88E5))),
            ),
        ],

        // Branching Fork Header from Branch Node down to leaves
        if (children.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SizedBox(
              width: forkWidth,
              height: 24,
              child: CustomPaint(
                painter: BranchingForkPainter(
                  childCount: branchCount,
                  activeIndex: activeIndex,
                  inactiveColor: isDark ? Colors.white24 : Colors.black12,
                  activeColor: (activeIndex >= 0 && activeIndex < children.length && children[activeIndex].pokemon != null && children[activeIndex].pokemon!.types.isNotEmpty)
                    ? AppColors.getTypeColor(children[activeIndex].pokemon!.types.first.type.name)
                    : (widget.themeColor ?? (branchNode.pokemon != null && branchNode.pokemon!.types.isNotEmpty
                        ? AppColors.getTypeColor(branchNode.pokemon!.types.first.type.name)
                        : const Color(0xFF1E88E5))),
                ),
              ),
            ),
          ),

          // Row of Branch columns (Gardevoir & Gallade, Flapple & Appletun & Dipplin, etc.)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((child) {
              final isSelected = child.pokemonId == _selectedPokemonId;
              final isCurrent = child.pokemonId == widget.pokemonId;
              final isPathActive = activePath.contains(child.pokemonId);
              final parsed = parseEvoCondition(child.condition);
              final childAestheticColor = (child.pokemon != null && child.pokemon!.types.isNotEmpty)
                  ? AppColors.getTypeColor(child.pokemon!.types.first.type.name)
                  : (widget.themeColor ?? const Color(0xFF1E88E5));

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Condition badge
                    if (child.condition.trim().isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF222634) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPathActive
                                ? childAestheticColor.withValues(alpha: 0.6)
                                : (isDark ? Colors.white12 : Colors.black12),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (parsed.itemImageUrl != null) ...[
                              Image.network(
                                parsed.itemImageUrl!,
                                width: 9,
                                height: 9,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => Icon(
                                  parsed.icon,
                                  size: 8.5,
                                  color: isPathActive ? childAestheticColor : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 3),
                            ] else ...[
                              Icon(parsed.icon, size: 8.5, color: isPathActive ? childAestheticColor : Colors.grey),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              parsed.text,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: isPathActive
                                    ? childAestheticColor
                                    : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                              ),
                            ),
                            if (parsed.genderIcon != null) ...[
                              const SizedBox(width: 2.5),
                              Icon(
                                parsed.genderIcon,
                                size: 9.0,
                                color: parsed.genderIcon == Icons.female
                                    ? const Color(0xFFEC407A)
                                    : const Color(0xFF1E88E5),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    EvolutionPokemonNode(
                      node: child,
                      isSelected: isSelected,
                      isCurrent: isCurrent,
                      isPathActive: isPathActive,
                      width: branchWidth,
                      onTap: () => setState(() => _selectedPokemonId = child.pokemonId),
                      onLongPress: () => _handlePokemonLongPress(context, child.pokemonId, child.pokemon?.name),
                    ),

                    // If branch has further downstream evolution (e.g. Dipplin -> Hydrapple)
                    if (child.evolvesTo.isNotEmpty) ...[
                      ...child.evolvesTo.map((subChild) {
                        final subSelected = subChild.pokemonId == _selectedPokemonId;
                        final subCurrent = subChild.pokemonId == widget.pokemonId;
                        final subPathActive = activePath.contains(subChild.pokemonId);
                        final subConnActive = isPathActive && subPathActive;
                        final subAestheticColor = (subChild.pokemon != null && subChild.pokemon!.types.isNotEmpty)
                            ? AppColors.getTypeColor(subChild.pokemon!.types.first.type.name)
                            : childAestheticColor;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            VerticalEvolutionConnector(
                              condition: subChild.condition,
                              isActive: subConnActive,
                              activeColor: subAestheticColor,
                            ),
                            EvolutionPokemonNode(
                              node: subChild,
                              isSelected: subSelected,
                              isCurrent: subCurrent,
                              isPathActive: subPathActive,
                              width: branchWidth,
                              onTap: () => setState(() => _selectedPokemonId = subChild.pokemonId),
                              onLongPress: () => _handlePokemonLongPress(context, subChild.pokemonId, subChild.pokemon?.name),
                            ),
                          ],
                        );
                      }),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LAYOUT E: SINGLE NON-EVOLVING POKEMON
  // ---------------------------------------------------------------------------

  Widget _buildSingleLayout(
    BuildContext context,
    EvoNode root,
    BoxConstraints constraints,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          EvolutionPokemonNode(
            node: root,
            isSelected: root.pokemonId == _selectedPokemonId,
            isCurrent: root.pokemonId == widget.pokemonId,
            isPathActive: true,
            width: 104.0,
            onTap: () => setState(() => _selectedPokemonId = root.pokemonId),
            onLongPress: () => _handlePokemonLongPress(context, root.pokemonId, root.pokemon?.name),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222634) : const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 13,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Basic Pokémon • Does not evolve',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP MODE SWITCHER (Evolution Tree vs Forms & Megas)
  // ---------------------------------------------------------------------------

  Widget _buildTopModeSwitcher(bool isDark, int altCount) {
    final activeColor = widget.themeColor ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E212D) : const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: _showAlternateForm ? Alignment.centerRight : Alignment.centerLeft,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOutCubic,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      heightFactor: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2B3042) : Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            AppFeedback.selectionClick();
                            setState(() => _showAlternateForm = false);
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.dna,
                                  size: 13,
                                  color: !_showAlternateForm
                                      ? activeColor
                                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Evolution Tree',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: !_showAlternateForm
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            AppFeedback.selectionClick();
                            setState(() => _showAlternateForm = true);
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.zap,
                                  size: 13,
                                  color: _showAlternateForm
                                      ? activeColor
                                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Forms & Megas ($altCount)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: _showAlternateForm
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildInfoButton(isDark),
        ],
      ),
    );
  }

  Widget _buildInfoButton(bool isDark) {
    return Semantics(
      button: true,
      label: 'Evolution navigation guide',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppFeedback.lightImpact();
            _showNavigationInfoSheet(isDark);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E212D) : const Color(0xFFF0F2F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.info,
                size: 16,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNavigationInfoSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final cardBg = isDark ? const Color(0xFF1E212D) : Colors.white;
        final innerTileBg = isDark ? const Color(0xFF282C3D) : const Color(0xFFF3F4F8);

        return Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(sheetContext).bottom + 20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.info,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Evolution Navigation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item 1: Tap to Select
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: innerTileBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.mousePointerClick,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tap to Select',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Selects the Pokémon and traces its ancestral evolution lineage on the tree.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Item 2: Hold to View
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: innerTileBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.fingerprint,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hold to View Pokémon',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Press and hold any Pokémon card to open and inspect its complete details.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Got it button
              ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ALTERNATE FORMS & MEGAS VIEW (Req 8)
  // ---------------------------------------------------------------------------

  Widget _buildAlternateFormsView(BuildContext context, EvoNode root, [double navBarHeight = 80.0]) {
    final cards = _buildAltFormCards(context, root);
    if (cards.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No alternate forms available for this evolution family.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(top: 12, bottom: navBarHeight + 24, left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards,
      ),
    );
  }

  List<Widget> _buildAltFormCards(BuildContext context, EvoNode root) {
    final List<Widget> list = [];
    final Set<int> addedIds = {};

    void collect(EvoNode node) {
      final speciesId = node.pokemonId;

      if (_knownRegionalChains.containsKey(speciesId)) {
        final spec = _knownRegionalChains[speciesId]!;
        final parentAlt = node.altForms.firstWhere(
          (p) => p.id == spec.parentId,
          orElse: () => node.pokemon!,
        );

        if (!addedIds.contains(parentAlt.id)) {
          addedIds.add(parentAlt.id);
          list.add(_AltFormSquareCard(
            pokemon: parentAlt,
            formLabel: spec.parentLabel,
          ));
        }

        for (final childSpec in spec.children) {
          Pokemon? childP;
          for (final c in node.evolvesTo) {
            if (c.pokemonId == childSpec.childId && c.pokemon != null) {
              childP = c.pokemon;
              break;
            }
          }
          childP ??= node.altForms.firstWhere(
            (p) => p.id == childSpec.childId,
            orElse: () => node.pokemon!,
          );

          if (childP.id != parentAlt.id && !addedIds.contains(childP.id)) {
            addedIds.add(childP.id);
            final childAltColor = childP.types.isNotEmpty
                ? AppColors.getTypeColor(childP.types.first.type.name)
                : (widget.themeColor ?? const Color(0xFF1E88E5));
            list.add(VerticalEvolutionConnector(
              condition: childSpec.condition,
              activeColor: childAltColor,
            ));
            list.add(_AltFormSquareCard(
              pokemon: childP,
              formLabel: childSpec.label,
            ));
          }
        }
      }

      for (final altP in node.altForms) {
        if (!addedIds.contains(altP.id)) {
          addedIds.add(altP.id);
          String label = 'Alternate Form';
          final nameLower = altP.name.toLowerCase();
          if (nameLower.contains('mega')) {
            label = 'Mega Evolution';
          } else if (nameLower.contains('gigantamax')) {
            label = 'Gigantamax Form';
          } else if (nameLower.contains('alolan')) {
            label = 'Alolan Form';
          } else if (nameLower.contains('galarian')) {
            label = 'Galarian Form';
          } else if (nameLower.contains('hisuian')) {
            label = 'Hisuian Form';
          } else if (nameLower.contains('paldean')) {
            label = 'Paldean Form';
          }

          list.add(_AltFormSquareCard(
            pokemon: altP,
            formLabel: label,
          ));
        }
      }

      for (final child in node.evolvesTo) {
        collect(child);
      }
    }

    collect(root);
    return list;
  }

  int _countAltForms(EvoNode root) {
    final Set<int> ids = {};
    void count(EvoNode n) {
      for (final alt in n.altForms) {
        if (alt.id != n.pokemonId) ids.add(alt.id);
      }
      for (final c in n.evolvesTo) {
        count(c);
      }
    }
    count(root);
    return ids.length;
  }
}

// =============================================================================
// ALT FORM SQUARE CARD
// =============================================================================

class _AltFormSquareCard extends StatelessWidget {
  final Pokemon pokemon;
  final String? formLabel;

  const _AltFormSquareCard({
    required this.pokemon,
    this.formLabel,
  });

  @override
  Widget build(BuildContext context) {
    final name = PokemonHelpers.formatName(pokemon.name);
    final speciesIdStr = '#${pokemon.speciesId.toString().padLeft(3, '0')}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final aestheticColor = pokemon.types.isNotEmpty
        ? AppColors.getTypeColor(pokemon.types.first.type.name)
        : const Color(0xFF1E88E5);

    return GestureDetector(
      onTap: () {
        AppFeedback.lightImpact();
        context.push('/pokemon/${pokemon.id}');
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E212D) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: aestheticColor.withValues(alpha: isDark ? 0.45 : 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Artwork Image in square container
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141720) : const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Center(
                child: Image.asset(
                  PokemonHelpers.getHomeAssetPath(pokemon.id),
                  height: 58,
                  width: 58,
                  fit: BoxFit.contain,
                  cacheWidth: PokemonHelpers.cacheWidth(context, 58),
                  errorBuilder: (_, _, _) => Image.asset(
                    PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                    height: 58,
                    width: 58,
                    fit: BoxFit.contain,
                    cacheWidth: PokemonHelpers.cacheWidth(context, 58),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (formLabel != null && formLabel!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: aestheticColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formLabel!,
                        style: TextStyle(
                          color: aestheticColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  Text(
                    name,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speciesIdStr,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: pokemon.types.map((t) {
                      final typeName = t.type.name;
                      final typeColor = AppColors.getTypeColor(typeName);
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.4),
                            width: 0.9,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/types/$typeName.svg',
                              width: 11,
                              height: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              typeName[0].toUpperCase() + typeName.substring(1),
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.arrowRight,
              size: 16,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
