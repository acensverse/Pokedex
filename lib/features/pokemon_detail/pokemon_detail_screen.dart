import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/providers.dart';
import '../../core/utils/pokemon_helpers.dart';
import '../../core/utils/type_chart.dart';
import '../../models/pokemon.dart';
import '../../models/move.dart';
import '../../app/theme/app_colors.dart';
import '../pokedex/pokedex_provider.dart';
import 'widgets/evolution_tab.dart';

final pokemonDetailProvider = FutureProvider.family<Pokemon, int>((ref, id) async {
  final repository = ref.read(pokemonRepositoryProvider);
  return repository.getPokemonDetails(id);
});

final speciesInfoProvider = FutureProvider.family<({String category, String? flavorText}), int>((ref, id) async {
  final repository = ref.read(pokemonRepositoryProvider);
  return repository.getSpeciesInfo(id);
});

/// SQLite-only snapshot: resolves in milliseconds so the header never waits
/// on the species network fetch that speciesInfoProvider may need.
final cachedSpeciesProvider =
    FutureProvider.family<({String? category, String? flavorText}), int>((ref, id) async {
  final repository = ref.read(pokemonRepositoryProvider);
  return repository.getCachedSpeciesInfo(id);
});

final moveDetailProvider = FutureProvider.family<Move, String>((ref, url) async {
  final api = ref.read(pokeApiProvider);
  final id = extractIdFromUrl(url);
  if (id == null) {
    throw ArgumentError('Malformed move URL: $url');
  }
  return api.fetchMoveDetails(id);
});

/// Move lists are the only profile section not kept in SQLite; loading them
/// lazily lets the rest of the page paint instantly from the local database.
final pokemonMovesProvider = FutureProvider.family<List<PokemonMoveSlot>, int>((ref, id) async {
  final repository = ref.read(pokemonRepositoryProvider);
  return repository.getPokemonMoves(id);
});

