import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/feedback_service.dart';
import '../../../core/utils/pokemon_helpers.dart';
import '../../../models/pokemon.dart';
import '../../../core/providers.dart';
import '../pokedex_provider.dart';

class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;

  /// When provided, taps invoke this instead of navigating to the detail
  /// screen (used by picker sheets).
  final VoidCallback? onTap;

  /// Heroes animate between routes; disable inside modal sheets.
  final bool showHero;
  final bool isGrid;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
    this.showHero = true,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShiny = ref.watch(shinyModeProvider);
    final isFavorite = ref.watch(favoriteIdsProvider).value?.contains(pokemon.id) ?? false;
    final primaryType = pokemon.types.isNotEmpty
        ? pokemon.types.first.type.name
        : 'normal';
    final baseTypeColor = AppColors.getTypeColor(primaryType);

    final typeColor1 = pokemon.types.length > 1
        ? baseTypeColor.withValues(alpha: 0.55)
        : baseTypeColor.withValues(alpha: 0.45);

    final typeColor2 = pokemon.types.length > 1
        ? AppColors.getTypeColor(
            pokemon.types[1].type.name,
          ).withValues(alpha: 0.55)
        : baseTypeColor.withValues(alpha: 0.55);

    final semanticLabel =
        '${PokemonHelpers.formatName(pokemon.name)}, '
        'number ${pokemon.speciesId.toString().padLeft(3, '0')}, '
        '${pokemon.types.map((t) => t.type.name).join(' and ')} type';

    Widget artwork = Image.asset(
      isShiny
          ? PokemonHelpers.getHomeShinyAssetPath(pokemon.id)
          : PokemonHelpers.getHomeAssetPath(pokemon.id),
      height: isGrid ? 66 : 76,
      width: isGrid ? 66 : 76,
      cacheWidth: PokemonHelpers.cacheWidth(context, isGrid ? 66 : 76),
      filterQuality: FilterQuality.medium,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        // If shiny was requested but missing, try normal home asset. If normal missing, try thumbnail.
        isShiny
            ? PokemonHelpers.getHomeAssetPath(pokemon.id)
            : PokemonHelpers.getThumbnailAssetPath(pokemon.id),
        height: isGrid ? 66 : 76,
        width: isGrid ? 66 : 76,
        cacheWidth: PokemonHelpers.cacheWidth(context, isGrid ? 66 : 76),
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          PokemonHelpers.getThumbnailAssetPath(pokemon.id),
          height: isGrid ? 66 : 76,
          width: isGrid ? 66 : 76,
          cacheWidth: PokemonHelpers.cacheWidth(context, isGrid ? 66 : 76),
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.catching_pokemon,
            size: isGrid ? 30 : 36,
            color: Colors.white54,
          ),
        ),
      ),
    );

    if (isGrid) {
      Widget artworkGrid = Image.asset(
        isShiny
            ? PokemonHelpers.getHomeShinyAssetPath(pokemon.id)
            : PokemonHelpers.getHomeAssetPath(pokemon.id),
        height: 140,
        width: 140,
        cacheWidth: PokemonHelpers.cacheWidth(context, 140),
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          isShiny
              ? PokemonHelpers.getHomeAssetPath(pokemon.id)
              : PokemonHelpers.getThumbnailAssetPath(pokemon.id),
          height: 140,
          width: 140,
          cacheWidth: PokemonHelpers.cacheWidth(context, 140),
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            PokemonHelpers.getThumbnailAssetPath(pokemon.id),
            height: 140,
            width: 140,
            cacheWidth: PokemonHelpers.cacheWidth(context, 140),
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.catching_pokemon,
              size: 60,
              color: Colors.white54,
            ),
          ),
        ),
      );

      return RepaintBoundary(
        child: Semantics(
          button: true,
          label: semanticLabel,
          child: ExcludeSemantics(
            child: GestureDetector(
              onTap: () {
                AppFeedback.lightImpact();
                if (onTap != null) {
                  onTap!();
                } else {
                  FocusManager.instance.primaryFocus?.unfocus();
                  ref.read(searchClearTriggerProvider.notifier).state++;
                  context.push('/pokemon/${pokemon.id}');
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [typeColor1, typeColor2],
                    stops: pokemon.types.length > 1 ? const [0.6, 1.0] : null,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
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
                          angle: 0.3,
                          child: Icon(
                            Icons.catching_pokemon,
                            size: 110,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      // Top Left ID Text
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Text(
                          '#${pokemon.speciesId.toString().padLeft(3, '0')}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Favorite Icon
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(pokemonRepositoryProvider)
                                .toggleFavorite(pokemon.id, !isFavorite);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Card Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Pokemon Image Centered 3x
                            Expanded(
                              child: Center(
                                child: showHero
                                    ? Hero(
                                        tag: 'pokemon-image-${pokemon.id}',
                                        child: artworkGrid,
                                      )
                                    : artworkGrid,
                              ),
                            ),
                            // Name & Types Column
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  PokemonHelpers.formatName(pokemon.name),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: pokemon.types.map((typeSlot) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      padding: const EdgeInsets.only(
                                        left: 4,
                                        top: 2,
                                        bottom: 2,
                                        right: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: SvgPicture.asset(
                                              'assets/types/${typeSlot.type.name}.svg',
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            typeSlot.type.name[0].toUpperCase() +
                                                typeSlot.type.name.substring(1),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9.5,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Expose the whole card as one tappable button to screen readers.
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: () {
              AppFeedback.lightImpact();
              if (onTap != null) {
                onTap!();
              } else {
                FocusManager.instance.primaryFocus?.unfocus();
                ref.read(searchClearTriggerProvider.notifier).state++;
                context.push('/pokemon/${pokemon.id}');
              }
            },
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
                                showHero
                                    ? Hero(
                                        tag: 'pokemon-image-${pokemon.id}',
                                        child: artwork,
                                      )
                                    : artwork,
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
                                const SizedBox(
                                  height: 6,
                                ), // Push down slightly to align with image top
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        PokemonHelpers.formatName(pokemon.name),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        AppFeedback.selectionClick();
                                        ref
                                            .read(pokemonRepositoryProvider)
                                            .toggleFavorite(pokemon.id, !isFavorite);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 4),
                                        child: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite
                                              ? Colors.redAccent
                                              : Colors.white.withValues(alpha: 0.6),
                                          size: 20,
                                        ),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // SVG Type Icon
                                          Container(
                                            width: 20,
                                            height: 20,
                                            margin: const EdgeInsets.only(
                                              right: 6,
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/types/${typeSlot.type.name}.svg',
                                            ),
                                          ),
                                          Text(
                                            typeSlot.type.name
                                                    .toUpperCase()
                                                    .substring(0, 1) +
                                                typeSlot.type.name.substring(1),
                                            style: TextStyle(
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
        ),
      ),
    );
  }
}
