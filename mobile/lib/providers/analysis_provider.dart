import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/analysis_result.dart';
import '../models/deep_analysis_result.dart';
import '../services/api_service.dart';
import '../services/instagram_client_service.dart';

enum AnalysisState { initial, loading, success, error, rateLimited, needsFallback, deepSuccess }

class AnalysisProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final InstagramClientService _instagramClient = InstagramClientService();

  AnalysisState _state = AnalysisState.initial;
  AnalysisResult? _result;
  DeepAnalysisResult? _deepResult;
  String? _errorMessage;
  String? _instagramUsername;
  int _remainingUses = 3;
  String? _loadingMessage; // For showing progress during multi-step fetch
  int _postCountAnalyzed = 0;

  AnalysisState get state => _state;
  AnalysisResult? get result => _result;
  DeepAnalysisResult? get deepResult => _deepResult;
  String? get errorMessage => _errorMessage;
  String? get instagramUsername => _instagramUsername;
  int get remainingUses => _remainingUses;
  String? get loadingMessage => _loadingMessage;
  int get postCountAnalyzed => _postCountAnalyzed;

  Future<void> analyzeProfile(File imageFile, {bool roastMode = true}) async {
    debugPrint('AnalysisProvider: analyzeProfile started with file: ${imageFile.path}, roastMode: $roastMode');
    _state = AnalysisState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('AnalysisProvider: Calling API for image analysis...');
      _result = await _apiService.analyzeProfile(imageFile, roastMode: roastMode);
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

  Future<void> analyzeInstagram(String urlOrUsername, {bool roastMode = true}) async {
    debugPrint('AnalysisProvider: analyzeInstagram started with: $urlOrUsername, roastMode: $roastMode');
    _state = AnalysisState.loading;
    _errorMessage = null;
    _instagramUsername = null;
    _loadingMessage = 'Profil aranıyor...';
    notifyListeners();

    // Extract username for display
    final username = _instagramClient.extractUsername(urlOrUsername);
    if (username != null) {
      _instagramUsername = username;
    }

    // STEP 1: Try client-side fetch first (uses user's IP - much less likely to be blocked)
    debugPrint('AnalysisProvider: Step 1 - Trying client-side fetch...');
    _loadingMessage = 'Instagram\'a bağlanılıyor...';
    notifyListeners();

    try {
      final clientResult = await _instagramClient.fetchProfilePhoto(urlOrUsername);

      if (clientResult.success && clientResult.imageFile != null) {
        debugPrint('AnalysisProvider: Client-side fetch successful!');
        _instagramUsername = clientResult.username;
        _loadingMessage = 'Profil bulundu, analiz ediliyor...';
        notifyListeners();

        // Analyze the downloaded image via backend
        try {
          _result = await _apiService.analyzeProfile(clientResult.imageFile!, roastMode: roastMode);
          _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
          _state = AnalysisState.success;
          _loadingMessage = null;
          debugPrint('AnalysisProvider: Client-side + API analysis successful');
          notifyListeners();

          // Clean up temp file
          try {
            await clientResult.imageFile!.delete();
          } catch (_) {}

          return;
        } on RateLimitException {
          _state = AnalysisState.rateLimited;
          _remainingUses = 0;
          _loadingMessage = null;
          notifyListeners();
          return;
        } catch (e) {
          debugPrint('AnalysisProvider: API analysis failed: $e');
          // Continue to backend fallback
        }
      } else {
        debugPrint('AnalysisProvider: Client-side fetch failed: ${clientResult.errorCode}');

        // If it's a definitive error (user not found, invalid username), don't try backend
        if (clientResult.errorCode == 'user_not_found' || clientResult.errorCode == 'invalid_username') {
          _state = AnalysisState.error;
          _errorMessage = clientResult.errorMessage;
          _loadingMessage = null;
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('AnalysisProvider: Client-side exception: $e');
      // Continue to backend fallback
    }

    // STEP 2: Try backend fetch (server-side scraping)
    debugPrint('AnalysisProvider: Step 2 - Trying backend fetch...');
    _loadingMessage = 'Alternatif yöntem deneniyor...';
    notifyListeners();

    try {
      final response = await _apiService.analyzeInstagram(urlOrUsername, roastMode: roastMode);
      debugPrint('AnalysisProvider: Backend response success=${response.success}, error=${response.error}');

      if (response.success && response.result != null) {
        _result = response.result;
        _instagramUsername = response.username;
        _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
        _state = AnalysisState.success;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Backend analysis successful');
      } else if (response.errorCode == 'rate_limit') {
        _state = AnalysisState.rateLimited;
        _remainingUses = 0;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Rate limited');
      } else if (response.needsFallback) {
        _state = AnalysisState.needsFallback;
        _errorMessage = response.error;
        _instagramUsername = response.username;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Needs fallback - suggesting screenshot');
      } else {
        _state = AnalysisState.error;
        _errorMessage = response.error ?? 'Bilinmeyen hata';
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Error - $_errorMessage');
      }
    } catch (e) {
      debugPrint('AnalysisProvider: Backend exception - $e');
      // Both methods failed - show fallback
      _state = AnalysisState.needsFallback;
      _errorMessage = 'Instagram\'a erişilemiyor. Profil screenshot\'ı yükleyerek devam edebilirsin.';
      _loadingMessage = null;
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
    _deepResult = null;
    _errorMessage = null;
    _instagramUsername = null;
    _loadingMessage = null;
    _postCountAnalyzed = 0;
    notifyListeners();
  }

  void setResult(AnalysisResult result) {
    _result = result;
    _state = AnalysisState.success;
    notifyListeners();
  }

  void setDeepResult(DeepAnalysisResult result, {String? username}) {
    _deepResult = result;
    _instagramUsername = username;
    _state = AnalysisState.deepSuccess;
    notifyListeners();
  }

  Future<void> analyzeInstagramDeep(String urlOrUsername) async {
    debugPrint('AnalysisProvider: analyzeInstagramDeep started with: $urlOrUsername');
    _state = AnalysisState.loading;
    _errorMessage = null;
    _instagramUsername = null;
    _deepResult = null;
    _postCountAnalyzed = 0;
    _loadingMessage = 'Derin analiz başlatılıyor...';
    notifyListeners();

    // Extract username for display
    final username = _instagramClient.extractUsername(urlOrUsername);
    if (username != null) {
      _instagramUsername = username;
    }

    _loadingMessage = 'Profil verileri çekiliyor...';
    notifyListeners();

    try {
      _loadingMessage = '6-9 post analiz ediliyor...';
      notifyListeners();

      final response = await _apiService.analyzeInstagramDeep(urlOrUsername);
      debugPrint('AnalysisProvider: Deep analysis response success=${response.success}, error=${response.error}');

      if (response.success && response.result != null) {
        _deepResult = response.result;
        _instagramUsername = response.username;
        _postCountAnalyzed = response.postCountAnalyzed;
        _remainingUses = _remainingUses > 0 ? _remainingUses - 1 : 0;
        _state = AnalysisState.deepSuccess;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Deep analysis successful');
      } else if (response.errorCode == 'rate_limit') {
        _state = AnalysisState.rateLimited;
        _remainingUses = 0;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Rate limited');
      } else if (response.errorCode == 'private_account') {
        _state = AnalysisState.error;
        _errorMessage = response.error;
        _instagramUsername = response.username;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Private account');
      } else if (response.errorCode == 'insufficient_posts') {
        _state = AnalysisState.error;
        _errorMessage = response.error;
        _instagramUsername = response.username;
        _postCountAnalyzed = response.postCountAnalyzed;
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Insufficient posts');
      } else {
        _state = AnalysisState.error;
        _errorMessage = response.error ?? 'Bilinmeyen hata';
        _loadingMessage = null;
        debugPrint('AnalysisProvider: Error - $_errorMessage');
      }
    } catch (e) {
      debugPrint('AnalysisProvider: Deep analysis exception - $e');
      _state = AnalysisState.error;
      _errorMessage = 'Derin analiz başarısız: $e';
      _loadingMessage = null;
    }

    notifyListeners();
  }
}
