import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType {
  success,
  copy,
  error,
  tap,
  confetti,
}

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _soundEnabled = true;
  bool _initialized = false;

  bool get soundEnabled => _soundEnabled;

  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _initialized = true;
    } catch (e) {
      _soundEnabled = true;
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', enabled);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> toggleSound() async {
    await setSoundEnabled(!_soundEnabled);
  }

  Future<void> play(SoundType type) async {
    if (!_soundEnabled) return;

    // Use haptic feedback for tactile response
    switch (type) {
      case SoundType.success:
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.lightImpact();
        break;
      case SoundType.copy:
        await HapticFeedback.lightImpact();
        break;
      case SoundType.error:
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
        await HapticFeedback.heavyImpact();
        break;
      case SoundType.tap:
        await HapticFeedback.selectionClick();
        break;
      case SoundType.confetti:
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.mediumImpact();
        break;
    }
  }
}
