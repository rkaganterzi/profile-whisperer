import 'dart:convert';
import 'analysis_result.dart';

class AnalysisHistoryItem {
  final String id;
  final DateTime analyzedAt;
  final String? instagramUsername;
  final String? imageSource; // 'camera', 'gallery', 'instagram'
  final AnalysisResult result;

  AnalysisHistoryItem({
    required this.id,
    required this.analyzedAt,
    this.instagramUsername,
    this.imageSource,
    required this.result,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analyzedAt': analyzedAt.toIso8601String(),
      'instagramUsername': instagramUsername,
      'imageSource': imageSource,
      'result': result.toJson(),
    };
  }

  factory AnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    return AnalysisHistoryItem(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      analyzedAt: DateTime.parse(json['analyzedAt']),
      instagramUsername: json['instagramUsername'],
      imageSource: json['imageSource'],
      result: AnalysisResult.fromJson(json['result']),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AnalysisHistoryItem.fromJsonString(String jsonString) {
    return AnalysisHistoryItem.fromJson(jsonDecode(jsonString));
  }
}
