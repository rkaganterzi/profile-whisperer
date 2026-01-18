enum AchievementType {
  firstAnalysis,
  tenAnalyses,
  fiftyAnalyses,
  nightOwl,
  earlyBird,
  sharingIsCaring,
  collector,
  comparer,
  darkSide,
  vibeExplorer,
}

class Achievement {
  final AchievementType type;
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String? unlockedAt;
  final bool isSecret;

  const Achievement({
    required this.type,
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.unlockedAt,
    this.isSecret = false,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({String? unlockedAt}) {
    return Achievement(
      type: type,
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isSecret: isSecret,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unlockedAt': unlockedAt,
    };
  }

  static const List<Achievement> allAchievements = [
    Achievement(
      type: AchievementType.firstAnalysis,
      id: 'first_analysis',
      title: 'İlk Adım',
      description: 'İlk profil analizini yap',
      emoji: '🎉',
    ),
    Achievement(
      type: AchievementType.tenAnalyses,
      id: 'ten_analyses',
      title: 'Meraklı',
      description: '10 profil analiz et',
      emoji: '🔍',
    ),
    Achievement(
      type: AchievementType.fiftyAnalyses,
      id: 'fifty_analyses',
      title: 'Profil Uzmanı',
      description: '50 profil analiz et',
      emoji: '🏆',
    ),
    Achievement(
      type: AchievementType.nightOwl,
      id: 'night_owl',
      title: 'Gece Kuşu',
      description: 'Gece yarısından sonra analiz yap',
      emoji: '🦉',
    ),
    Achievement(
      type: AchievementType.earlyBird,
      id: 'early_bird',
      title: 'Erken Kalkan',
      description: 'Sabah 6\'dan önce analiz yap',
      emoji: '🐦',
    ),
    Achievement(
      type: AchievementType.sharingIsCaring,
      id: 'sharing_is_caring',
      title: 'Paylaşımcı',
      description: 'Bir sonucu paylaş',
      emoji: '📤',
    ),
    Achievement(
      type: AchievementType.collector,
      id: 'collector',
      title: 'Koleksiyoncu',
      description: '5 farklı vibe tipi gör',
      emoji: '📚',
    ),
    Achievement(
      type: AchievementType.comparer,
      id: 'comparer',
      title: 'Karşılaştırıcı',
      description: 'İlk profil karşılaştırmasını yap',
      emoji: '⚖️',
    ),
    Achievement(
      type: AchievementType.darkSide,
      id: 'dark_side',
      title: 'Karanlık Taraf',
      description: 'Dark mode\'u aç',
      emoji: '🌙',
    ),
    Achievement(
      type: AchievementType.vibeExplorer,
      id: 'vibe_explorer',
      title: 'Vibe Kaşifi',
      description: 'Tüm conversation starter kategorilerini gör',
      emoji: '✨',
      isSecret: true,
    ),
  ];
}
