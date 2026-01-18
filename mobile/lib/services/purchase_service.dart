import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'analytics_service.dart';

/// Singleton service for managing in-app purchases via RevenueCat
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  bool _isInitialized = false;
  Offerings? _offerings;
  CustomerInfo? _customerInfo;

  // RevenueCat API Keys - Replace with your actual keys
  // TODO: Replace with production keys before release
  static const String _apiKeyIOS = 'appl_PLACEHOLDER_IOS_API_KEY';
  static const String _apiKeyAndroid = 'goog_PLACEHOLDER_ANDROID_API_KEY';

  // Product IDs
  static const String premiumMonthly = 'premium_monthly';
  static const String premiumYearly = 'premium_yearly';
  static const String credits25 = 'credits_25';
  static const String credits75 = 'credits_75';
  static const String credits200 = 'credits_200';

  bool get isInitialized => _isInitialized;
  Offerings? get offerings => _offerings;
  CustomerInfo? get customerInfo => _customerInfo;

  /// Check if user has active premium subscription
  bool get isPremium {
    return _customerInfo?.entitlements.all['premium']?.isActive ?? false;
  }

  /// Initialize RevenueCat - call from main.dart
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final apiKey = Platform.isIOS ? _apiKeyIOS : _apiKeyAndroid;

      // Configure RevenueCat
      await Purchases.configure(
        PurchasesConfiguration(apiKey),
      );

      // Listen for customer info updates
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfo = customerInfo;
        debugPrint('PurchaseService: Customer info updated - Premium: $isPremium');
      });

      // Get initial customer info
      _customerInfo = await Purchases.getCustomerInfo();

      // Fetch offerings
      await _fetchOfferings();

      _isInitialized = true;
      debugPrint('PurchaseService: Initialized successfully');
    } catch (e) {
      debugPrint('PurchaseService: Failed to initialize - $e');
    }
  }

  /// Fetch available offerings
  Future<void> _fetchOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      debugPrint('PurchaseService: Offerings fetched - ${_offerings?.current?.identifier}');
    } catch (e) {
      debugPrint('PurchaseService: Failed to fetch offerings - $e');
    }
  }

  /// Refresh offerings
  Future<void> refreshOfferings() async {
    await _fetchOfferings();
  }

  /// Purchase a package
  /// Returns true if purchase was successful, false otherwise
  Future<PurchaseResult> purchasePackage(Package package) async {
    if (!_isInitialized) {
      return PurchaseResult(
        success: false,
        error: 'Purchase service not initialized',
      );
    }

    try {
      // Log purchase initiated
      AnalyticsService().logPurchaseInitiated(
        productType: package.storeProduct.identifier,
      );

      final result = await Purchases.purchasePackage(package);
      _customerInfo = result;

      // Log purchase completed
      AnalyticsService().logPurchaseCompleted(
        productType: package.storeProduct.identifier,
        price: package.storeProduct.price,
        currency: package.storeProduct.currencyCode,
      );

      // Update premium status in analytics
      if (isPremium) {
        AnalyticsService().setIsPremium(true);
      }

      debugPrint('PurchaseService: Purchase successful - ${package.storeProduct.identifier}');
      return PurchaseResult(
        success: true,
        customerInfo: result,
      );
    } on PurchasesErrorCode catch (e) {
      debugPrint('PurchaseService: Purchase error - $e');

      String errorMessage;
      switch (e) {
        case PurchasesErrorCode.purchaseCancelledError:
          errorMessage = 'Satın alma iptal edildi';
          break;
        case PurchasesErrorCode.paymentPendingError:
          errorMessage = 'Ödeme beklemede';
          break;
        case PurchasesErrorCode.productAlreadyPurchasedError:
          errorMessage = 'Bu ürün zaten satın alındı';
          break;
        default:
          errorMessage = 'Satın alma başarısız oldu';
      }

      // Log purchase failed
      AnalyticsService().logPurchaseFailed(
        productType: package.storeProduct.identifier,
        error: e.toString(),
      );

      return PurchaseResult(
        success: false,
        error: errorMessage,
      );
    } catch (e) {
      debugPrint('PurchaseService: Unknown purchase error - $e');

      AnalyticsService().logPurchaseFailed(
        productType: package.storeProduct.identifier,
        error: e.toString(),
      );

      return PurchaseResult(
        success: false,
        error: 'Satın alma başarısız oldu: $e',
      );
    }
  }

  /// Purchase by product ID
  Future<PurchaseResult> purchaseProductById(String productId) async {
    if (!_isInitialized || _offerings == null) {
      return PurchaseResult(
        success: false,
        error: 'Purchase service not ready',
      );
    }

    // Find package by product ID
    final allPackages = _offerings!.current?.availablePackages ?? [];
    Package? targetPackage;

    for (final package in allPackages) {
      if (package.storeProduct.identifier == productId) {
        targetPackage = package;
        break;
      }
    }

    if (targetPackage == null) {
      return PurchaseResult(
        success: false,
        error: 'Product not found: $productId',
      );
    }

    return purchasePackage(targetPackage);
  }

  /// Restore purchases
  Future<RestoreResult> restorePurchases() async {
    if (!_isInitialized) {
      return RestoreResult(
        success: false,
        error: 'Purchase service not initialized',
      );
    }

    try {
      _customerInfo = await Purchases.restorePurchases();

      if (isPremium) {
        AnalyticsService().setIsPremium(true);
        return RestoreResult(
          success: true,
          hasPremium: true,
          customerInfo: _customerInfo,
        );
      }

      return RestoreResult(
        success: true,
        hasPremium: false,
        customerInfo: _customerInfo,
      );
    } catch (e) {
      debugPrint('PurchaseService: Restore error - $e');
      return RestoreResult(
        success: false,
        error: 'Geri yükleme başarısız: $e',
      );
    }
  }

  /// Login user to RevenueCat (for syncing purchases across devices)
  Future<void> login(String userId) async {
    if (!_isInitialized) return;

    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
      debugPrint('PurchaseService: User logged in - $userId');
    } catch (e) {
      debugPrint('PurchaseService: Login error - $e');
    }
  }

  /// Logout user from RevenueCat
  Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      _customerInfo = await Purchases.logOut();
      debugPrint('PurchaseService: User logged out');
    } catch (e) {
      debugPrint('PurchaseService: Logout error - $e');
    }
  }

  /// Get price string for a product
  String? getPriceForProduct(String productId) {
    if (_offerings == null) return null;

    final allPackages = _offerings!.current?.availablePackages ?? [];
    for (final package in allPackages) {
      if (package.storeProduct.identifier == productId) {
        return package.storeProduct.priceString;
      }
    }
    return null;
  }
}

/// Result of a purchase operation
class PurchaseResult {
  final bool success;
  final String? error;
  final CustomerInfo? customerInfo;

  PurchaseResult({
    required this.success,
    this.error,
    this.customerInfo,
  });
}

/// Result of a restore operation
class RestoreResult {
  final bool success;
  final bool hasPremium;
  final String? error;
  final CustomerInfo? customerInfo;

  RestoreResult({
    required this.success,
    this.hasPremium = false,
    this.error,
    this.customerInfo,
  });
}
