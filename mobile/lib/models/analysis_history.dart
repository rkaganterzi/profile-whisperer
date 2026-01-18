import 'dart:convert';
import 'analysis_result.dart';
import 'deep_analysis_result.dart';

class AnalysisHistoryItem {
  final String id;
  final DateTime analyzedAt;
  final String? instagramUsername;
  final String? imageSource; // 'camera', 'gallery', 'instagram', 'instagram_deep'
  final AnalysisResult? result;
  final DeepAnalysisResult? deepResult;
  final bool isDeepAnalysis;

  AnalysisHistoryItem({
    required this.id,
    required this.analyzedAt,
    this.instagramUsername,
    this.imageSource,
    this.result,
    this.deepResult,
    this.isDeepAnalysis = false,
  });

  // Helper getters for display
  String get displayTitle => isDeepAnalysis
      ? deepResult?.profileArchetype ?? 'Derin Analiz'
      : result?.vibeType ?? 'Analiz';

  String get displayEmoji => isDeepAnalysis
      ? deepResult?.archetypeEmoji ?? '🔮'
      : result?.vibeEmoji ?? '✨';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analyzedAt': analyzedAt.toIso8601String(),
      'instagramUsername': instagramUsername,
      'imageSource': imageSource,
      'result': result?.toJson(),
      'deepResult': deepResult?.toJson(),
      'isDeepAnalysis': isDeepAnalysis,
    };
  }

  factory AnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    return AnalysisHistoryItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      analyzedAt: DateTime.parse(json['analyzedAt']),
      instagramUsername: json['instagramUsername'],
      imageSource: json['imageSource'],
      result: json['result'] != null ? AnalysisResult.fromJson(json['result']) : null,
      deepResult: json['deepResult'] != null ? DeepAnalysisResult.fromJson(json['deepResult']) : null,
      isDeepAnalysis: json['isDeepAnalysis'] ?? false,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AnalysisHistoryItem.fromJsonString(String jsonString) {
    return AnalysisHistoryItem.fromJson(jsonDecode(jsonString));
  }
}
