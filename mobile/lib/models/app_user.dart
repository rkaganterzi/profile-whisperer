class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final int credits;
  final bool isPremium;
  final DateTime? premiumUntil;
  final DateTime createdAt;
  final DateTime lastCreditRefresh;
  final int totalAnalyses;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.credits = 5,
    this.isPremium = false,
    this.premiumUntil,
    required this.createdAt,
    required this.lastCreditRefresh,
    this.totalAnalyses = 0,
  });

  bool get canAnalyze => credits > 0 || isPremium;

  bool get needsCreditRefresh {
    final now = DateTime.now();
    final lastRefresh = lastCreditRefresh;
    return now.difference(lastRefresh).inHours >= 24;
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    int? credits,
    bool? isPremium,
    DateTime? premiumUntil,
    DateTime? createdAt,
    DateTime? lastCreditRefresh,
    int? totalAnalyses,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      credits: credits ?? this.credits,
      isPremium: isPremium ?? this.isPremium,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      createdAt: createdAt ?? this.createdAt,
      lastCreditRefresh: lastCreditRefresh ?? this.lastCreditRefresh,
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'credits': credits,
      'isPremium': isPremium,
      'premiumUntil': premiumUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastCreditRefresh': lastCreditRefresh.toIso8601String(),
      'totalAnalyses': totalAnalyses,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      credits: json['credits'] ?? 5,
      isPremium: json['isPremium'] ?? false,
      premiumUntil: json['premiumUntil'] != null
          ? DateTime.parse(json['premiumUntil'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      lastCreditRefresh: json['lastCreditRefresh'] != null
          ? DateTime.parse(json['lastCreditRefresh'])
          : DateTime.now(),
      totalAnalyses: json['totalAnalyses'] ?? 0,
    );
  }

  factory AppUser.newUser(String uid, {String? email, String? displayName, String? photoUrl}) {
    final now = DateTime.now();
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      credits: 10, // Welcome bonus
      isPremium: false,
      createdAt: now,
      lastCreditRefresh: now,
      totalAnalyses: 0,
    );
  }
}

class CreditPackage {
  final String id;
  final String name;
  final int credits;
  final double price;
  final String? badge;

  const CreditPackage({
    required this.id,
    required this.name,
    required this.credits,
    required this.price,
    this.badge,
  });

  static const List<CreditPackage> packages = [
    CreditPackage(
      id: 'credits_25',
      name: 'Başlangıç',
      credits: 25,
      price: 19,
    ),
    CreditPackage(
      id: 'credits_75',
      name: 'Popüler',
      credits: 75,
      price: 49,
      badge: 'En Çok Satan',
    ),
    CreditPackage(
      id: 'credits_200',
      name: 'Mega',
      credits: 200,
      price: 99,
      badge: 'En Değerli',
    ),
  ];
}

class SubscriptionPlan {
  final String id;
  final String name;
  final double monthlyPrice;
  final double? yearlyPrice;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    this.yearlyPrice,
    required this.features,
  });

  static const premium = SubscriptionPlan(
    id: 'premium',
    name: 'Premium',
    monthlyPrice: 29,
    yearlyPrice: 249,
    features: [
      'Derin Profil Analizi (6-9 post)',
      'Reklamsız deneyim',
      '50 kredi/ay bonus',
      'Profil karşılaştırma',
      'Öncelikli analiz',
      'Özel rozetler',
      'Detaylı raporlar',
    ],
  );
}
