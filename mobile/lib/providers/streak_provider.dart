import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_streak.dart';
import '../utils/premium_features.dart';

class StreakProvider extends ChangeNotifier {
  static const String _streakKey = 'user_streak';

  UserStreak _streak = UserStreak();
  bool _isLoading = false;
  bool _showBonusDialog = false;
  int _pendingBonusDay = 0;

  UserStreak get streak => _streak;
  bool get isLoading => _isLoading;
  bool get showBonusDialog => _showBonusDialog;
  int get pendingBonusDay => _pendingBonusDay;

  StreakProvider() {
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final streakJson = prefs.getString(_streakKey);

      if (streakJson != null) {
        _streak = UserStreak.fromJson(jsonDecode(streakJson));
      }
    } catch (e) {
      debugPrint('Error loading streak: $e');
      _streak = UserStreak();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_streakKey, jsonEncode(_streak.toJson()));
    } catch (e) {
      debugPrint('Error saving streak: $e');
    }
  }

  /// Call this when the app opens to check and update streak
  Future<void> checkAndUpdateStreak() async {
    await _loadStreak();

    if (_streak.isNewDay) {
      if (_streak.isStreakActive) {
        // Continue streak
        _streak = _streak.copyWith(
          currentStreak: _streak.currentStreak + 1,
          lastLoginDate: DateTime.now(),
        );
      } else {
        // Streak broken - reset
        _streak = UserStreak(
          currentStreak: 1,
          lastLoginDate: DateTime.now(),
          hasClaimedDay3Bonus: false,
          hasClaimedDay7Bonus: false,
        );
      }
      await _saveStreak();
      notifyListeners();
    }

    // Check if bonus dialog should be shown
    if (_streak.canClaimDay3Bonus) {
      _pendingBonusDay = 3;
      _showBonusDialog = true;
      notifyListeners();
    } else if (_streak.canClaimDay7Bonus) {
      _pendingBonusDay = 7;
      _showBonusDialog = true;
      notifyListeners();
    }
  }

  /// Claim day 3 bonus (+1 analysis credit)
  Future<int> claimDay3Bonus(bool isPremium) async {
    if (!_streak.canClaimDay3Bonus) return 0;

    final multiplier = PremiumFeatures.getStreakMultiplier(isPremium);
    final credits = PremiumFeatures.day3BonusCredits * multiplier;

    _streak = _streak.copyWith(hasClaimedDay3Bonus: true);
    _showBonusDialog = false;
    _pendingBonusDay = 0;
    await _saveStreak();
    notifyListeners();

    return credits;
  }

  /// Claim day 7 bonus (+1 deep analysis)
  Future<int> claimDay7Bonus(bool isPremium) async {
    if (!_streak.canClaimDay7Bonus) return 0;

    final multiplier = PremiumFeatures.getStreakMultiplier(isPremium);
    final credits = PremiumFeatures.day7BonusDeepAnalysis * multiplier;

    // Reset bonuses for next cycle
    _streak = _streak.copyWith(
      hasClaimedDay3Bonus: false,
      hasClaimedDay7Bonus: true,
    );
    _showBonusDialog = false;
    _pendingBonusDay = 0;
    await _saveStreak();
    notifyListeners();

    return credits;
  }

  /// Dismiss the bonus dialog without claiming
  void dismissBonusDialog() {
    _showBonusDialog = false;
    notifyListeners();
  }

  /// Reset streak (for testing)
  Future<void> resetStreak() async {
    _streak = UserStreak();
    await _saveStreak();
    notifyListeners();
  }
}
