import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'app_preferences.dart';

const String _prefHapticsKey = 'pref_haptics_enabled';
const String _prefSoundKey = 'pref_sound_enabled';

class FeedbackSettings {
  final bool hapticsEnabled;
  final bool soundEnabled;

  const FeedbackSettings({
    required this.hapticsEnabled,
    required this.soundEnabled,
  });

  FeedbackSettings copyWith({
    bool? hapticsEnabled,
    bool? soundEnabled,
  }) {
    return FeedbackSettings(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class FeedbackHelper {
  static Future<void> setHapticsEnabled(WidgetRef ref, bool enabled) async {
    final current = ref.read(feedbackSettingsProvider);
    ref.read(feedbackSettingsProvider.notifier).state =
        current.copyWith(hapticsEnabled: enabled);
    AppFeedback.updatePreferences(haptics: enabled);
    final prefs = await AppPreferences.getPrefs();
    await prefs.setBool(_prefHapticsKey, enabled);
  }

  static Future<void> setSoundEnabled(WidgetRef ref, bool enabled) async {
    final current = ref.read(feedbackSettingsProvider);
    ref.read(feedbackSettingsProvider.notifier).state =
        current.copyWith(soundEnabled: enabled);
    AppFeedback.updatePreferences(sound: enabled);
    final prefs = await AppPreferences.getPrefs();
    await prefs.setBool(_prefSoundKey, enabled);
  }
}

final feedbackSettingsProvider = StateProvider<FeedbackSettings>((ref) {
  final haptics = AppPreferences.instance?.getBool(_prefHapticsKey) ?? true;
  final sound = AppPreferences.instance?.getBool(_prefSoundKey) ?? false;
  AppFeedback.updatePreferences(haptics: haptics, sound: sound);
  return FeedbackSettings(hapticsEnabled: haptics, soundEnabled: sound);
});

/// Centralized touch and interaction feedback service.
///
/// Respects user preferences for both Vibration/Haptics and Touch Sound.
class AppFeedback {
  static bool _inMemoryHaptics = true;
  static bool _inMemorySound = false;
  static bool _initialized = false;

  static void init() {
    final prefs = AppPreferences.instance;
    if (prefs != null) {
      _inMemoryHaptics = prefs.getBool(_prefHapticsKey) ?? true;
      _inMemorySound = prefs.getBool(_prefSoundKey) ?? false;
      _initialized = true;
    }
  }

  static void updatePreferences({bool? haptics, bool? sound}) {
    if (haptics != null) _inMemoryHaptics = haptics;
    if (sound != null) _inMemorySound = sound;
    _initialized = true;
  }

  static bool get _hapticsEnabled {
    if (!_initialized && AppPreferences.instance != null) {
      init();
    }
    return _inMemoryHaptics;
  }

  static bool get _soundEnabled {
    if (!_initialized && AppPreferences.instance != null) {
      init();
    }
    return _inMemorySound;
  }

  /// Standard button/tile selection click.
  static void selectionClick() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Light tactile pulse for subtle interactions (switches, tabs, toggles).
  static void lightImpact() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Medium tactile pulse for confirms, saves, or item select.
  static void mediumImpact() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Heavy tactile pulse for long-presses, actions, or alerts.
  static void heavyImpact() {
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}
