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
    _state = AnalysisState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _result = await _apiService.analyzeProfile(imageFile);
      _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
      _state = AnalysisState.success;
    } on RateLimitException {
      _state = AnalysisState.rateLimited;
      _remainingUses = 0;
    } catch (e) {
      _state = AnalysisState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> analyzeInstagram(String urlOrUsername) async {
    _state = AnalysisState.loading;
    _errorMessage = null;
    _instagramUsername = null;
    notifyListeners();

    try {
      final response = await _apiService.analyzeInstagram(urlOrUsername);

      if (response.success && response.result != null) {
        _result = response.result;
        _instagramUsername = response.username;
        _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
        _state = AnalysisState.success;
      } else if (response.errorCode == 'rate_limit') {
        _state = AnalysisState.rateLimited;
        _remainingUses = 0;
      } else if (response.needsFallback) {
        _state = AnalysisState.needsFallback;
        _errorMessage = response.error;
        _instagramUsername = response.username;
      } else {
        _state = AnalysisState.error;
        _errorMessage = response.error ?? 'Bilinmeyen hata';
      }
    } catch (e) {
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
