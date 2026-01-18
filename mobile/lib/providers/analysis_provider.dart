import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';

enum AnalysisState { initial, loading, success, error, rateLimited, needsFallback }

class AnalysisProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  AnalysisState _state = AnalysisState.initial;
  AnalysisResult? _result;
  String? _errorMessage;
  String? _instagramUsername;
  int _remainingUses = 3;

  AnalysisState get state => _state;
  AnalysisResult? get result => _result;
  String? get errorMessage => _errorMessage;
  String? get instagramUsername => _instagramUsername;
  int get remainingUses => _remainingUses;

  Future<void> analyzeProfile(File imageFile) async {
    debugPrint('AnalysisProvider: analyzeProfile started with file: ${imageFile.path}');
    _state = AnalysisState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('AnalysisProvider: Calling API for image analysis...');
      _result = await _apiService.analyzeProfile(imageFile);
      debugPrint('AnalysisProvider: Image analysis successful');
      _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
      _state = AnalysisState.success;
    } on RateLimitException {
      debugPrint('AnalysisProvider: Rate limited');
      _state = AnalysisState.rateLimited;
      _remainingUses = 0;
    } catch (e) {
      debugPrint('AnalysisProvider: Image analysis error - $e');
      _state = AnalysisState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> analyzeInstagram(String urlOrUsername) async {
    debugPrint('AnalysisProvider: analyzeInstagram started with: $urlOrUsername');
    _state = AnalysisState.loading;
    _errorMessage = null;
    _instagramUsername = null;
    notifyListeners();

    try {
      debugPrint('AnalysisProvider: calling API...');
      final response = await _apiService.analyzeInstagram(urlOrUsername);
      debugPrint('AnalysisProvider: API response success=${response.success}, error=${response.error}');

      if (response.success && response.result != null) {
        _result = response.result;
        _instagramUsername = response.username;
        _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
        _state = AnalysisState.success;
        debugPrint('AnalysisProvider: Analysis successful');
      } else if (response.errorCode == 'rate_limit') {
        _state = AnalysisState.rateLimited;
        _remainingUses = 0;
        debugPrint('AnalysisProvider: Rate limited');
      } else if (response.needsFallback) {
        _state = AnalysisState.needsFallback;
        _errorMessage = response.error;
        _instagramUsername = response.username;
        debugPrint('AnalysisProvider: Needs fallback');
      } else {
        _state = AnalysisState.error;
        _errorMessage = response.error ?? 'Bilinmeyen hata';
        debugPrint('AnalysisProvider: Error - ${_errorMessage}');
      }
    } catch (e) {
      debugPrint('AnalysisProvider: Exception - $e');
      _state = AnalysisState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> fetchRemainingUses() async {
    try {
      _remainingUses = await _apiService.getRemainingUses();
      notifyListeners();
    } catch (e) {
      // Silently fail, use default
    }
  }

  void reset() {
    _state = AnalysisState.initial;
    _result = null;
    _errorMessage = null;
    _instagramUsername = null;
    notifyListeners();
  }

  void setResult(AnalysisResult result) {
    _result = result;
    _state = AnalysisState.success;
    notifyListeners();
  }
}
