import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/pokemon_helpers.dart';
import '../../../core/providers.dart';
import '../../../models/pokemon.dart';

class EvoNode {
  final int pokemonId;
  final String condition;
  final List<EvoNode> evolvesTo;
  Pokemon? pokemon;

  EvoNode({
    required this.pokemonId,
    required this.condition,
    required this.evolvesTo,
  });
}

/// Builds the evolution tree from the baked seed data
/// (evolutionInfo: [{id, name, evolves_from, condition}]) — fully offline.
/// Node models resolve from the seeded SQLite cache (cache-first).
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

  // Create nodes, then link children to their parents.
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

  // Resolve display models from the seeded DB (cache-first, no network).
  final repo = ref.read(pokemonRepositoryProvider);
  final entryById = {for (final e in entries) e['id'] as int: e};

  Future<void> resolveModels(EvoNode node) async {
    try {
      node.pokemon = await repo.getPokemonDetails(node.pokemonId);
    } catch (_) {
      // Fallback: minimal model from the baked entry so the node still
      // renders (grey card, name, no type pills).
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
    for (final child in node.evolvesTo) {
      await resolveModels(child);
    }
  }

  await resolveModels(root);
  return root;
});

class EvolutionTab extends ConsumerWidget {
  final String evolutionInfoJson;
  final Widget? header;

  const EvolutionTab({super.key, required this.evolutionInfoJson, this.header});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncChain = ref.watch(evolutionChainProvider(evolutionInfoJson));

    return Column(
      children: [
        ?header,
        Expanded(
          child: asyncChain.when(
            data: (root) => root == null
                ? const Center(
                    child: Text(
                      'No evolution chain available.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : _buildChainContent(context, root),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (e, st) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChainContent(BuildContext context, EvoNode root) {
    // If it's Eevee (id 133) and has 8 evolutions, we use a radial/grid layout
    if (root.pokemonId == 133 && root.evolvesTo.length == 8) {
      return _buildEeveeRadialLayout(context, root);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(
        top: 32,
        bottom: 32 + MediaQuery.paddingOf(context).bottom,
        left: 24,
        right: 24,
      ),
      child: _buildTree(context, root),
    );
  }

  Widget _buildTree(BuildContext context, EvoNode node) {
    if (node.evolvesTo.isEmpty) {
      return _buildNodeWidget(context, node);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNodeWidget(context, node),
        const SizedBox(width: 24),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: node.evolvesTo
              .map(
                (child) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildArrow(child.condition),
                      const SizedBox(width: 24),
                      _buildTree(context, child),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildArrow(String condition) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_forward, color: Colors.white70, size: 28),
        if (condition.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            condition,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEeveeRadialLayout(BuildContext context, EvoNode eevee) {
    // Special layout for Eevee matching the provided image.
    // Nodes are located by species ID, never by list position, so a missing or
    // reordered entry degrades gracefully instead of showing the wrong Pokemon.
    EvoNode? findEvo(int id) {
      for (final e in eevee.evolvesTo) {
        if (e.pokemonId == id) return e;
      }
      return null;
    }

    Widget cell(int id) {
      final node = findEvo(id);
      return node != null
          ? _buildTree(context, node)
          : const SizedBox(width: 130, height: 200);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: 16,
        bottom: 16 + MediaQuery.paddingOf(context).bottom,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              cell(134), // Vaporeon
              cell(135), // Jolteon
              cell(136), // Flareon
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              cell(700), // Sylveon
              _buildNodeWidget(context, eevee),
              cell(196), // Espeon
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cell(471), // Glaceon
              cell(470), // Leafeon
              cell(197), // Umbreon
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(BuildContext context, EvoNode node) {
    if (node.pokemon == null) {
      return const SizedBox(width: 120, height: 200, child: Placeholder());
    }

    final pokemon = node.pokemon!;
    final primaryType = pokemon.types.isNotEmpty
        ? pokemon.types.first.type.name
        : 'normal';
    final bgColor = AppColors.getTypeColor(primaryType);
    final semanticLabel =
        '${PokemonHelpers.formatName(pokemon.name)}, '
        '${pokemon.types.map((t) => t.type.name).join(' and ')} type';

    // Expose each evolution stage as one tappable button to screen readers.
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: () {
            context.push('/pokemon/${pokemon.id}');
          },
          child: Container(
            width: 130,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Curved top with image
                ClipPath(
                  clipper: _TopCurveClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 110,
                    color: Colors.white.withValues(alpha: 0.9),
                    child: Center(
                      child: Image.asset(
                        PokemonHelpers.getHomeAssetPath(pokemon.id),
                        height: 80,
                        cacheWidth: PokemonHelpers.cacheWidth(context, 80),
                        errorBuilder: (_, _, _) => Image.asset(
                          PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                          height: 80,
                          cacheWidth: PokemonHelpers.cacheWidth(context, 80),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ID
                Text(
                  '#${pokemon.speciesId.toString().padLeft(3, '0')}',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    PokemonHelpers.formatName(pokemon.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // Type Pills
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: pokemon.types
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: _buildTypePill(t.type.name),
                          ),
                        )
                        .toList(),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypePill(String type) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/types/$type.svg',
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
              Colors.black54,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    // Control point is at bottom center
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
