import 'package:shared_preferences/shared_preferences.dart';

/// Centralized access to SharedPreferences.
///
/// Initialized once in `main()` before `runApp()` so that synchronous
/// provider initializers (such as default Pokédex mode, theme, and layout)
/// have immediate access to persisted user preferences from the very first frame.
class AppPreferences {
  static SharedPreferences? _instance;

  /// The cached [SharedPreferences] instance, non-null after [init].
  static SharedPreferences? get instance => _instance;

  /// Sets or replaces the cached instance (useful for unit tests with mocks).
  static set instance(SharedPreferences? prefs) => _instance = prefs;

  /// Loads and caches [SharedPreferences]. Safe to call multiple times.
  static Future<SharedPreferences> init() async {
    _instance = await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Returns the cached instance, or fetches it if not yet loaded.
  static Future<SharedPreferences> getPrefs() async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }
}