int? extractIdFromUrl(String url) {
  try {
    final segments = Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
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

class _ProfileContentState extends ConsumerState<_ProfileContent> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _statsMode = 'Base';
  String _activeTab = 'About';
  String _activeMoveTab = 'Level up'; 

  bool _isMenuOpen = false;
  late AnimationController _menuController;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _menuController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  // Transliterates accented characters so names like "Flabébé" resolve to
  // the correct cry file (flabebe.mp3) instead of being truncated.
  String _sanitizeCryName(String raw) {
    const accents = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
      'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
      'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
      'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
      'ñ': 'n', 'ç': 'c',
    };
    var name = raw.toLowerCase().replaceAllMapped(
          RegExp('[àáâãäåèéêëìíîïòóôõöùúûüñç]'),
          (m) => accents[m[0]] ?? m[0]!,
        );
    return name.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  // Maps a Pokemon's display name to the correct Showdown cry ID.
  // Most forms use the base species cry; only mega evolutions get unique files.
  static final _cryOverrides = <String, String>{
    'Mega Venusaur': 'venusaur-mega',

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

    'Mega Ampharos': 'ampharos-mega',
    'Mega Steelix': 'steelix-mega',
    'Mega Scizor': 'scizor-mega',
    'Mega Heracross': 'heracross-mega',
    'Mega Houndoom': 'houndoom-mega',
    'Mega Tyranitar': 'tyranitar-mega',
    'Mega Sceptile': 'sceptile-mega',
    'Mega Swampert': 'swampert-mega',
    'Mega Gardevoir': 'gardevoir-mega',
    'Mega Mawile': 'mawile-mega',
    'Mega Aggron': 'aggron-mega',
    'Mega Manectric': 'manectric-mega',
    'Mega Garchomp': 'garchomp-mega',
    'Mega Lucario': 'lucario-mega',
    'Mega Abomasnow': 'abomasnow-mega',
    'Mega Gallade': 'gallade-mega',
    'Mega Audino': 'audino-mega',
    'Mega Diancie': 'diancie-mega',
  };

  String _resolveCryId(String rawName) {
    // Check the override table first (mega forms with unique cry files).
    final override = _cryOverrides[rawName];
    if (override != null) return override;

    // For everything else, strip form prefixes — the base species cry is used
    // for Alolan, Galarian, Hisuian, Paldean, G-Max, Totem, Primal, Therian,
    // Zen Mode, costume, and all other non-mega forms on Showdown.
    var name = rawName;
    // Compound multi-word prefixes first
    if (name.contains(' Breed Paldean ')) {
      name = name.substring(name.indexOf(' Breed Paldean ') + 15);
    }
    // Single-word prefixes (longest first to avoid partial matches)
    for (final prefix in [
      'Galarian Zen Mode ', 'Totem Disguised ', 'Totem Busted ',
      'Totem ', 'Mega ', 'Alolan ', 'Galarian ', 'Hisuian ', 'Paldean ',
      'Gigantamax ', 'Primal ', 'Therian ', 'Zen Mode ', 'Standard ',
      'Disguised ', 'Busted ', 'Complete ',
    ]) {
      if (name.startsWith(prefix)) {
        name = name.substring(prefix.length);
        break;
      }
    }
    // Mega variants with X/Y suffix (e.g. "Mega Charizard X" -> "Charizard")
    // have no unique cry files on Showdown; strip the trailing suffix.
    if (RegExp(r' [XY]$').hasMatch(name)) {
      name = name.substring(0, name.length - 2);
    }
    // Percentage prefixes: "10 Power Construct Zygarde" -> "Zygarde"
    if (RegExp(r'^\d+').hasMatch(name)) {
      name = name.replaceFirst(RegExp(r'^\d+\s*(Power Construct\s*)?'), '');
    }
    // Pikachu costumes/caps: "Pikachu Rock Star" -> "Pikachu"
    if (name.startsWith('Pikachu ') && !_cryOverrides.containsKey(rawName)) {
      name = 'Pikachu';
    }
    // Data issue: "O Totem Kommo" after stripping -> "O Kommo"
    if (name == 'O Kommo') name = 'Kommo-o';

    return _sanitizeCryName(name);
  }

  void _playCry() async {
    final cryId = _resolveCryId(widget.pokemon.name);
    final url = 'https://play.pokemonshowdown.com/audio/cries/$cryId.mp3';
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      // Fallback to the base species cry if the resolved file is missing.
      final fallbackId = _sanitizeCryName(widget.pokemon.name.split(' ').last);
      if (fallbackId != cryId) {
        try {
          await _audioPlayer.play(UrlSource(
            'https://play.pokemonshowdown.com/audio/cries/$fallbackId.mp3',
          ));
        } catch (_) {
          debugPrint('Fallback cry also failed for $fallbackId');
        }
      } else {
        debugPrint('Failed to play cry: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isShiny = ref.watch(shinyModeProvider);
    final pokemon = widget.pokemon;
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first.type.name : 'normal';
    final themeColor = AppColors.getTypeColor(primaryType);
    final speciesData = PokemonHelpers.getPokemonSpeciesData(pokemon.speciesId);
    
    // The category ships in the seed asset, so the instant DB snapshot almost
    // always wins; only fall back to (and wait on) the network provider when
    // the row has no trustworthy category yet.
    final cachedInfo = ref.watch(cachedSpeciesProvider(pokemon.id)).asData?.value;
    final categoryText = cachedInfo?.category ??
        ref.watch(speciesInfoProvider(pokemon.id)).when(
          data: (info) => info.category,
          loading: () => '...',
          error: (_, _) => 'Unknown Pok\u00e9mon',
        ) ??
        'Unknown Pok\u00e9mon';

    return Scaffold(
      backgroundColor: const Color(0xFFBCAAA4), // Neutral warm background fallback
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    themeColor.withValues(alpha: 0.4),
                    const Color(0xFFD6C8B8), // Soft warm tone from the UI reference
                    const Color(0xFFC7B19D), // Darker at bottom
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.paddingOf(context).top + 40),

                  // 3D Image Artwork
                  Hero(
                    tag: 'pokemon-image-${pokemon.id}',
                    child: Image.asset(
                      isShiny 
                          ? PokemonHelpers.getHomeShinyAssetPath(pokemon.id)
                          : PokemonHelpers.getHomeAssetPath(pokemon.id),
                      height: 300,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        isShiny 
                            ? PokemonHelpers.getHomeAssetPath(pokemon.id)
                            : PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                        height: 300,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          PokemonHelpers.getThumbnailAssetPath(pokemon.id),
                          height: 300,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          errorBuilder: (context, error, stackTrace) => const Icon(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tColor.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16, height: 16,
                              margin: const EdgeInsets.only(right: 6),
                              child: SvgPicture.asset('assets/types/${t.type.name}.svg'),
                            ),
                            Text(
                              t.type.name.substring(0,1).toUpperCase() + t.type.name.substring(1),
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                                   const SizedBox(height: 32),

                  // Tab Content Render
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildTabContent(themeColor, speciesData),
                  ),
                ],
              ),
            ),
          ),

          // Glassmorphism Navigation Buttons (Top)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 24,
            left: 24,
            child: Semantics(
              button: true,
              label: 'Back',
              child: GestureDetector(
                // Single predictable behavior: always navigate back.
                // Tab switching lives in the poke-ball menu on the right.
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    ExcludeSemantics(
                      child: Text(
                        '#${pokemon.speciesId.toString().padLeft(3, '0')}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _GlassButton(
                      icon: Icons.auto_awesome,
                      color: isShiny ? Colors.amber : Colors.white,
                      onTap: () {
                        ref.read(shinyModeProvider.notifier).state = !isShiny;
                      },
                    ),
                    const SizedBox(width: 12),
                    _GlassButton(
                      icon: Icons.volume_up_rounded,
                      color: Colors.white,
                      onTap: _playCry,
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleMenu,
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 0.5).animate(
                          CurvedAnimation(parent: _menuController, curve: Curves.easeInOut),
                        ),
                        child: const _GlassButton(
                          icon: Icons.catching_pokemon,
                          color: Colors.white,
                          onTap: null, // Gesture handled by outer GestureDetector
                        ),
                      ),
                    ),
                  ],
                ),
                SizeTransition(
                  sizeFactor: CurvedAnimation(parent: _menuController, curve: Curves.easeOutCubic),
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildMenuIcon('About', Icons.info_outline),
                              const SizedBox(height: 20),
                              _buildMenuIcon('Stats', Icons.bar_chart),
                              const SizedBox(height: 20),
                              _buildMenuIcon('Moves', Icons.flash_on),
                              const SizedBox(height: 20),
                              _buildMenuIcon('Evolution', Icons.transform),
                              const SizedBox(height: 20),
                              _buildMenuIcon('Defense', Icons.shield_outlined),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Real offline entries (Bulbasaur/Charmander lines) are shown directly;
  /// everything else fetches the official flavor text from the API cache.
  String _resolveDescription(Map<String, dynamic> speciesData) {
    final staticEntry = speciesData['entry'] as String?;
    if (staticEntry != null && staticEntry.isNotEmpty) {
      return staticEntry.replaceAll('\n', ' ');
    }
    // Previously fetched entries resolve instantly from SQLite; only the
    // first-ever visit per Pok\u00e9mon streams from the network here.
    final cachedFlavor = ref.watch(cachedSpeciesProvider(widget.pokemon.id)).asData?.value.flavorText;
    if (cachedFlavor != null && cachedFlavor.isNotEmpty) {
      return cachedFlavor;
    }
    final infoAsync = ref.watch(speciesInfoProvider(widget.pokemon.id));
    return infoAsync.when(
      data: (info) => info.flavorText ?? 'No Pok\u00e9dex entry available.',
      loading: () => '\u2026',
      error: (_, _) => 'No Pok\u00e9dex entry available.',
    );
  }

  Widget _buildMenuIcon(String title, IconData icon) {
    final isSelected = _activeTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = title;
          _toggleMenu();
        });
      },
      child: Icon(
        icon,
        color: isSelected ? Colors.amber : Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildTabContent(Color themeColor, Map<String, dynamic> speciesData) {
    if (_activeTab == 'About') {
      return Column(
        key: const ValueKey('About'),
        children: [
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _resolveDescription(speciesData),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 3-Column Stats Row (Height | Weight | Gender Ratio Ring)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _buildIconText(Icons.height, '${(widget.pokemon.height / 10).toStringAsFixed(1)} m'))),
                  const VerticalDivider(color: Colors.white54, thickness: 1, indent: 0, endIndent: 0),
                  Expanded(child: Center(child: _buildIconText(Icons.fitness_center, '${(widget.pokemon.weight / 10).toStringAsFixed(1)} kg'))),
                  const VerticalDivider(color: Colors.white54, thickness: 1, indent: 0, endIndent: 0),
                  Expanded(child: Center(child: _buildGenderRing(speciesData['genderMale']))),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),

          // Abilities Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.only(top: 36, bottom: 32, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: widget.pokemon.abilities.map((a) {
                      final isHidden = a.isHidden;
                      final rawName = a.ability.name.replaceAll('-', ' ');
                      final abilityName = rawName.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: themeColor.withValues(alpha: 0.8), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isHidden) ...[
                              const Text(
                                'Hidden',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(width: 1, height: 12, color: Colors.white54),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              abilityName,
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Abilities',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ), // Close Padding

          const SizedBox(height: 32),
        ],
      );
    } else if (_activeTab == 'Stats') {
      return _buildGlassCard(
        key: const ValueKey('Stats'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Base Statistics',
                  style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: themeColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(
                      'BST: ${widget.pokemon.stats.fold<int>(0, (p, s) => p + s.baseStat)}',
                      style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            
            // Mode Selector (Base, Min, Max)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: ['Base', 'Min', 'Max'].map((mode) {
                  final isActive = _statsMode == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _statsMode = mode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? themeColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            mode,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // Stat bars
            _buildStatBar('HP', widget.pokemon.stats[0].baseStat, themeColor),
            _buildStatBar('ATK', widget.pokemon.stats[1].baseStat, themeColor),
            _buildStatBar('DEF', widget.pokemon.stats[2].baseStat, themeColor),
            _buildStatBar('SATK', widget.pokemon.stats[3].baseStat, themeColor),
            _buildStatBar('SDEF', widget.pokemon.stats[4].baseStat, themeColor),
            _buildStatBar('SPD', widget.pokemon.stats[5].baseStat, themeColor),
          ],
        ),
      );
    } else if (_activeTab == 'Moves') {
      // Move data is the only section not kept in SQLite; watch it lazily so
      // the rest of the profile paints without waiting on the network.
      final movesAsync = ref.watch(pokemonMovesProvider(widget.pokemon.id));
      if (movesAsync.isLoading) {
        return _buildMovesCard(const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: CircularProgressIndicator(),
          ),
        ));
      }
      if (movesAsync.hasError && (movesAsync.asData?.value ?? const []).isEmpty) {
        return _buildMovesCard(Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
            child: Text(
              "Couldn't load moves.\n${movesAsync.error}",
              textAlign: TextAlign.center,
            ),
          ),
        ));
      }
      final moves = movesAsync.asData?.value ?? const <PokemonMoveSlot>[];

      // Resolve all lists against a single (most recent) version group so
      // levels are not mixed across games and duplicates disappear.
      final latestGroup = _latestVersionGroupName(moves);
      final levelUpMoves = <_MoveEntry>[];
      final tmMoves = <_MoveEntry>[];
      final eggMoves = <_MoveEntry>[];
      final tutorMoves = <_MoveEntry>[];

      for (var slot in moves) {
        final details = slot.versionGroupDetails
            .where((d) => latestGroup == null || d.versionGroup?.name == latestGroup)
            .toList();
        if (details.isEmpty) continue;

        // Keeps the last match so legacy cache rows without version_group tags
        // resolve to their newest detail entry.
        _MoveEntry? entryFor(String method) {
          PokemonMoveVersionDetail? match;
          for (final d in details) {
            if (d.moveLearnMethod.name == method) match = d;
          }
          return match == null ? null : _MoveEntry(slot: slot, level: match.levelLearnedAt);
        }

        final levelEntry = entryFor('level-up');
        if (levelEntry != null) levelUpMoves.add(levelEntry);
        final tmEntry = entryFor('machine');
        if (tmEntry != null) tmMoves.add(tmEntry);
        final eggEntry = entryFor('egg');
        if (eggEntry != null) eggMoves.add(eggEntry);
        final tutorEntry = entryFor('tutor');
        if (tutorEntry != null) tutorMoves.add(tutorEntry);
      }

      List<_MoveEntry> dedupeAndSort(List<_MoveEntry> moves) {
        final byName = <String, _MoveEntry>{};
        for (final e in moves) {
          final existing = byName[e.slot.move.name];
          if (existing == null || e.level < existing.level) byName[e.slot.move.name] = e;
        }
        final list = byName.values.toList()
          ..sort((a, b) {
            final byLevel = a.level.compareTo(b.level);
            return byLevel != 0 ? byLevel : a.slot.move.name.compareTo(b.slot.move.name);
          });
        return list;
      }

      final sortedLevelUp = dedupeAndSort(levelUpMoves);
      final sortedTm = dedupeAndSort(tmMoves);
      final sortedEgg = dedupeAndSort(eggMoves);
      final sortedTutor = dedupeAndSort(tutorMoves);

      List<_MoveEntry> currentMoves;
      bool isLevelUp = false;
      if (_activeMoveTab == 'Level up') { currentMoves = sortedLevelUp; isLevelUp = true; }
      else if (_activeMoveTab == 'TM/HM') { currentMoves = sortedTm; }
      else if (_activeMoveTab == 'Eggs') { currentMoves = sortedEgg; }
      else { currentMoves = sortedTutor; }

      return Container(
        key: const ValueKey('Moves'),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Segmented Move Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: ['Level up', 'TM/HM', 'Eggs', 'Tutor'].map((mode) {
                  final isActive = _activeMoveTab == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeMoveTab = mode),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? themeColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            mode,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black45,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildMoveTable(currentMoves, isLevelUp: isLevelUp),
          ],
        ),
      );
    } else if (_activeTab == 'Defense') {
      return _buildGlassCard(
        key: const ValueKey('Defense'),
        padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 24),
        child: _buildTypeDefenses(widget.pokemon.types),
      );
    } else if (_activeTab == 'Evolution') {
      return EvolutionTab(key: const ValueKey('Evolution'), speciesId: widget.pokemon.speciesId);
    } else {
      return Padding(
        key: ValueKey(_activeTab),
        padding: const EdgeInsets.only(top: 40.0),
        child: Center(
          child: Text(
            '$_activeTab info goes here',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }
  }

  /// Frosted-glass shell shared by every tab card: backdrop blur beneath a
  /// translucent white fill with a hairline highlight border.
  Widget _buildGlassCard({
    Key? key,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            key: key,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Glass container for every state of the Moves tab so the loading spinner
  /// and error card keep the section's geometry.
  Widget _buildMovesCard(Widget child) {
    return _buildGlassCard(
      key: const ValueKey('Moves'),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: child,
    );
  }

  /// Picks the newest game version group present in the move data so every
  /// list shows one coherent generation instead of a cross-game mix.
  String? _latestVersionGroupName(List<PokemonMoveSlot> moves) {
    const order = [
      'red-blue', 'yellow', 'gold-silver', 'crystal', 'ruby-sapphire', 'emerald',
      'firered-leafgreen', 'diamond-pearl', 'platinum', 'heartgold-soulsilver',
      'black-white', 'black-2-white-2', 'x-y', 'omega-ruby-alpha-sapphire',
      'sun-moon', 'ultra-sun-ultra-moon', 'lets-go-pikachu-lets-go-eevee',
      'brilliant-diamond-and-shining-pearl', 'legends-arceus', 'scarlet-violet',
    ];
    String? latest;
    var latestRank = -1;
    for (final slot in moves) {
      for (final d in slot.versionGroupDetails) {
        final rank = order.indexOf(d.versionGroup?.name ?? '');
        if (rank > latestRank) {
          latestRank = rank;
          latest = d.versionGroup!.name;
        }
      }
    }
    return latest;
  }

  Widget _buildMoveTable(List<_MoveEntry> moves, {required bool isLevelUp}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Row(
            children: [
              SizedBox(width: 32, child: Text(isLevelUp ? 'Lv.' : 'TM', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.right)),
              const SizedBox(width: 12),
              const Expanded(flex: 3, child: Text('Move', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54))),
              Expanded(
                flex: 5,
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.center)),
                    SizedBox(width: 4),
                    Expanded(flex: 2, child: Text('Cat.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.center)),
                    SizedBox(width: 36, child: Text('Power', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.right)),
                    SizedBox(width: 36, child: Text('Acc.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54), textAlign: TextAlign.right)),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...moves.map((m) => _MoveRow(
          moveSlot: m.slot,
          methodText: isLevelUp ? (m.level > 0 ? m.level.toString() : '—') : '—'
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderRing(double? maleRatio) {
    if (maleRatio == null || maleRatio < 0) {
      return _buildIconText(Icons.transgender, 'Unknown');
    }

    final femaleRatio = 100.0 - maleRatio;
    String maleText = '${(maleRatio % 1 == 0) ? maleRatio.toInt() : maleRatio.toStringAsFixed(1)}%';
    String femaleText = '${(femaleRatio % 1 == 0) ? femaleRatio.toInt() : femaleRatio.toStringAsFixed(1)}%';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.male, size: 12, color: Colors.blueAccent),
                const SizedBox(width: 4),
                Text(maleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.female, size: 12, color: Colors.pinkAccent),
                const SizedBox(width: 4),
                Text(femaleText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              ],
            ),
          ],
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: maleRatio / 100,
            backgroundColor: Colors.pinkAccent,
            color: Colors.blueAccent,
            strokeWidth: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeDefenses(List<PokemonTypeSlot> types) {
    final typeNames = types.map((t) => t.type.name).toList();
    final effectiveness = TypeChart.getEffectiveness(typeNames);
    
    final weakTo = <String>[];
    final veryWeakTo = <String>[];
    final normalTo = <String>[];
    final resistantTo = <String>[];
    final veryResistantTo = <String>[];
    final immuneTo = <String>[];
    
    effectiveness.forEach((type, multiplier) {
      if (multiplier == 4.0) {
        veryWeakTo.add(type);
      } else if (multiplier == 2.0) {
        weakTo.add(type);
      } else if (multiplier == 1.0) {
        normalTo.add(type);
      } else if (multiplier == 0.5) {
        resistantTo.add(type);
      } else if (multiplier == 0.25) {
        veryResistantTo.add(type);
      } else if (multiplier == 0.0) {
        immuneTo.add(type);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 16),
          child: Text(
            'Type Defenses',
            style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (veryWeakTo.isNotEmpty) _buildDefenseCategory('Very Weak to (4×)', veryWeakTo, Colors.red.shade900, Colors.red.shade50),
        if (weakTo.isNotEmpty) _buildDefenseCategory('Weak to (2×)', weakTo, Colors.red.shade700, Colors.red.shade50),
        if (normalTo.isNotEmpty) _buildDefenseCategory('Normal Damage (1×)', normalTo, Colors.blueGrey.shade700, Colors.blueGrey.shade50),
        if (resistantTo.isNotEmpty) _buildDefenseCategory('Resistant to (½×)', resistantTo, Colors.brown.shade700, Colors.orange.shade50),
        if (veryResistantTo.isNotEmpty) _buildDefenseCategory('Strongly Resistant to (¼×)', veryResistantTo, Colors.green.shade700, Colors.green.shade50),
        if (immuneTo.isNotEmpty) _buildDefenseCategory('No Effect (0×)', immuneTo, Colors.grey.shade700, Colors.grey.shade100),
      ],
    );
  }

  Widget _buildDefenseCategory(String title, List<String> types, Color titleColor, Color bgColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types.map((type) {
              final typeColor = AppColors.getTypeColor(type);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.only(right: 6),
                      child: SvgPicture.asset('assets/types/$type.svg'),
                    ),
                    Text(
                      type[0].toUpperCase() + type.substring(1),
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int baseValue, Color color) {
    int displayValue;
    int maxValue = 255;
    
    if (_statsMode == 'Base') {
      displayValue = baseValue;
    } else if (_statsMode == 'Min') {
      if (label == 'HP') {
        displayValue = (baseValue * 2 + 110);
      } else {
        displayValue = ((baseValue * 2 + 5) * 0.9).toInt();
      }
      maxValue = label == 'HP' ? 714 : 504;
    } else { // Max
      if (label == 'HP') {
        displayValue = (baseValue * 2 + 204);
      } else {
        displayValue = ((baseValue * 2 + 99) * 1.1).toInt();
      }
      maxValue = label == 'HP' ? 714 : 504;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Dashed background line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        20,
                        (index) => Container(
                          width: constraints.maxWidth / 40,
                          height: 2,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                    // The actual stat bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        height: 6,
                        width: constraints.maxWidth * (displayValue / maxValue).clamp(0.0, 1.0),
                        color: color,
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 32,
            child: Text(
              displayValue.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
            ),
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

  const _GlassButton({required this.icon, this.onTap, this.color = Colors.black87});

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
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );

    if (onTap == null) return inner;

    return GestureDetector(
      onTap: onTap,
      child: inner,
    );
  }
}
class _MoveEntry {
  final PokemonMoveSlot slot;
  final int level;

  const _MoveEntry({required this.slot, required this.level});
}

class _MoveRow extends ConsumerWidget {
  final PokemonMoveSlot moveSlot;
  final String methodText;

  const _MoveRow({required this.moveSlot, required this.methodText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moveId = extractIdFromUrl(moveSlot.move.url);
    final moveAsync = moveId == null ? null : ref.watch(moveDetailProvider(moveSlot.move.url));

    final name = moveSlot.move.name.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '').join(' ');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(methodText, style: const TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.right)
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueAccent))
          ),
          Expanded(
            flex: 5,
            child: moveAsync == null
                ? _buildPlaceholderDetails()
                : moveAsync.when(
              data: (move) {
                 return Row(
                   children: [
                      Expanded(flex: 2, child: _buildTypePill(move.type.name)),
                      const SizedBox(width: 4),
                      Expanded(flex: 2, child: _buildCategoryPill(move.damageClass?.name ?? 'status')),
                      SizedBox(width: 36, child: Text(move.power?.toString() ?? '—', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                      SizedBox(width: 36, child: Text(move.accuracy?.toString() ?? '∞', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                   ]
                 );
              },
              loading: () => const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
              ),
              error: (_, _) => const Text('Error', style: TextStyle(fontSize: 10, color: Colors.red)),
            ),
          )
        ],
      )
    );
  }

  Widget _buildPlaceholderDetails() {
    return Row(
      children: const [
        Expanded(flex: 2, child: SizedBox()),
        SizedBox(width: 4),
        Expanded(flex: 2, child: SizedBox()),
        SizedBox(width: 36, child: Text('—', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.black87))),
        SizedBox(width: 36, child: Text('—', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.black87))),
      ]
    );
  }

  Widget _buildTypePill(String type) {
    final color = AppColors.getTypeColor(type);
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 4),
       decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
       child: Center(child: Text(type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildCategoryPill(String cat) {
    Color color;
    if (cat == 'physical') {
      color = Colors.red.shade400;
    } else if (cat == 'special') {
      color = Colors.deepPurple.shade400;
    } else {
      color = Colors.grey.shade500;
    }

    return Container(
       padding: const EdgeInsets.symmetric(vertical: 4),
       decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
       child: Center(child: Text(cat.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
    );
  }
}
