class DeepAnalysisResult {
  final String id;
  final String profileArchetype;
  final String archetypeEmoji;
  final List<String> contentPatterns;
  final String engagementAnalysis;
  final double engagementRate;
  final String deepRoast;
  final String relationshipPrediction;
  final List<String> warningSigns;
  final DateTime createdAt;

  DeepAnalysisResult({
    required this.id,
    required this.profileArchetype,
    required this.archetypeEmoji,
    required this.contentPatterns,
    required this.engagementAnalysis,
    required this.engagementRate,
    required this.deepRoast,
    required this.relationshipPrediction,
    required this.warningSigns,
    required this.createdAt,
  });

  factory DeepAnalysisResult.fromJson(Map<String, dynamic> json) {
    return DeepAnalysisResult(
      id: json['id'] ?? '',
      profileArchetype: json['profile_archetype'] ?? 'Bilinmeyen Tip',
      archetypeEmoji: json['archetype_emoji'] ?? '🔮',
      contentPatterns: List<String>.from(json['content_patterns'] ?? []),
      engagementAnalysis: json['engagement_analysis'] ?? '',
      engagementRate: (json['engagement_rate'] ?? 0.0).toDouble(),
      deepRoast: json['deep_roast'] ?? '',
      relationshipPrediction: json['relationship_prediction'] ?? '',
      warningSigns: List<String>.from(json['warning_signs'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_archetype': profileArchetype,
      'archetype_emoji': archetypeEmoji,
      'content_patterns': contentPatterns,
      'engagement_analysis': engagementAnalysis,
      'engagement_rate': engagementRate,
      'deep_roast': deepRoast,
      'relationship_prediction': relationshipPrediction,
      'warning_signs': warningSigns,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper to get engagement rate as percentage string
  String get engagementRateString {
    return '${engagementRate.toStringAsFixed(2)}%';
  }

  // Helper to determine engagement quality
  String get engagementQuality {
    if (engagementRate >= 6) return 'Mükemmel';
    if (engagementRate >= 3) return 'İyi';
    if (engagementRate >= 1) return 'Ortalama';
    return 'Düşük';
  }
}

class DeepAnalysisResponse {
  final bool success;
  final DeepAnalysisResult? result;
  final String? error;
  final String? errorCode;
  final String? username;
  final int postCountAnalyzed;

  DeepAnalysisResponse({
    required this.success,
    this.result,
    this.error,
    this.errorCode,
    this.username,
    this.postCountAnalyzed = 0,
  });

  factory DeepAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return DeepAnalysisResponse(
      success: json['success'] ?? false,
      result: json['result'] != null
          ? DeepAnalysisResult.fromJson(json['result'])
          : null,
      error: json['error'],
      errorCode: json['error_code'],
      username: json['username'],
      postCountAnalyzed: json['post_count_analyzed'] ?? 0,
    );
  }
}
