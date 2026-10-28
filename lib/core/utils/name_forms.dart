import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Data-driven Pokémon name resolution.
///
/// Every form word, punctuation name and Showdown cry-file rule lives in
/// assets/name_forms.json (generated from the seed + verified cry probes by
/// tool/build_name_forms.js). When a new Pokémon or form appears in the data,
/// extend the JSON — never this class. Unknown words fall back to generic
/// rules, so future forms display and cry correctly with zero code changes.
class NameForms {
  NameForms._();

  static Map<String, dynamic>? _rules;
  static Map<String, Map<String, dynamic>>? _speciesFallback;
  static List<String>? _displayPrefixes;
  static Set<String>? _headWords;
  static Set<String>? _dropTokenSlugs;

  static bool get isLoaded => _rules != null;

  /// Loads the rule assets. Call once during bootstrap (main) and in tests;
  /// afterwards all resolution methods are synchronous.
  static Future<void> load() async {
    if (_rules != null) return;
    try {
      _rules =
          jsonDecode(await rootBundle.loadString('assets/name_forms.json'))
              as Map<String, dynamic>;
    } catch (_) {
      _rules =
          const {}; // generic rules still function without the asset file
    }
    try {
      final raw = jsonDecode(
        await rootBundle.loadString('assets/species_fallback.json'),
      ) as Map<String, dynamic>;
      _speciesFallback = raw.map(
        (k, v) => MapEntry(k, v as Map<String, dynamic>),
      );
    } catch (_) {
      _speciesFallback = const {};
    }
    // Derived indexes.
    _headWords = _displayForms.keys.map((h) => h.toLowerCase()).toSet();
    final dropTokens = <String>{};
    (_slugForms).forEach((token, rule) {
      if (rule is! Map) return;
      final display = rule['display'];
      if (display is! String) return;
      final headRule = _displayForms[display];
      if (headRule is Map && headRule['cry'] == 'drop') dropTokens.add(token);
    });
    _dropTokenSlugs = dropTokens;
  }

  // ---- lookup helpers --------------------------------------------------------

  static Map<String, dynamic> get _displayForms =>
      (_rules?['displayForms'] as Map<String, dynamic>?) ?? const {};

  static Map<String, dynamic> get _slugForms =>
      (_rules?['slugForms'] as Map<String, dynamic>?) ?? const {};

  static Map<String, dynamic> get _cryFileOverrides =>
      (_rules?['cryFileOverrides'] as Map<String, dynamic>?) ?? const {};

  static Map<String, dynamic> get _punctuationNames =>
      (_rules?['punctuationNames'] as Map<String, dynamic>?) ?? const {};

  static Map<String, dynamic> get _baseNameFixups =>
      (_rules?['baseNameFixups'] as Map<String, dynamic>?) ?? const {};

  static Map<String, dynamic> get _displayAliases =>
      (_rules?['displayAliases'] as Map<String, dynamic>?) ?? const {};

  /// Display head words sorted longest-first (cached), so "Galarian Zen Mode"
  /// wins over "Galarian" when matching.
  static List<String> get _sortedDisplayPrefixes {
    final cached = _displayPrefixes;
    if (cached != null) return cached;
    final list = _displayForms.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    return _displayPrefixes = list;
  }

