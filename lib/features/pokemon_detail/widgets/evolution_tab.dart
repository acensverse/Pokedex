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

/// Known regional evolution overrides: map regional evolution child ID to regional parent form ID
const _regionalParentOverrides = <int, int>{
  863: 10161, // Perrserker <- Galarian Meowth
  865: 10166, // Sirfetch'd <- Galarian Farfetch'd
  864: 10173, // Cursola <- Galarian Corsola
  867: 10179, // Runerigus <- Galarian Yamask
  862: 10175, // Obstagoon <- Galarian Linoone
  866: 10168, // Mr. Rime <- Galarian Mr. Mime
  980: 10253, // Clodsire <- Paldean Wooper
  904: 10234, // Overqwil <- Hisuian Qwilfish
  903: 10235, // Sneasler <- Hisuian Sneasel
  10232: 10231, // Hisuian Electrode <- Hisuian Voltorb
  10239: 10238, // Hisuian Zoroark <- Hisuian Zorua
  10230: 10229, // Hisuian Arcanine <- Hisuian Growlithe
  10165: 10164, // Galarian Slowbro <- Galarian Slowpoke
  10172: 10164, // Galarian Slowking <- Galarian Slowpoke
  10163: 10162, // Galarian Rapidash <- Galarian Ponyta
};

/// Builds the evolution tree from baked seed data, resolving accurate Pokemon models offline.
final evolutionChainProvider = FutureProvider.family<EvoNode?, String>((
  ref,
  evolutionInfoJson,
) async {
  final entries = (jsonDecode(evolutionInfoJson) as List? ?? const [])
      .cast<Map>()
      .map(
        (e) => {
          'id': e['id'] as int,
          'name': (e['name'] ?? '') as String,
          'evolves_from': e['evolves_from'] as int?,
          'condition': (e['condition'] ?? '') as String,
        },
      )
      .toList();
  if (entries.isEmpty) return null;

  // Create nodes, linking children to parents
  final nodes = <int, EvoNode>{
    for (final e in entries)
      e['id'] as int: EvoNode(
        pokemonId: e['id'] as int,
        condition: e['condition'] as String,
        evolvesTo: [],
      ),
  };
  EvoNode? root;
  for (final e in entries) {
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
  final repo = ref.read(pokemonRepositoryProvider);
  final entryById = {for (final e in entries) e['id'] as int: e};

  Future<void> resolveModels(EvoNode node) async {
    // 1. Fetch primary base Pokemon model
    try {
      node.pokemon = await repo.getPokemonDetails(node.pokemonId);
    } catch (_) {
      final entry = entryById[node.pokemonId];
      node.pokemon = Pokemon(
        id: node.pokemonId,
        speciesId: node.pokemonId,
        name: (entry?['name'] as String?) ?? '',
        height: 0,
        weight: 0,
        types: const [],
        stats: const [],
        abilities: const [],
        moves: const [],
      );
    }

    // 2. Resolve regional parent override form if any child requires it
    for (final child in node.evolvesTo) {
      if (_regionalParentOverrides.containsKey(child.pokemonId)) {
        final regParentId = _regionalParentOverrides[child.pokemonId]!;
        try {
          final regParentP = await repo.getPokemonDetails(regParentId);
          if (!node.altForms.any((p) => p.id == regParentId)) {
            node.altForms.add(regParentP);
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
  final Widget? header;

  const EvolutionTab({super.key, required this.evolutionInfoJson, this.header});

  @override
  ConsumerState<EvolutionTab> createState() => _EvolutionTabState();
}

class _EvolutionTabState extends ConsumerState<EvolutionTab> {
  bool _showAlternateForm = false;

  @override
  Widget build(BuildContext context) {
    final asyncChain = ref.watch(evolutionChainProvider(widget.evolutionInfoJson));

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
                style: const TextStyle(color: Colors.redAccent),
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
            color: _showAlternateForm ? AppColors.primary : Colors.white,
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
      // 1. Regional parent override check (e.g. Galarian Meowth -> Perrserker, Galarian Zigzagoon -> Obstagoon)
      for (final child in node.evolvesTo) {
        if (_regionalParentOverrides.containsKey(child.pokemonId)) {
          final parentAltId = _regionalParentOverrides[child.pokemonId]!;
          final parentAlt = node.altForms.firstWhere(
            (p) => p.id == parentAltId,
            orElse: () => node.pokemon!,
          );

          if (!addedIds.contains(parentAlt.id)) {
            addedIds.add(parentAlt.id);
            list.add(_AltFormSquareCard(
              pokemon: parentAlt,
              formLabel: 'Regional Base Form',
            ));
          }

          if (child.pokemon != null && !addedIds.contains(child.pokemon!.id)) {
            addedIds.add(child.pokemon!.id);
            list.add(_AltFormSquareCard(
              pokemon: child.pokemon!,
              formLabel: 'Regional Evolution',
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

    // Multi-branch evolutions (e.g. Tyrogue, Wurmple, Ralts, Slowpoke, Oddish)
    if (root.evolvesTo.length > 1) {
      return _buildBranchLayout(context, root);
    }

    // Standard linear chain (1 -> 2 -> 3 stage vertical flow)
    return _buildVerticalLinearChain(context, root);
  }

  /// Top-to-bottom vertical linear chain (fits portrait space cleanly)
  Widget _buildVerticalLinearChain(BuildContext context, EvoNode node) {
    final list = <Widget>[_CleanEvoNode(node: node)];

    var current = node;
    while (current.evolvesTo.isNotEmpty) {
      final child = current.evolvesTo.first;
      list.add(_buildVerticalArrow(child.condition));
      list.add(_CleanEvoNode(node: child));
      current = child;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: list,
    );
  }

  /// Branching evolution tree (e.g. Ralts, Tyrogue, Slowpoke, Meowth)
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
                  if (child.evolvesTo.isEmpty)
                    _CleanEvoNode(node: child)
                  else
                    _buildBranchLayout(context, child),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Eevee (8 evolutions) compact portrait grid layout
  Widget _buildEeveeCompactGrid(BuildContext context, EvoNode eevee) {
    EvoNode? findEvo(int id) {
      for (final e in eevee.evolvesTo) {
        if (e.pokemonId == id || e.pokemon?.id == id) return e;
      }
      return null;
    }

    Widget cell(int id) {
      final node = findEvo(id);
      if (node == null) return const SizedBox(width: 80, height: 100);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CleanEvoNode(node: node, compact: true),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cell(134), // Vaporeon
            const SizedBox(width: 16),
            cell(135), // Jolteon
            const SizedBox(width: 16),
            cell(136), // Flareon
          ],
        ),
        const SizedBox(height: 12),
        // Row 2 (Eevee in center)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cell(700), // Sylveon
            const SizedBox(width: 20),
            _CleanEvoNode(node: eevee, compact: true),
            const SizedBox(width: 20),
            cell(196), // Espeon
          ],
        ),
        const SizedBox(height: 12),
        // Row 3
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cell(471), // Glaceon
            const SizedBox(width: 16),
            cell(470), // Leafeon
            const SizedBox(width: 16),
            cell(197), // Umbreon
          ],
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
                color: Colors.white,
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
                style: const TextStyle(
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
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
                color: Colors.grey.shade50,
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    speciesIdStr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
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
                color: Colors.white,
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
                color: AppColors.textPrimary,
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
