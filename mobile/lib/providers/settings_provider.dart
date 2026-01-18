import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/analytics_service.dart';

/// Provider for app settings including roast mode preference
class SettingsProvider extends ChangeNotifier {
  static const String _roastModeKey = 'roast_mode_enabled';

  bool _roastModeEnabled = true; // Default to true (roast mode on)
  bool _isInitialized = false;

  bool get roastModeEnabled => _roastModeEnabled;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _roastModeEnabled = prefs.getBool(_roastModeKey) ?? true;
      _isInitialized = true;
      notifyListeners();
      debugPrint('SettingsProvider: Loaded roast mode = $_roastModeEnabled');
    } catch (e) {
      debugPrint('SettingsProvider: Failed to load settings - $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Toggle roast mode on/off
  Future<void> setRoastMode(bool enabled) async {
    if (_roastModeEnabled == enabled) return;

    _roastModeEnabled = enabled;
    notifyListeners();

    // Log analytics
    AnalyticsService().logRoastModeToggled(enabled: enabled);

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_roastModeKey, enabled);
      debugPrint('SettingsProvider: Saved roast mode = $enabled');
    } catch (e) {
      debugPrint('SettingsProvider: Failed to save roast mode - $e');
    }
  }

  /// Toggle roast mode (convenience method)
  Future<void> toggleRoastMode() async {
    await setRoastMode(!_roastModeEnabled);
  }
}
