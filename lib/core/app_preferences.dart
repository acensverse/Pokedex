import 'package:shared_preferences/shared_preferences.dart';

/// Centralized access to SharedPreferences.
///
/// Initialized once in `main()` before `runApp()` so that synchronous
/// provider initializers (such as default Pokédex mode, theme, and layout)
/// have immediate access to persisted user preferences from the very first frame.
class AppPreferences {
  /// The cached [SharedPreferences] instance, non-null after [init].
  static SharedPreferences? instance;

  /// Loads and caches [SharedPreferences]. Safe to call multiple times.
  static Future<SharedPreferences> init() async {
    instance = await SharedPreferences.getInstance();
    return instance!;
  }

  /// Returns the cached instance, or fetches it if not yet loaded.
  static Future<SharedPreferences> getPrefs() async {
    instance ??= await SharedPreferences.getInstance();
    return instance!;
  }
}
