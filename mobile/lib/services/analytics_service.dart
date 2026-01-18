import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../main.dart' show firebaseInitialized;

/// Singleton service for Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  bool get isEnabled => _analytics != null && firebaseInitialized;

  /// Initialize analytics - call from main.dart after Firebase.initializeApp()
  void init() {
    if (!firebaseInitialized) {
      debugPrint('AnalyticsService: Firebase not initialized, analytics disabled');
      return;
    }

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
      debugPrint('AnalyticsService: Initialized successfully');
    } catch (e) {
      debugPrint('AnalyticsService: Failed to initialize - $e');
    }
  }

  /// Get the analytics observer for MaterialApp.navigatorObservers
  FirebaseAnalyticsObserver? get observer => _observer;

  // ==================== APP LIFECYCLE EVENTS ====================

  /// Log when app is opened
  Future<void> logAppOpen() async {
    await _logEvent('app_open');
  }

  // ==================== SCREEN TRACKING ====================

  /// Log screen view
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (!isEnabled) return;
    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('AnalyticsService: Screen view - $screenName');
    } catch (e) {
      debugPrint('AnalyticsService: logScreenView error - $e');
    }
  }

  // ==================== ANALYSIS EVENTS ====================

  /// Log when analysis is started
  Future<void> logAnalyzeStarted({
    required String source, // 'instagram', 'camera', 'gallery'
  }) async {
    await _logEvent('analyze_started', {'source': source});
  }

  /// Log when analysis is completed successfully
  Future<void> logAnalyzeCompleted({
    required String source,
    required String vibeType,
  }) async {
    await _logEvent('analyze_completed', {
      'source': source,
      'vibe_type': vibeType,
    });
  }

  /// Log when analysis fails
  Future<void> logAnalyzeFailed({
    required String source,
    required String error,
  }) async {
    await _logEvent('analyze_failed', {
      'source': source,
      'error': error,
    });
  }

  // ==================== SHARING EVENTS ====================

  /// Log when result is shared
  Future<void> logShareResult({String? method}) async {
    await _logEvent('share_result', {
      if (method != null) 'method': method,
    });
  }

  /// Log when conversation starter is copied
  Future<void> logStarterCopied({int? index, String? category}) async {
    await _logEvent('starter_copied', {
      if (index != null) 'index': index,
      if (category != null) 'category': category,
    });
  }

  // ==================== COMPARISON EVENTS ====================

  /// Log when profiles are compared
  Future<void> logCompareProfiles({int? compatibilityScore}) async {
    await _logEvent('compare_profiles', {
      if (compatibilityScore != null) 'compatibility_score': compatibilityScore,
    });
  }

  // ==================== PURCHASE EVENTS ====================

  /// Log when purchase flow is initiated
  Future<void> logPurchaseInitiated({
    required String productType, // 'premium_monthly', 'premium_yearly', 'credits_25', etc.
  }) async {
    await _logEvent('purchase_initiated', {'product_type': productType});
  }

  /// Log when purchase is completed
  Future<void> logPurchaseCompleted({
    required String productType,
    double? price,
    String? currency,
  }) async {
    await _logEvent('purchase_completed', {
      'product_type': productType,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
    });
  }

  /// Log when purchase fails
  Future<void> logPurchaseFailed({
    required String productType,
    required String error,
  }) async {
    await _logEvent('purchase_failed', {
      'product_type': productType,
      'error': error,
    });
  }

  // ==================== AUTH EVENTS ====================

  /// Log user login
  Future<void> logLogin({required String method}) async {
    if (!isEnabled) return;
    try {
      await _analytics!.logLogin(loginMethod: method);
      debugPrint('AnalyticsService: Login - $method');
    } catch (e) {
      debugPrint('AnalyticsService: logLogin error - $e');
    }
  }

  /// Log user sign up
  Future<void> logSignUp({required String method}) async {
    if (!isEnabled) return;
    try {
      await _analytics!.logSignUp(signUpMethod: method);
      debugPrint('AnalyticsService: Sign up - $method');
    } catch (e) {
      debugPrint('AnalyticsService: logSignUp error - $e');
    }
  }

  // ==================== USER PROPERTIES ====================

  /// Set user's premium status
  Future<void> setIsPremium(bool isPremium) async {
    await _setUserProperty('is_premium', isPremium.toString());
  }

  /// Set user's total analyses count tier
  Future<void> setTotalAnalysesTier(int totalAnalyses) async {
    String tier;
    if (totalAnalyses == 0) {
      tier = 'none';
    } else if (totalAnalyses <= 5) {
      tier = '1-5';
    } else if (totalAnalyses <= 20) {
      tier = '6-20';
    } else if (totalAnalyses <= 50) {
      tier = '21-50';
    } else {
      tier = '50+';
    }
    await _setUserProperty('total_analyses_tier', tier);
  }

  /// Set user's preferred language
  Future<void> setPreferredLanguage(String language) async {
    await _setUserProperty('preferred_language', language);
  }

  /// Set user ID for tracking
  Future<void> setUserId(String? userId) async {
    if (!isEnabled) return;
    try {
      await _analytics!.setUserId(id: userId);
      debugPrint('AnalyticsService: User ID set - $userId');
    } catch (e) {
      debugPrint('AnalyticsService: setUserId error - $e');
    }
  }

  // ==================== SETTINGS EVENTS ====================

  /// Log when roast mode is toggled
  Future<void> logRoastModeToggled({required bool enabled}) async {
    await _logEvent('roast_mode_toggled', {'enabled': enabled});
  }

  /// Log when theme is changed
  Future<void> logThemeChanged({required String theme}) async {
    await _logEvent('theme_changed', {'theme': theme});
  }

  // ==================== HELPER METHODS ====================

  Future<void> _logEvent(String name, [Map<String, Object>? parameters]) async {
    if (!isEnabled) return;
    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
      debugPrint('AnalyticsService: Event - $name ${parameters ?? ''}');
    } catch (e) {
      debugPrint('AnalyticsService: logEvent error - $e');
    }
  }

  Future<void> _setUserProperty(String name, String value) async {
    if (!isEnabled) return;
    try {
      await _analytics!.setUserProperty(name: name, value: value);
      debugPrint('AnalyticsService: User property - $name: $value');
    } catch (e) {
      debugPrint('AnalyticsService: setUserProperty error - $e');
    }
  }
}
