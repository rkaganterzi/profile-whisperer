import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../services/analytics_service.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';

class PaywallScreen extends StatefulWidget {
  final bool showCreditsTab;

  const PaywallScreen({super.key, this.showCreditsTab = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AnalyticsService _analytics = AnalyticsService();
  final PurchaseService _purchaseService = PurchaseService();
  bool _isYearly = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showCreditsTab ? 1 : 0,
    );

    // Log screen view
    _analytics.logScreenView('paywall_screen');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  // Current credits badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${authProvider.credits} Kredi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Premium'),
                  Tab(text: 'Kredi Al'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPremiumTab(isDark),
                  _buildCreditsTab(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          const Text('👑', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Premium\'a Geç',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sınırsız analiz, reklamsız deneyim',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 32),
          // Features
          ...SubscriptionPlan.premium.features.map((feature) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          // Plan toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlanToggle(
                    'Aylık',
                    '₺${SubscriptionPlan.premium.monthlyPrice.toInt()}/ay',
                    !_isYearly,
                    () => setState(() => _isYearly = false),
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildPlanToggle(
                    'Yıllık',
                    '₺${(SubscriptionPlan.premium.yearlyPrice! / 12).toInt()}/ay',
                    _isYearly,
                    () => setState(() => _isYearly = true),
                    isDark,
                    badge: '%28 tasarruf',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Subscribe button
          _buildPurchaseButton(
            text: _isYearly
                ? 'Yıllık ₺${SubscriptionPlan.premium.yearlyPrice!.toInt()}'
                : 'Aylık ₺${SubscriptionPlan.premium.monthlyPrice.toInt()}',
            onPressed: () => _purchasePremium(),
          ),
          const SizedBox(height: 12),
          // Terms
          Text(
            _isYearly
                ? 'Yıllık abonelik. İstediğin zaman iptal edebilirsin.'
                : 'Aylık abonelik. İstediğin zaman iptal edebilirsin.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Restore purchases button
          TextButton(
            onPressed: _isLoading ? null : _restorePurchases,
            child: Text(
              'Satın alımları geri yükle',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(
    String title,
    String price,
    bool isSelected,
    VoidCallback onTap,
    bool isDark, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppTheme.primaryPink,
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.textWhite : AppTheme.textDark),
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white70
                    : (isDark ? AppTheme.textGrayDark : AppTheme.textGray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          const Text('⚡', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(
            'Kredi Satın Al',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1 kredi = 1 profil analizi',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 32),
          // Credit packages
          ...CreditPackage.packages.map((package) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCreditPackageCard(package, isDark),
            );
          }),
          const SizedBox(height: 16),
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceDark
                  : AppTheme.primaryPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Premium üyelik ile her ay 50 bonus kredi kazanırsın!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditPackageCard(CreditPackage package, bool isDark) {
    final pricePerCredit = package.price / package.credits;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: package.badge != null
            ? Border.all(color: AppTheme.primaryPink, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchaseCredits(package),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Credits amount
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${package.credits}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'kredi',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? AppTheme.textWhite : AppTheme.textDark,
                            ),
                          ),
                          if (package.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                package.badge!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₺${pricePerCredit.toStringAsFixed(2)} / kredi',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₺${package.price.toInt()}',
                    style: const TextStyle(
                      color: AppTheme.primaryPink,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchaseButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _purchasePremium() async {
    final productId = _isYearly
        ? PurchaseService.premiumYearly
        : PurchaseService.premiumMonthly;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    // Try RevenueCat purchase first
    if (_purchaseService.isInitialized) {
      final result = await _purchaseService.purchaseProductById(productId);

      setState(() => _isLoading = false);

      if (result.success && mounted) {
        // Update local auth state
        final authProvider = context.read<AuthProvider>();
        final until = _isYearly
            ? DateTime.now().add(const Duration(days: 365))
            : DateTime.now().add(const Duration(days: 30));
        await authProvider.setPremium(until);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('👑', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text('Premium aktif! Hoş geldin! 🎉'),
              ],
            ),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (result.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      // Fallback to mock purchase if RevenueCat not initialized
      _analytics.logPurchaseInitiated(productType: productId);

      await Future.delayed(const Duration(seconds: 2));

      final authProvider = context.read<AuthProvider>();
      final until = _isYearly
          ? DateTime.now().add(const Duration(days: 365))
          : DateTime.now().add(const Duration(days: 30));

      final success = await authProvider.setPremium(until);

      setState(() => _isLoading = false);

      if (success && mounted) {
        _analytics.logPurchaseCompleted(
          productType: productId,
          price: _isYearly
              ? SubscriptionPlan.premium.yearlyPrice
              : SubscriptionPlan.premium.monthlyPrice,
          currency: 'TRY',
        );
        _analytics.setIsPremium(true);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('👑', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text('Premium aktif! Hoş geldin! 🎉'),
              ],
            ),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _purchaseCredits(CreditPackage package) async {
    final productId = 'credits_${package.credits}';

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    // Try RevenueCat purchase first
    if (_purchaseService.isInitialized) {
      final result = await _purchaseService.purchaseProductById(productId);

      setState(() => _isLoading = false);

      if (result.success && mounted) {
        // Update local auth state
        final authProvider = context.read<AuthProvider>();
        await authProvider.addCredits(package.credits);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text('${package.credits} kredi eklendi! 🎉'),
              ],
            ),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (result.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      // Fallback to mock purchase if RevenueCat not initialized
      _analytics.logPurchaseInitiated(productType: productId);

      await Future.delayed(const Duration(seconds: 2));

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.addCredits(package.credits);

      setState(() => _isLoading = false);

      if (success && mounted) {
        _analytics.logPurchaseCompleted(
          productType: productId,
          price: package.price,
          currency: 'TRY',
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text('${package.credits} kredi eklendi! 🎉'),
              ],
            ),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    final result = await _purchaseService.restorePurchases();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.success) {
      if (result.hasPremium) {
        // Update local auth state
        final authProvider = context.read<AuthProvider>();
        await authProvider.setPremium(
          DateTime.now().add(const Duration(days: 365)),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Text('👑', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text('Premium geri yüklendi!'),
              ],
            ),
            backgroundColor: AppTheme.primaryPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Geri yüklenecek satın alma bulunamadı'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Geri yükleme başarısız'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
