/// Centralized premium feature limits and utilities
class PremiumFeatures {
  // Conversation Starters
  static const int freeStarters = 1;
  static const int premiumStarters = 5;

  // History limits
  static const int freeHistory = 5;
  static const int premiumHistory = 50;

  // Daily analysis limit
  static const int freeDailyLimit = 2;

  // Streak bonuses
  static const int day3BonusCredits = 1;
  static const int day7BonusDeepAnalysis = 1;

  // Share bonus
  static const int shareBonusCredits = 1;

  /// Get the number of conversation starters to show
  static int getStarterLimit(bool isPremium) {
    return isPremium ? premiumStarters : freeStarters;
  }

  /// Get the history limit
  static int getHistoryLimit(bool isPremium) {
    return isPremium ? premiumHistory : freeHistory;
  }

  /// Get streak multiplier for bonuses (Premium users get 2x)
  static int getStreakMultiplier(bool isPremium) {
    return isPremium ? 2 : 1;
  }

  /// Check if a starter index is locked for free users
  static bool isStarterLocked(int index, bool isPremium) {
    if (isPremium) return false;
    return index >= freeStarters;
  }

  /// Check if flags should be blurred for free users
  static bool shouldBlurFlags(bool isPremium) {
    return !isPremium;
  }

  /// Check if history item is accessible
  static bool isHistoryAccessible(int index, bool isPremium) {
    final limit = getHistoryLimit(isPremium);
    return index < limit;
  }
}
