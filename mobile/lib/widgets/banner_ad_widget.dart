import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/ad_service.dart';

/// A banner ad widget that only shows for non-premium users
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (!AdService().isInitialized) {
      debugPrint('BannerAdWidget: AdService not initialized');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('BannerAdWidget: Ad loaded');
          if (mounted) {
            setState(() => _isAdLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAdWidget: Ad failed to load - $error');
          ad.dispose();
          _bannerAd = null;
        },
        onAdOpened: (ad) {
          debugPrint('BannerAdWidget: Ad opened');
        },
        onAdClosed: (ad) {
          debugPrint('BannerAdWidget: Ad closed');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads to premium users
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isPremium) {
      return const SizedBox.shrink();
    }

    // Don't show if ad isn't loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox(height: 50); // Reserve space for ad
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
