import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Singleton service for managing AdMob ads
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  bool get isInitialized => _isInitialized;
  bool get isInterstitialAdReady => _isInterstitialAdReady;

  // Test Ad Unit IDs (replace with real IDs in production)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
    }
    return '';
  }

  /// Initialize AdMob - call from main.dart
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdService: MobileAds initialized successfully');

      // Preload interstitial ad
      _loadInterstitialAd();
    } catch (e) {
      debugPrint('AdService: Failed to initialize MobileAds - $e');
    }
  }

  /// Load an interstitial ad
  void _loadInterstitialAd() {
    if (!_isInitialized) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('AdService: Interstitial ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next interstitial
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: Interstitial ad failed to show - $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Interstitial ad failed to load - $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  /// Show interstitial ad if ready
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd() async {
    if (!_isInitialized || !_isInterstitialAdReady || _interstitialAd == null) {
      debugPrint('AdService: Interstitial ad not ready');
      return false;
    }

    try {
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      debugPrint('AdService: Failed to show interstitial ad - $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
