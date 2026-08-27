import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:audioplayers/audioplayers.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../models/pokemon.dart';
import '../../app/theme/app_colors.dart';
import '../pokedex/pokedex_provider.dart';
import '../pokedex/widgets/pokemon_card.dart';
import 'widgets/evolution_tab.dart';
import 'widgets/about_tab.dart';
import 'widgets/stats_tab.dart';
import 'widgets/moves_tab.dart';
import 'widgets/defense_tab.dart';

final pokemonDetailProvider = FutureProvider.family<Pokemon, int>((
  ref,
  id,
) async {
  final repository = ref.read(pokemonRepositoryProvider);
  return repository.getPokemonDetails(id);
});

final speciesInfoProvider =
    FutureProvider.family<({String category, String? flavorText}), int>((
      ref,
      id,
    ) async {
      final repository = ref.read(pokemonRepositoryProvider);
      return repository.getSpeciesInfo(id);
    });

final cachedSpeciesProvider =
    FutureProvider.family<({String? category, String? flavorText}), int>((
      ref,
      id,
    ) async {
      final repository = ref.read(pokemonRepositoryProvider);
      return repository.getCachedSpeciesInfo(id);
    });

final abilitiesSeedProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final raw = await rootBundle.loadString('assets/abilities_seed.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list.cast<Map<String, dynamic>>();
});

int? extractIdFromUrl(String url) {
  try {
    final segments = Uri.parse(
      url,
    ).pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;
    return int.tryParse(segments.last);
  } on FormatException {
    return null;
  }
}

class PokemonDetailScreen extends ConsumerWidget {
  final int pokemonId;

  const PokemonDetailScreen({super.key, required this.pokemonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(pokemonDetailProvider(pokemonId));

    return detailAsync.when(
      data: (pokemon) => _ProfileContent(pokemon: pokemon),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error loading Pok\u00e9mon: $err')),
      ),
    );
  }
}

