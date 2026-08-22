import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/pokemon_helpers.dart';
import '../../../models/pokemon.dart';
import '../pokedex_provider.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShiny = ref.watch(shinyModeProvider);
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first.type.name : 'normal';
    final baseTypeColor = AppColors.getTypeColor(primaryType);
    
    final typeColor1 = pokemon.types.length > 1 
        ? baseTypeColor.withValues(alpha: 0.5)
        : baseTypeColor.withValues(alpha: 0.2); // Even lighter on the left for single type
        
    final typeColor2 = pokemon.types.length > 1
        ? AppColors.getTypeColor(pokemon.types[1].type.name).withValues(alpha: 0.5)
        : baseTypeColor.withValues(alpha: 0.5);

    // Wrap the card in a RepaintBoundary to isolate paint operations for 120+ FPS scrolling.
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.push('/pokemon/${pokemon.id}'),
        child: Container(
          height: 92,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [typeColor1, typeColor2],
              stops: pokemon.types.length > 1 ? const [0.6, 1.0] : null,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [

              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Watermark Pokeball
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Transform.rotate(
                    angle: 0.3, // Slight rotation for dynamic look
                    child: Icon(
                      Icons.catching_pokemon,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                // Bottom Right ID Text
                Positioned(
                  right: 16,
                  bottom: 4,
                  child: Text(
                    '#${pokemon.speciesId.toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              // Card contents
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Pokemon Image
                    SizedBox(
                      height: 76,
                      width: 76,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Hero(
                            tag: 'pokemon-image-${pokemon.id}',
                            child: Image.asset(
                              isShiny 
                                  ? PokemonHelpers.getHomeShinyAssetPath(pokemon.id)
                                  : PokemonHelpers.getHomeAssetPath(pokemon.id),
                              height: 76,
                              width: 76,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                // If shiny was requested but missing, try normal home asset. If normal missing, try thumbnail.
                                isShiny 
                                    ? PokemonHelpers.getHomeAssetPath(pokemon.id)
                                    : PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                                height: 76,
                                width: 76,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                                  height: 76,
                                  width: 76,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.catching_pokemon,
                                    size: 36,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name, Types, and Heart Icon
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6), // Push down slightly to align with image top
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  PokemonHelpers.formatName(pokemon.name),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: pokemon.types.map((typeSlot) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  top: 4,
                                  bottom: 4,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // SVG Type Icon
                                    Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.only(right: 6),
                                      child: SvgPicture.asset('assets/types/${typeSlot.type.name}.svg'),
                                    ),
                                    Text(
                                      typeSlot.type.name.toUpperCase().substring(0, 1) + typeSlot.type.name.substring(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
            ],
          ),
          ),
        ),
      ),
    );
  }
}
