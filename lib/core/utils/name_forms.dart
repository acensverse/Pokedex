/// Normalizes a name for lookups: lowercase, fold accents (basic Latin +
/// common accented chars), drop every non-alphanumeric character. Used for
/// matching item names and ability slugs across different data sources.
String normalizeKey(String raw) => raw
    .toLowerCase()
    .replaceAll(RegExp(r'[àáâãäå]'), 'a')
    .replaceAll(RegExp(r'[èéêë]'), 'e')
    .replaceAll(RegExp(r'[ìíîï]'), 'i')
    .replaceAll(RegExp(r'[òóôõö]'), 'o')
    .replaceAll(RegExp(r'[ùúûü]'), 'u')
    .replaceAll(RegExp(r'[ç]'), 'c')
    .replaceAll(RegExp(r'[ñ]'), 'n')
    .replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Converts a display name to a PokeAPI-style slug: "Thermal Exchange" ->
/// "thermal-exchange".
String toSlug(String raw) => raw
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
