import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  // Production URL (Render)
  static const String _baseUrl = 'https://profile-whisperer.onrender.com/api/v1';

  // For local development:
  // static const String _baseUrl = 'http://10.0.2.2:8000/api/v1';  // Android emulator
  // static const String _baseUrl = 'http://localhost:8000/api/v1'; // iOS simulator / Web

  Future<AnalysisResult> analyzeProfile(
    File imageFile, {
    String language = 'tr',
    bool roastMode = true,
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze?language=$language&roast_mode=$roastMode');
    debugPrint('ApiService: Uploading image to $uri');
    debugPrint('ApiService: File path: ${imageFile.path}, roastMode: $roastMode');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ));

      debugPrint('ApiService: Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('ApiService: Image upload response status=${response.statusCode}');
      debugPrint('ApiService: Image upload response body=${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return AnalysisResult.fromJson(json);
      } else if (response.statusCode == 429) {
        throw RateLimitException('Daily limit reached');
      } else {
        throw ApiException('Failed to analyze: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService: Image upload error - $e');
      rethrow;
    }
  }

  Future<InstagramAnalysisResult> analyzeInstagram(
    String urlOrUsername, {
    String language = 'tr',
    bool roastMode = true,
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze-instagram');
    debugPrint('ApiService: POST $uri with url=$urlOrUsername, roastMode=$roastMode');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'url': urlOrUsername,
          'language': language,
          'roast_mode': roastMode,
        }),
      );
      debugPrint('ApiService: Response status=${response.statusCode}');
      debugPrint('ApiService: Response body=${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return InstagramAnalysisResult.fromJson(json);
      } else {
        throw ApiException('Instagram analizi başarısız: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ApiService: Exception - $e');
      rethrow;
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
