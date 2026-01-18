import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';

class AchievementProvider extends ChangeNotifier {
  static const String _achievementsKey = 'unlocked_achievements';

  Map<String, String> _unlockedAchievements = {}; // id -> unlockedAt
  Achievement? _lastUnlockedAchievement;

  List<Achievement> get allAchievements {
    return Achievement.allAchievements.map((a) {
      final unlockedAt = _unlockedAchievements[a.id];
      return a.copyWith(unlockedAt: unlockedAt);
    }).toList();
  }

  List<Achievement> get unlockedAchievements {
    return allAchievements.where((a) => a.isUnlocked).toList();
  }

  int get totalAchievements => Achievement.allAchievements.length;
  int get unlockedCount => _unlockedAchievements.length;

  Achievement? get lastUnlockedAchievement => _lastUnlockedAchievement;

  void clearLastUnlocked() {
    _lastUnlockedAchievement = null;
    notifyListeners();
  }

  AchievementProvider() {
    loadAchievements();
  }

  Future<void> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_achievementsKey);
      if (json != null) {
        _unlockedAchievements = Map<String, String>.from(jsonDecode(json));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    }
  }

  Future<void> _saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_achievementsKey, jsonEncode(_unlockedAchievements));
    } catch (e) {
      debugPrint('Error saving achievements: $e');
    }
  }

  Future<bool> unlock(AchievementType type) async {
    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.type == type,
    );

    if (_unlockedAchievements.containsKey(achievement.id)) {
      return false; // Already unlocked
    }

    _unlockedAchievements[achievement.id] = DateTime.now().toIso8601String();
    _lastUnlockedAchievement = achievement.copyWith(
      unlockedAt: _unlockedAchievements[achievement.id],
    );
    await _saveAchievements();
    notifyListeners();
    return true;
  }

  bool isUnlocked(AchievementType type) {
    final achievement = Achievement.allAchievements.firstWhere(
      (a) => a.type == type,
    );
    return _unlockedAchievements.containsKey(achievement.id);
  }

  // Check for analysis-based achievements
  Future<void> checkAnalysisAchievements(int totalAnalyses) async {
    if (totalAnalyses >= 1) {
      await unlock(AchievementType.firstAnalysis);
    }
    if (totalAnalyses >= 10) {
      await unlock(AchievementType.tenAnalyses);
    }
    if (totalAnalyses >= 50) {
      await unlock(AchievementType.fiftyAnalyses);
    }

    // Time-based achievements
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 6) {
      await unlock(AchievementType.nightOwl);
    }
    if (hour >= 5 && hour < 7) {
      await unlock(AchievementType.earlyBird);
    }
  }

  // Check for vibe type collector achievement
  Future<void> checkVibeCollector(Set<String> uniqueVibeTypes) async {
    if (uniqueVibeTypes.length >= 5) {
      await unlock(AchievementType.collector);
    }
  }
}
