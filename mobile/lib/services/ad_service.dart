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
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  bool get isInitialized => _isInitialized;
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;

  // Production Ad Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9682546527690102/3057584116'; // Android Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9682546527690102/3057584116'; // iOS Banner (aynı veya iOS için ayrı oluştur)
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9682546527690102/1456921359'; // Android Interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9682546527690102/1456921359'; // iOS Interstitial (aynı veya iOS için ayrı oluştur)
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9682546527690102/7890123456'; // Android Rewarded (replace with actual ID)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9682546527690102/7890123456'; // iOS Rewarded (replace with actual ID)
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

      // Preload ads
      _loadInterstitialAd();
      _loadRewardedAd();
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

  /// Load a rewarded ad
  void _loadRewardedAd() {
    if (!_isInitialized) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('AdService: Rewarded ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('AdService: Rewarded ad dismissed');
              ad.dispose();
              _isRewardedAdReady = false;
              // Preload next rewarded ad
              _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('AdService: Rewarded ad failed to show - $error');
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdService: Rewarded ad failed to load - $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// Show rewarded ad and return true if reward was earned
  /// [onRewarded] callback receives the reward amount
  Future<bool> showRewardedAd({required Function(int amount) onRewarded}) async {
    if (!_isInitialized || !_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('AdService: Rewarded ad not ready');
      return false;
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('AdService: User earned reward - ${reward.amount} ${reward.type}');
          onRewarded(reward.amount.toInt());
        },
      );
      return true;
    } catch (e) {
      debugPrint('AdService: Failed to show rewarded ad - $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
}
