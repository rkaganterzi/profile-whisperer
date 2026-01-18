import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class InstagramAnalysisResult {
  final bool success;
  final AnalysisResult? result;
  final String? error;
  final String? errorCode;
  final String? username;

  InstagramAnalysisResult({
    required this.success,
    this.result,
    this.error,
    this.errorCode,
    this.username,
  });

  factory InstagramAnalysisResult.fromJson(Map<String, dynamic> json) {
    return InstagramAnalysisResult(
      success: json['success'] ?? false,
      result: json['result'] != null ? AnalysisResult.fromJson(json['result']) : null,
      error: json['error'],
      errorCode: json['error_code'],
      username: json['username'],
    );
  }

  bool get needsFallback => !success && errorCode != 'rate_limit';
}

class ApiService {
  static const String _baseUrl = 'http://localhost:8000/api/v1';

  // For development, change this to your local IP when testing on device
  // static const String _baseUrl = 'http://192.168.1.x:8000/api/v1';

  Future<AnalysisResult> analyzeProfile(File imageFile, {String language = 'tr'}) async {
    final uri = Uri.parse('$_baseUrl/analyze?language=$language');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AnalysisResult.fromJson(json);
    } else if (response.statusCode == 429) {
      throw RateLimitException('Daily limit reached');
    } else {
      throw ApiException('Failed to analyze: ${response.statusCode}');
    }
  }

  Future<InstagramAnalysisResult> analyzeInstagram(String urlOrUsername, {String language = 'tr'}) async {
    final uri = Uri.parse('$_baseUrl/analyze-instagram');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'url': urlOrUsername,
        'language': language,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return InstagramAnalysisResult.fromJson(json);
    } else {
      throw ApiException('Instagram analizi başarısız: ${response.statusCode}');
    }
  }

  Future<int> getRemainingUses() async {
    final uri = Uri.parse('$_baseUrl/remaining-uses');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['remaining'] ?? 0;
    }
    return 3; // Default
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);

  @override
  String toString() => message;
}
