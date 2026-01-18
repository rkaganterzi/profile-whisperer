/// Model for tracking user login streaks and bonuses
class UserStreak {
  final int currentStreak;
  final DateTime lastLoginDate;
  final bool hasClaimedDay3Bonus;
  final bool hasClaimedDay7Bonus;

  UserStreak({
    this.currentStreak = 0,
    DateTime? lastLoginDate,
    this.hasClaimedDay3Bonus = false,
    this.hasClaimedDay7Bonus = false,
  }) : lastLoginDate = lastLoginDate ?? DateTime.now();

  /// Check if the streak is still active (user logged in today or yesterday)
  bool get isStreakActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    final difference = today.difference(lastLogin).inDays;
    return difference <= 1;
  }

  /// Check if this is a new day (different from last login day)
  bool get isNewDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );
    return today.isAfter(lastLogin);
  }

  /// Check if day 3 bonus is available to claim
  bool get canClaimDay3Bonus {
    return currentStreak >= 3 && !hasClaimedDay3Bonus;
  }

  /// Check if day 7 bonus is available to claim
  bool get canClaimDay7Bonus {
    return currentStreak >= 7 && !hasClaimedDay7Bonus;
  }

  /// Check if any bonus is available
  bool get hasAvailableBonus => canClaimDay3Bonus || canClaimDay7Bonus;

  /// Get the next milestone day
  int get nextMilestone {
    if (currentStreak < 3) return 3;
    if (currentStreak < 7) return 7;
    return 7; // After day 7, cycle resets
  }

  /// Get days until next milestone
  int get daysUntilNextMilestone {
    return nextMilestone - currentStreak;
  }

  UserStreak copyWith({
    int? currentStreak,
    DateTime? lastLoginDate,
    bool? hasClaimedDay3Bonus,
    bool? hasClaimedDay7Bonus,
  }) {
    return UserStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      hasClaimedDay3Bonus: hasClaimedDay3Bonus ?? this.hasClaimedDay3Bonus,
      hasClaimedDay7Bonus: hasClaimedDay7Bonus ?? this.hasClaimedDay7Bonus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'lastLoginDate': lastLoginDate.toIso8601String(),
      'hasClaimedDay3Bonus': hasClaimedDay3Bonus,
      'hasClaimedDay7Bonus': hasClaimedDay7Bonus,
    };
  }

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      currentStreak: json['currentStreak'] ?? 0,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'])
          : DateTime.now(),
      hasClaimedDay3Bonus: json['hasClaimedDay3Bonus'] ?? false,
      hasClaimedDay7Bonus: json['hasClaimedDay7Bonus'] ?? false,
    );
  }
}