class _ProfileContent extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const _ProfileContent({required this.pokemon});

  @override
  ConsumerState<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<_ProfileContent> {
  late final PageController _outerController;
  late PageController _innerController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentOuterPage = 0;
  int _currentInnerPage = 0;

  int get _currentPage {
    if (_currentOuterPage == 0) return 0;
    return _currentInnerPage + 1;
  }

  @override
  void initState() {
    super.initState();
    _outerController = PageController(initialPage: 0);
    _innerController = PageController(initialPage: 0);
  }

  String _sanitizeCryName(String raw) {
    const accents = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ã': 'a',
      'ä': 'a',
      'å': 'a',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ö': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ñ': 'n',
      'ç': 'c',
    };
    var name = raw.toLowerCase().replaceAllMapped(
      RegExp('[àáâãäåèéêëìíîïòóôõöùúûüñç]'),
      (m) => accents[m[0]] ?? m[0]!,
    );
    return name.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  static final _cryOverrides = <String, String>{
    'Mega Venusaur': 'venusaur-mega',
    'Mega Charizard X': 'charizard-megax',
    'Mega Charizard Y': 'charizard-megay',
    'Mega Blastoise': 'blastoise-mega',
    'Mega Beedrill': 'beedrill-mega',
    'Mega Pidgeot': 'pidgeot-mega',
    'Mega Alakazam': 'alakazam-mega',
    'Mega Slowbro': 'slowbro-mega',
    'Mega Gengar': 'gengar-mega',
    'Mega Kangaskhan': 'kangaskhan-mega',
    'Mega Pinsir': 'pinsir-mega',
    'Mega Gyarados': 'gyarados-mega',
    'Mega Aerodactyl': 'aerodactyl-mega',
    'Mega Mewtwo X': 'mewtwo-megax',
    'Mega Mewtwo Y': 'mewtwo-megay',
    'Mega Ampharos': 'ampharos-mega',
    'Mega Steelix': 'steelix-mega',
    'Mega Scizor': 'scizor-mega',
    'Mega Heracross': 'heracross-mega',
    'Mega Houndoom': 'houndoom-mega',
    'Mega Tyranitar': 'tyranitar-mega',
    'Mega Sceptile': 'sceptile-mega',
    'Mega Swampert': 'swampert-mega',
    'Mega Gardevoir': 'gardevoir-mega',
    'Mega Sableye': 'sableye-mega',
    'Mega Mawile': 'mawile-mega',
    'Mega Aggron': 'aggron-mega',
    'Mega Medicham': 'medicham-mega',
    'Mega Manectric': 'manectric-mega',
    'Mega Sharpedo': 'sharpedo-mega',
    'Mega Camerupt': 'camerupt-mega',
    'Mega Altaria': 'altaria-mega',
    'Mega Banette': 'banette-mega',
    'Mega Absol': 'absol-mega',
    'Mega Glalie': 'glalie-mega',
    'Mega Salamence': 'salamence-mega',
    'Mega Metagross': 'metagross-mega',
    'Mega Latias': 'latias-mega',
    'Mega Latios': 'latios-mega',
    'Mega Rayquaza': 'rayquaza-mega',
    'Mega Lopunny': 'lopunny-mega',
    'Mega Garchomp': 'garchomp-mega',
    'Mega Lucario': 'lucario-mega',
    'Mega Abomasnow': 'abomasnow-mega',
    'Mega Gallade': 'gallade-mega',
    'Mega Audino': 'audino-mega',
    'Mega Diancie': 'diancie-mega',
  };

  String _resolveCryId(String rawName) {
    final override = _cryOverrides[rawName];
    if (override != null) return override;

    var name = rawName;
    if (name.contains(' Breed Paldean ')) {
      name = name.substring(name.indexOf(' Breed Paldean ') + 15);
    }
    for (final prefix in [
      'Galarian Zen Mode ',
      'Totem Disguised ',
      'Totem Busted ',
      'Totem ',
      'Mega ',
      'Alolan ',
      'Galarian ',
      'Hisuian ',
      'Paldean ',
      'Gigantamax ',
      'Primal ',
      'Therian ',
      'Zen Mode ',
      'Standard ',
      'Disguised ',
      'Busted ',
      'Complete ',
    ]) {
      if (name.startsWith(prefix)) {
        name = name.substring(prefix.length);
        break;
      }
    }
    if (RegExp(r' [XY]$').hasMatch(name)) {
      name = name.substring(0, name.length - 2);
    }
    if (RegExp(r'^\d+').hasMatch(name)) {
      name = name.replaceFirst(RegExp(r'^\d+\s*(Power Construct\s*)?'), '');
    }
    if (name.startsWith('Pikachu ') && !_cryOverrides.containsKey(rawName)) {
      name = 'Pikachu';
    }
    if (name == 'O Kommo') name = 'Kommo-o';

    return _sanitizeCryName(name);
  }

  void _playCry() async {
    final cryId = _resolveCryId(widget.pokemon.name);
    final url = 'https://play.pokemonshowdown.com/audio/cries/$cryId.mp3';
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      final fallbackId = _sanitizeCryName(widget.pokemon.name.split(' ').last);
      if (fallbackId != cryId) {
        try {
          await _audioPlayer.stop();
          await _audioPlayer.play(
            UrlSource(
              'https://play.pokemonshowdown.com/audio/cries/$fallbackId.mp3',
            ),
          );
        } catch (_) {
          debugPrint('Fallback cry also failed for $fallbackId');
        }
      } else {
        debugPrint('Failed to play cry: $e');
      }
    }
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _navigateToPage(int index) {
    if (index == 0) {
      _outerController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      if (_currentOuterPage == 0) {
        setState(() {
          _currentInnerPage = index - 1;
        });
        if (_innerController.hasClients) {
          _innerController.jumpToPage(index - 1);
        } else {
          _innerController.dispose();
          _innerController = PageController(initialPage: index - 1);
        }
        _outerController.animateToPage(
          1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _innerController.animateToPage(
          index - 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShiny = ref.watch(shinyModeProvider);
    final pokemon = widget.pokemon;
    final primaryType = pokemon.types.isNotEmpty
        ? pokemon.types.first.type.name
        : 'normal';
    final themeColor = AppColors.getTypeColor(primaryType);
    final speciesData = PokemonHelpers.getPokemonSpeciesData(pokemon.speciesId);

    final cachedInfo = ref
        .watch(cachedSpeciesProvider(pokemon.id))
        .asData
        ?.value;
    final categoryText =
        cachedInfo?.category ??
        ref
            .watch(speciesInfoProvider(pokemon.id))
            .when(
              data: (info) => info.category,
              loading: () => '...',
              error: (_, _) => 'Unknown Pok\u00e9mon',
            ) ??
        'Unknown Pok\u00e9mon';

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFBCAAA4),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final fullHeader = Stack(
            key: const ValueKey('full-header'),
            alignment: Alignment.topCenter,
            children: [
              Column(
                children: [
                  // 3D Image Artwork
                  Hero(
                    tag: 'pokemon-image-${pokemon.id}',
                    child: Image.asset(
                      isShiny
                          ? PokemonHelpers.getHomeShinyAssetPath(pokemon.id)
                          : PokemonHelpers.getHomeAssetPath(pokemon.id),
                      height: 300,
                      fit: BoxFit.contain,
                      cacheWidth: PokemonHelpers.cacheWidth(context, 300),
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        isShiny
                            ? PokemonHelpers.getHomeAssetPath(pokemon.id)
                            : PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                        height: 300,
                        fit: BoxFit.contain,
                        cacheWidth: PokemonHelpers.cacheWidth(context, 300),
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                              height: 300,
                              fit: BoxFit.contain,
                              cacheWidth: PokemonHelpers.cacheWidth(
                                context,
                                300,
                              ),
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.catching_pokemon,
                                    size: 100,
                                    color: Colors.white54,
                                  ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    PokemonHelpers.formatName(pokemon.name),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Types Pills Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pokemon.types.map((t) {
                      final tColor = AppColors.getTypeColor(t.type.name);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tColor.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 6),
                              child: SvgPicture.asset(
                                'assets/types/${t.type.name}.svg',
                              ),
                            ),
                            Text(
                              t.type.name.substring(0, 1).toUpperCase() +
                                  t.type.name.substring(1),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
              // Floating Top Bar
              Positioned(
                top: 0,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${pokemon.speciesId.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        _GlassButton(
                          icon: Icons.volume_up,
                          color: Colors.white,
                          onTap: _playCry,
                        ),
                        const SizedBox(width: 12),
                        _GlassButton(
                          icon: isShiny
                              ? Icons.auto_awesome
                              : Icons.auto_awesome_outlined,
                          color: isShiny ? Colors.amber : Colors.white,
                          onTap: () {
                            ref.read(shinyModeProvider.notifier).state =
                                !isShiny;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          final compactHeader = Padding(
            key: const ValueKey('card-header'),
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PokemonCard(
              pokemon: pokemon,
              showHero: false,
              onTap: () {}, // No-op to disable navigation
            ),
          );

          return Stack(
            children: [
              Positioned.fill(
                child: PageView(
                  controller: _outerController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentOuterPage = index;
                    });
                  },
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top + 8,
                      ),
                      child: AboutTab(
                        pokemon: pokemon,
                        themeColor: themeColor,
                        speciesData: speciesData,
                        header: fullHeader,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top + 8,
                      ),
                      child: Column(
                        children: [
                          compactHeader,
                          Expanded(
                            child: PageView(
                              controller: _innerController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentInnerPage = index;
                                });
                              },
                              children: [
                                StatsTab(
                                  pokemon: pokemon,
                                  themeColor: themeColor,
                                ),
                                MovesTab(
                                  pokemon: pokemon,
                                  themeColor: themeColor,
                                ),
                                DefenseTab(
                                  types: pokemon.types,
                                  themeColor: themeColor,
                                ),
                                EvolutionTab(
                                  evolutionInfoJson:
                                      pokemon.evolutionInfo ?? '[]',
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
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _navigateToPage(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: _currentPage == 0 ? Colors.transparent : Colors.white,
        elevation: _currentPage == 0 ? 0 : 8,
        selectedItemColor: themeColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Movesets'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            label: 'Defense',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Evolution',
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _GlassButton({
    required this.icon,
    this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );

    if (onTap == null) return inner;

    return GestureDetector(onTap: onTap, child: inner);
  }
}
