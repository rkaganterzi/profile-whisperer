import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/analysis_history.dart';
import '../models/analysis_result.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _historyKey = 'analysis_history';
  static const int _maxHistoryItems = 50;

  List<AnalysisHistoryItem> _history = [];
  bool _isLoading = false;

  List<AnalysisHistoryItem> get history => _history;
  bool get isLoading => _isLoading;
  int get totalAnalyses => _history.length;

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
      final vibeType = item.result.vibeType;
      stats[vibeType] = (stats[vibeType] ?? 0) + 1;
    }
    return stats;
  }

  String? getMostCommonVibeType() {
    final stats = getVibeTypeStats();
    if (stats.isEmpty) return null;
    return stats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}
