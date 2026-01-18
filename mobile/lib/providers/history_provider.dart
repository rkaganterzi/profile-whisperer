import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_history.dart';
import '../models/analysis_result.dart';
import '../models/deep_analysis_result.dart';
import '../utils/premium_features.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _historyKey = 'analysis_history';
  static const int _maxHistoryItems = 50;

  List<AnalysisHistoryItem> _history = [];
  bool _isLoading = false;

  List<AnalysisHistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  int get totalAnalyses => _history.length;

  /// Get filtered history based on premium status
  List<AnalysisHistoryItem> getVisibleHistory(bool isPremium) {
    final limit = PremiumFeatures.getHistoryLimit(isPremium);
    if (_history.length <= limit) return _history;
    return _history.sublist(0, limit);
  }

  /// Get count of hidden history items for free users
  int getHiddenCount(bool isPremium) {
    final limit = PremiumFeatures.getHistoryLimit(isPremium);
    if (_history.length <= limit) return 0;
    return _history.length - limit;
  }

  /// Check if user has more history than their limit allows
  bool hasHiddenHistory(bool isPremium) {
    return getHiddenCount(isPremium) > 0;
  }

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      _history = historyJson
          .map((json) => AnalysisHistoryItem.fromJsonString(json))
          .toList();

      // Sort by date (newest first)
      _history.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    } catch (e) {
      debugPrint('Error loading history: $e');
      _history = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToHistory({
    required AnalysisResult result,
    String? instagramUsername,
    String? imageSource,
  }) async {
    final item = AnalysisHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      analyzedAt: DateTime.now(),
      instagramUsername: instagramUsername,
      imageSource: imageSource,
      result: result,
      isDeepAnalysis: false,
    );

    _history.insert(0, item);

    // Limit history size
    if (_history.length > _maxHistoryItems) {
      _history = _history.sublist(0, _maxHistoryItems);
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> addDeepToHistory({
    required DeepAnalysisResult result,
    String? instagramUsername,
  }) async {
    final item = AnalysisHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      analyzedAt: DateTime.now(),
      instagramUsername: instagramUsername,
      imageSource: 'instagram_deep',
      deepResult: result,
      isDeepAnalysis: true,
    );

    _history.insert(0, item);

    // Limit history size
    if (_history.length > _maxHistoryItems) {
      _history = _history.sublist(0, _maxHistoryItems);
    }

    await _saveHistory();
    notifyListeners();
  }

  Future<void> removeFromHistory(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history.map((item) => item.toJsonString()).toList();
      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  // Stats
  Map<String, int> getVibeTypeStats() {
    final stats = <String, int>{};
    for (final item in _history) {
      final vibeType = item.result?.vibeType;
      if (vibeType != null) {
        stats[vibeType] = (stats[vibeType] ?? 0) + 1;
      }
    }
    return stats;
  }

  String? getMostCommonVibeType() {
    final stats = getVibeTypeStats();
    if (stats.isEmpty) return null;
    return stats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