  /// Lowercases, folds accents to ASCII and maps every non-alphanumeric run
  /// to a single hyphen, so "Mr. Mime" -> "mr-mime", "farfetch'd" ->
  /// "farfetchd" and "Flabébé" -> "flabebe".
  static String _normalizeSlug(String raw) => _foldAccents(raw)
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  /// Maps accented characters to their ASCII base letter.
  static String _foldAccents(String raw) {
    const accents = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
      'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ì': 'i', 'í': 'i',
      'î': 'i', 'ï': 'i', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o',
      'ö': 'o', 'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ñ': 'n', 'ç': 'c',
    };
    return raw.toLowerCase().replaceAllMapped(
      RegExp('[àáâãäåèéêëìíîïòóôõöùúûüñç]'),
      (m) => accents[m[0]] ?? m[0]!,
    );
  }

  // ---- slug / name -> display --------------------------------------------------

  /// Converts a PokeAPI-style slug (or an already display-style name) to the
  /// display name, e.g. "charizard-mega-x" -> "Mega Charizard X".
  /// Names that already contain uppercase letters pass through untouched.
  static String toDisplay(String raw) {
    if (raw.isEmpty) return raw;
    // Seed and DB names are display-style; slugs are always lowercase.
    if (raw != raw.toLowerCase()) return raw;
    final normalized = _normalizeSlug(raw);

    final full = _punctuationNames[normalized];
    if (full is String) return full;

    final alias = _displayAliases[normalized];
    if (alias is String) return alias;

    // Whole-slug curated entries ("pikachu-rock-star" -> "Pikachu Rock Star").
    final whole = _slugForms[normalized];
    if (whole is Map && whole['whole'] == true) {
      final display = whole['display'];
      if (display is String) return display;
    }

    final parts = normalized.split('-');
    // Longest suffix-token match first ("rapid-strike" beats "strike").
    for (var take = parts.length - 1; take >= 1; take--) {
      final token = parts.sublist(take).join('-');
      final rule = _slugForms[token];
      if (rule is Map) {
        final base = _titleCaseBase(parts.sublist(0, take));
        final display = (rule['display'] as String?) ?? _titleCaseBase([token]);
        final letterAfter = rule['letterAfter'] as String?;
        if (letterAfter != null) return '$display $base $letterAfter';
        return '$display $base'.trim();
      }
    }
    return _titleCaseBase(parts);
  }

  /// Title-cases the base tokens, applying the punctuation fixups dictionary
  /// (data-driven; handles "ho oh" -> "Ho-Oh", "kommo o" -> "Kommo-o", etc.).
  static String _titleCaseBase(List<String> tokens) {
    final joined = tokens.join(' ');
    final fixup = _baseNameFixups[joined];
    if (fixup is String) return fixup;
    final punct = _punctuationNames[_normalizeSlug(joined)];
    if (punct is String) return punct;
    return tokens
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ---- display / slug -> Showdown cry file id ---------------------------------

  /// Resolves the Showdown cry file id for a display name or slug.
  /// Showdown's cry folder is irregular: megas, primals, crowned and a
  /// handful of form cries exist as "{base}-{token}"; most other forms have
  /// no file, so the base cry is the correct fallback (encoded as
  /// `cry: "drop"` in the rules data).
  static String toCryId(String raw) {
    final name = raw.trim();
    if (name.isEmpty) return '';
    final lower = name.toLowerCase();

    // 1. Exact overrides (data): "galarian slowpoke" -> "slowpoke-galar".
    final override = _cryFileOverrides[lower];
    if (override is String) return override;

    if (name.contains(' ')) {
      // 2. Display path: full punctuation names first ("Mr. Mime" -> mrmime).
      final normalized = _normalizeSlug(lower);
      final punct = _punctuationNames[normalized];
      if (punct is String) return _sanitize(punct);
      final alias = _displayAliases[normalized];
      if (alias is String) return _sanitize(alias);

      // 3. Longest known form head wins ("Galarian Zen Mode Darmanitan").
      for (final head in _sortedDisplayPrefixes) {
        final h = head.toLowerCase();
        if (!lower.startsWith('$h ')) continue;
        final rule = _displayForms[head];
        if (rule is! Map) continue;
        final restWords = lower.substring(h.length).trim().split(' ')
          ..removeWhere((w) => w.isEmpty);
        if (restWords.isEmpty) continue;
        // Lettered megas: "Mega Charizard X" -> charizard-megax.
        if (rule['letterTrailing'] == true &&
            restWords.last.length == 1 &&
            'xyz'.contains(restWords.last)) {
          final letter = restWords.last;
          restWords.removeLast();
          return '${_sanitize(restWords.join(' '))}-mega$letter';
        }
        // Compound forms: strip trailing form words ("Mega Meowstic Male"
        // -> base "meowstic"), then apply the head's cry rule.
        while (restWords.length > 1 && _headWords!.contains(restWords.last)) {
          restWords.removeLast();
        }
        final base = _sanitize(restWords.join(' '));
        if (rule['cry'] == 'drop') return base;
        final token = rule['token'] as String? ?? '';
        return token.isEmpty ? base : '$base-$token';
      }
      // 4. Unknown display name: drop trailing parentheticals
      // ("Pikachu (Original Cap)" -> pikachu), else sanitize the whole name.
      final noParen = name
          .replaceFirst(RegExp(r'\s*\([^)]*\)\s*$'), '')
          .trim();
      return _sanitize(noParen.isNotEmpty ? noParen : name);
    }

    // 5. Slug path.
    final normalized = _normalizeSlug(lower);
    final punct = _punctuationNames[normalized];
    if (punct is String) return _sanitize(punct);

    final whole = _slugForms[normalized];
    if (whole is Map && whole['whole'] == true) {
      final display = whole['display'];
      if (display is String) {
        final cry = _cryFileOverrides[display.toLowerCase()];
        if (cry is String) return cry;
        return _sanitize(display);
      }
    }

    final parts = normalized.split('-');
    for (var take = parts.length - 1; take >= 1; take--) {
      final token = parts.sublist(take).join('-');
      final rule = _slugForms[token];
      if (rule is! Map) continue;
      final baseParts = parts.sublist(0, take);
      final letterAfter = rule['letterAfter'] as String?;
      if (letterAfter != null) {
        return '${_sanitize(baseParts.join('-'))}-mega${letterAfter.toLowerCase()}';
      }
      // Strip residual form tokens ("toxtricity-amped-gmax" -> "toxtricity").
      var remaining = List<String>.of(baseParts);
      while (remaining.length > 1) {
        var stripped = false;
        for (var k = remaining.length - 1; k >= 1; k--) {
          final candidate = remaining.sublist(remaining.length - k).join('-');
          if (_dropTokenSlugs!.contains(candidate)) {
            remaining.removeRange(remaining.length - k, remaining.length);
            stripped = true;
            break;
          }
        }
        if (!stripped) break;
      }
      final base = _sanitize(remaining.join('-'));
      final display = rule['display'];
      final displayRule = display is String ? _displayForms[display] : null;
      if (displayRule is Map && displayRule['cry'] == 'drop') return base;
      final headToken = displayRule is Map
          ? displayRule['token'] as String? ?? token
          : token;
      return headToken.isEmpty ? base : '$base-$headToken';
    }
    return _sanitize(normalized);
  }

  /// Last-resort cry id (used as the retry fallback after the primary fails):
  /// the sanitized final word, matching the legacy behavior.
  static String lastResortCryId(String raw) =>
      _sanitize(raw.trim().split(' ').last);

  /// Lowercases, strips accents and removes every non-alphanumeric character
  /// (Showdown cry files are concatenated lowercase ids, e.g. "mrmime").
  static String _sanitize(String raw) =>
      _foldAccents(raw).replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Public normalization key: lowercase, accents folded, non-alphanumerics
  /// removed. Used for cross-dataset name matching (e.g. matching
  /// champsmeta item names against the seed's display names).
  static String normalizeKey(String raw) => _sanitize(raw);

  // ---- species fallback data (moved out of Dart hardcode) ----------------------

  /// Offline species metadata fallback (category, entry, gender ratio, ...).
  /// Returns generic empty data for unknown ids so the UI can fetch real data
  /// from the API instead of showing stale guesses.
  static Map<String, dynamic> speciesFallback(int id) {
    final map = _speciesFallback;
    final data = map?[id.toString()];
    if (data != null) return Map<String, dynamic>.from(data);
    return const {
      'category': '',
      'entry': '',
      'genderMale': 50.0,
      'genderFemale': 50.0,
      'eggGroups': ['Field'],
      'growthRate': 'Medium',
      'catchRate': '45 (17.6% - Pokeball - Full HP)',
      'evYield': '1 HP',
      'baseHappiness': '70 (Normal)',
    };
  }
}
