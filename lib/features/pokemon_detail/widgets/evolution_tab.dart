import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
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

/// Data structure for regional evolution chains & split evolutions
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
          (e) => {
            'id': e['id'] as int,
            'name': (e['name'] ?? '') as String,
            'evolves_from': e['evolves_from'] as int?,
            'condition': (e['condition'] ?? '') as String,
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

class EvolutionTab extends ConsumerStatefulWidget {
  final String evolutionInfoJson;
  final int? pokemonId;
  final int? speciesId;
  final Widget? header;

  const EvolutionTab({
    super.key,
    required this.evolutionInfoJson,
    this.pokemonId,
    this.speciesId,
    this.header,
  });

  @override
  ConsumerState<EvolutionTab> createState() => _EvolutionTabState();
}

class _EvolutionTabState extends ConsumerState<EvolutionTab> {
  bool _showAlternateForm = false;

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

    return Column(
      children: [
        if (widget.header != null) widget.header!,
        Expanded(
          child: asyncChain.when(
            data: (root) => root == null
                ? const Center(
                    child: Text(
                      'No evolution chain available.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      _buildFitViewportContainer(
                        context,
                        root,
                        _showAlternateForm,
                      ),
                      Positioned(
                        bottom: 96,
                        right: 16,
                        child: _buildFloatingAltFormButton(),
                      ),
                    ],
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, st) => Center(
              child: Text(
                'Error: $e',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingAltFormButton() {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(30),
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        onTap: () {
          setState(() {
            _showAlternateForm = !_showAlternateForm;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _showAlternateForm ? AppColors.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _showAlternateForm ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _showAlternateForm
                      ? Icons.restore
                      : Icons.auto_awesome,
                  color: _showAlternateForm ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _showAlternateForm ? 'Original Form' : 'Alt Form',
                style: TextStyle(
                  color: _showAlternateForm ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ensures the evolution chart fits 100% within available portrait viewport with NO scrolling.
  Widget _buildFitViewportContainer(
    BuildContext context,
    EvoNode root,
    bool showAlternate,
  ) {
    if (showAlternate) {
      return _buildAlternateFormsView(context, root);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 32, bottom: 16, left: 16, right: 16),
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: _buildChainContent(context, root),
            ),
          ),
        );
      },
    );
  }

  /// Dedicated Alternate Forms View displaying forms in white rounded square boxes with drop shadow
  Widget _buildAlternateFormsView(BuildContext context, EvoNode root) {
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 120, left: 16, right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: cards,
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildAltFormCards(BuildContext context, EvoNode root) {
    final List<Widget> list = [];
    final Set<int> addedIds = {};

    void collect(EvoNode node) {
      final speciesId = node.pokemonId;

      // 1. Regional evolution chain & split evolution support
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
            list.add(_buildVerticalArrow(childSpec.condition));
            list.add(_AltFormSquareCard(
              pokemon: childP,
              formLabel: childSpec.label,
            ));
          }
        }
      }

      // 2. Standalone alternate forms (Megas, Gigantamax, Alolan, Hisuian, etc.)
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

  Widget _buildChainContent(BuildContext context, EvoNode root) {
    // Eevee special 8-evolution grid layout
    if (root.pokemonId == 133 && root.evolvesTo.length >= 8) {
      return _buildEeveeCompactGrid(context, root);
    }

    // Single non-evolving Pokemon
    if (root.evolvesTo.isEmpty) {
      return _CleanEvoNode(node: root);
    }

    // Multi-branch evolutions (e.g. Tyrogue, Wurmple, Ralts, Slowpoke, Goomy, Scyther)
    if (root.evolvesTo.length > 1) {
      return _buildBranchLayout(context, root);
    }

    // Single child at root, but child might branch downstream (e.g. Cyndaquil -> Quilava -> Typhlosion/Hisuian Typhlosion)
    final child = root.evolvesTo.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CleanEvoNode(node: root),
        _buildVerticalArrow(child.condition),
        _buildChainContent(context, child),
      ],
    );
  }

  /// Branching evolution tree (e.g. Ralts, Tyrogue, Slowpoke, Meowth, Goomy, Scyther)
  Widget _buildBranchLayout(BuildContext context, EvoNode parent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CleanEvoNode(node: parent),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: parent.evolvesTo.map((child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildVerticalArrow(child.condition),
                  const SizedBox(height: 6),
                  _buildChainContent(context, child),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Eevee (8 evolutions) compact portrait grid layout with condition arrows
  Widget _buildEeveeCompactGrid(BuildContext context, EvoNode eevee) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CleanEvoNode(node: eevee, compact: true),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 16,
          children: eevee.evolvesTo.map((child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildVerticalArrow(child.condition),
                const SizedBox(height: 4),
                _CleanEvoNode(node: child, compact: true),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Vertical connecting arrow line with condition pill badge
  Widget _buildVerticalArrow(String condition) {
    final cleanCond = condition.replaceAll('\n', ' • ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2,
            height: 14,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          if (cleanCond.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                cleanCond,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

/// Square rounded white card with drop shadow for Alternate Form display
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

    return GestureDetector(
      onTap: () => context.push('/pokemon/${pokemon.id}'),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Artwork Image in square container
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  PokemonHelpers.getHomeAssetPath(pokemon.id),
                  height: 60,
                  width: 60,
                  cacheWidth: PokemonHelpers.cacheWidth(context, 60),
                  errorBuilder: (_, _, _) => Image.asset(
                    PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                    height: 60,
                    width: 60,
                    cacheWidth: PokemonHelpers.cacheWidth(context, 60),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        formLabel!,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    name,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    speciesIdStr,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/types/$typeName.svg',
                              width: 12,
                              height: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              typeName[0].toUpperCase() + typeName.substring(1),
                              style: TextStyle(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
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
          ],
        ),
      ),
    );
  }
}

/// Clean, cardless Pokemon evolution node for standard base chain
class _CleanEvoNode extends StatelessWidget {
  final EvoNode node;
  final bool compact;

  const _CleanEvoNode({
    required this.node,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final pokemon = node.pokemon;
    if (pokemon == null) {
      return const SizedBox(width: 70, height: 70, child: CircularProgressIndicator());
    }

    final name = PokemonHelpers.formatName(pokemon.name);
    final speciesIdStr = '#${pokemon.speciesId.toString().padLeft(3, '0')}';
    final imageSize = compact ? 56.0 : 76.0;

    return Semantics(
      button: true,
      label: '$name, $speciesIdStr',
      child: GestureDetector(
        onTap: () {
          context.push('/pokemon/${pokemon.id}');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Artwork Avatar (No cards/boxes for base chain)
            Container(
              width: imageSize + 12,
              height: imageSize + 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  PokemonHelpers.getHomeAssetPath(pokemon.id),
                  height: imageSize,
                  width: imageSize,
                  cacheWidth: PokemonHelpers.cacheWidth(context, imageSize),
                  errorBuilder: (_, _, _) => Image.asset(
                    PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                    height: imageSize,
                    width: imageSize,
                    cacheWidth: PokemonHelpers.cacheWidth(context, imageSize),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Species ID
            Text(
              speciesIdStr,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 11 : 12,
              ),
            ),

            // Name
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 12 : 14,
              ),
            ),

            const SizedBox(height: 4),

            // Compact Type Badges
            Row(
              mainAxisSize: MainAxisSize.min,
              children: pokemon.types.map((t) {
                final typeName = t.type.name;
                final typeColor = AppColors.getTypeColor(typeName);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/types/$typeName.svg',
                        width: 10,
                        height: 10,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        typeName[0].toUpperCase() + typeName.substring(1),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
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
    );
  }
}
