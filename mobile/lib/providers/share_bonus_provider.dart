import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/premium_features.dart';

class ShareBonusProvider extends ChangeNotifier {
  static const String _sharedResultsKey = 'shared_result_ids';

  Set<String> _sharedResultIds = {};
  bool _isLoading = false;

  Set<String> get sharedResultIds => _sharedResultIds;
  bool get isLoading => _isLoading;

  ShareBonusProvider() {
    _loadSharedResults();
  }

  Future<void> _loadSharedResults() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final sharedJson = prefs.getString(_sharedResultsKey);

      if (sharedJson != null) {
        final List<dynamic> list = jsonDecode(sharedJson);
        _sharedResultIds = list.map((e) => e.toString()).toSet();
      }
    } catch (e) {
      debugPrint('Error loading shared results: $e');
      _sharedResultIds = {};
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveSharedResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _sharedResultsKey,
        jsonEncode(_sharedResultIds.toList()),
      );
    } catch (e) {
      debugPrint('Error saving shared results: $e');
    }
  }

  /// Check if bonus has already been claimed for this result
  bool hasClaimedBonus(String resultId) {
    return _sharedResultIds.contains(resultId);
  }

  /// Claim share bonus for a result
  /// Returns the number of credits awarded (0 if already claimed)
  Future<int> claimShareBonus(String resultId) async {
    if (hasClaimedBonus(resultId)) {
      return 0;
    }

    _sharedResultIds.add(resultId);
    await _saveSharedResults();
    notifyListeners();

    return PremiumFeatures.shareBonusCredits;
  }

  /// Get total shares count
  int get totalShares => _sharedResultIds.length;

  /// Clear all shared results (for testing)
  Future<void> clearSharedResults() async {
    _sharedResultIds.clear();
    await _saveSharedResults();
    notifyListeners();
  }
}
