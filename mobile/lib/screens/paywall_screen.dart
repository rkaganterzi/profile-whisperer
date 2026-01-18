import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../services/analytics_service.dart';
import '../services/purchase_service.dart';
import '../theme/seductive_colors.dart';
import '../widgets/effects/light_leak.dart';
import '../widgets/effects/particle_background.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/core/neon_text.dart';

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
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: ParticleBackground(
        particleCount: 30,
        particleColor: SeductiveColors.neonMagenta.withOpacity(0.3),
        child: LightLeak(
          topLeft: true,
          bottomRight: true,
          intensity: 0.15,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: SeductiveColors.lunarWhite,
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
                          gradient: SeductiveColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: SeductiveColors.neonGlow(
                            color: SeductiveColors.neonMagenta,
                            blur: 10,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${authProvider.credits} Guc',
                              style: const TextStyle(
                                color: SeductiveColors.lunarWhite,
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
                    color: SeductiveColors.obsidianDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SeductiveColors.neonMagenta.withOpacity(0.2),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: SeductiveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: SeductiveColors.neonGlow(
                        color: SeductiveColors.neonMagenta,
                        blur: 8,
                      ),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: SeductiveColors.lunarWhite,
                    unselectedLabelColor: SeductiveColors.dustyRose,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'VIP'),
                      Tab(text: 'Guc Al'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPremiumTab(),
                      _buildCreditsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header with crown
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: SeductiveColors.primaryGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: SeductiveColors.neonGlow(
                color: SeductiveColors.neonMagenta,
                blur: 25,
              ),
            ),
            child: const Center(
              child: Text('', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 24),
          const GradientText(
            "VIP'e Yuksel",
            fontSize: 28,
            fontWeight: FontWeight.bold,
            gradient: SeductiveColors.primaryGradient,
          ),
          const SizedBox(height: 8),
          const Text(
            'Sinirsiz analiz, reklamsiz deneyim',
            style: TextStyle(
              fontSize: 16,
              color: SeductiveColors.silverMist,
            ),
          ),
          const SizedBox(height: 32),
          // Features
          ...SubscriptionPlan.premium.features.asMap().entries.map((entry) {
            final index = entry.key;
            final feature = entry.value;
            final isHighlighted = index == 0; // Deep Profile Analysis is first

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: isHighlighted
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                    : EdgeInsets.zero,
                decoration: isHighlighted
                    ? BoxDecoration(
                        color: SeductiveColors.neonMagenta.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: SeductiveColors.neonMagenta.withOpacity(0.3),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: isHighlighted
                            ? const LinearGradient(
                                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                              )
                            : SeductiveColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: SeductiveColors.neonGlow(
                          color: isHighlighted
                              ? const Color(0xFF9C27B0)
                              : SeductiveColors.neonMagenta,
                          blur: isHighlighted ? 12 : 8,
                        ),
                      ),
                      child: Icon(
                        isHighlighted ? Icons.psychology_rounded : Icons.check,
                        color: SeductiveColors.lunarWhite,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: isHighlighted ? 15 : 16,
                                    fontWeight: isHighlighted
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: SeductiveColors.lunarWhite,
                                  ),
                                ),
                              ),
                              if (isHighlighted) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9C27B0),
                                        Color(0xFFE91E63)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'YENI',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: SeductiveColors.lunarWhite,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (isHighlighted) ...[
                            const SizedBox(height: 4),
                            const Text(
                              'Kapsamli karakter tahmini ve iliski onerisi',
                              style: TextStyle(
                                fontSize: 12,
                                color: SeductiveColors.dustyRose,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          // Plan toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: SeductiveColors.obsidianDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SeductiveColors.neonMagenta.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlanToggle(
                    'Aylik',
                    '${SubscriptionPlan.premium.monthlyPrice.toInt()}/ay',
                    !_isYearly,
                    () => setState(() => _isYearly = false),
                  ),
                ),
                Expanded(
                  child: _buildPlanToggle(
                    'Yillik',
                    '${(SubscriptionPlan.premium.yearlyPrice! / 12).toInt()}/ay',
                    _isYearly,
                    () => setState(() => _isYearly = true),
                    badge: '%28 tasarruf',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Subscribe button
          GlowButton(
            text: _isYearly
                ? 'Yillik ${SubscriptionPlan.premium.yearlyPrice!.toInt()}'
                : 'Aylik ${SubscriptionPlan.premium.monthlyPrice.toInt()}',
            onPressed: _isLoading ? null : () => _purchasePremium(),
            isLoading: _isLoading,
            icon: Icons.workspace_premium_rounded,
          ),
          const SizedBox(height: 12),
          // Terms
          Text(
            _isYearly
                ? 'Yillik abonelik. Istedigin zaman iptal edebilirsin.'
                : 'Aylik abonelik. Istedigin zaman iptal edebilirsin.',
            style: const TextStyle(
              fontSize: 12,
              color: SeductiveColors.dustyRose,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Restore purchases button
          TextButton(
            onPressed: _isLoading ? null : _restorePurchases,
            child: const Text(
              'Satin alimlari geri yukle',
              style: TextStyle(
                fontSize: 14,
                color: SeductiveColors.dustyRose,
                decoration: TextDecoration.underline,
                decorationColor: SeductiveColors.dustyRose,
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
    VoidCallback onTap, {
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? SeductiveColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? SeductiveColors.neonGlow(
                  color: SeductiveColors.neonMagenta,
                  blur: 8,
                )
              : null,
        ),
        child: Column(
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : SeductiveColors.neonMagenta.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? SeductiveColors.lunarWhite
                        : SeductiveColors.neonMagenta,
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
                    ? SeductiveColors.lunarWhite
                    : SeductiveColors.silverMist,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white70
                    : SeductiveColors.dustyRose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: SeductiveColors.buttonGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: SeductiveColors.neonGlow(
                color: SeductiveColors.neonCoral,
                blur: 25,
              ),
            ),
            child: const Center(
              child: Text('', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 24),
          const GradientText(
            'Guc Satin Al',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            gradient: SeductiveColors.buttonGradient,
          ),
          const SizedBox(height: 8),
          const Text(
            '1 guc = 1 profil analizi',
            style: TextStyle(
              fontSize: 16,
              color: SeductiveColors.silverMist,
            ),
          ),
          const SizedBox(height: 32),
          // Credit packages
          ...CreditPackage.packages.map((package) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCreditPackageCard(package),
            );
          }),
          const SizedBox(height: 16),
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SeductiveColors.velvetPurple,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: SeductiveColors.neonPurple.withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Text('', style: TextStyle(fontSize: 24)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'VIP uyelik ile her ay 50 bonus guc kazanirsin!',
                    style: TextStyle(
                      fontSize: 14,
                      color: SeductiveColors.lunarWhite,
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

  Widget _buildCreditPackageCard(CreditPackage package) {
    final pricePerCredit = package.price / package.credits;

    return Container(
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(20),
        border: package.badge != null
            ? Border.all(color: SeductiveColors.neonMagenta, width: 2)
            : Border.all(color: SeductiveColors.smokyViolet),
        boxShadow: package.badge != null
            ? SeductiveColors.neonGlow(
                color: SeductiveColors.neonMagenta,
                blur: 15,
              )
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
                    gradient: SeductiveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: SeductiveColors.neonGlow(
                      color: SeductiveColors.neonMagenta,
                      blur: 10,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${package.credits}',
                        style: const TextStyle(
                          color: SeductiveColors.lunarWhite,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'guc',
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SeductiveColors.lunarWhite,
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
                                gradient: SeductiveColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                package.badge!,
                                style: const TextStyle(
                                  color: SeductiveColors.lunarWhite,
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
                        '${pricePerCredit.toStringAsFixed(2)} / guc',
                        style: const TextStyle(
                          fontSize: 13,
                          color: SeductiveColors.dustyRose,
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
                    color: SeductiveColors.neonMagenta.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: SeductiveColors.neonMagenta.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${package.price.toInt()}',
                    style: const TextStyle(
                      color: SeductiveColors.neonMagenta,
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
                Text('', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text('VIP aktif! Hos geldin!'),
              ],
            ),
            backgroundColor: SeductiveColors.neonMagenta,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (result.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: SeductiveColors.dangerRed,
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
                Text('', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text('VIP aktif! Hos geldin!'),
              ],
            ),
            backgroundColor: SeductiveColors.neonMagenta,
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
                const Text('', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text('${package.credits} guc eklendi!'),
              ],
            ),
            backgroundColor: SeductiveColors.neonMagenta,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (result.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: SeductiveColors.dangerRed,
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
                const Text('', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text('${package.credits} guc eklendi!'),
              ],
            ),
            backgroundColor: SeductiveColors.neonMagenta,
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
                Text('', style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Text('VIP geri yuklendi!'),
              ],
            ),
            backgroundColor: SeductiveColors.neonMagenta,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Geri yuklenecek satin alma bulunamadi'),
            backgroundColor: SeductiveColors.neonCoral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Geri yukleme basarisiz'),
          backgroundColor: SeductiveColors.dangerRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
