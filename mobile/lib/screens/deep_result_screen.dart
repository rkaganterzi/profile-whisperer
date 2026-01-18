import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import '../providers/analysis_provider.dart';
import '../services/sound_service.dart';
import '../services/analytics_service.dart';
import '../services/ad_service.dart';
import '../providers/auth_provider.dart';
import '../theme/seductive_colors.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/effects/light_leak.dart';

class DeepResultScreen extends StatefulWidget {
  const DeepResultScreen({super.key});

  @override
  State<DeepResultScreen> createState() => _DeepResultScreenState();
}

class _DeepResultScreenState extends State<DeepResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  final SoundService _soundService = SoundService();
  final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );

    // Log screen view
    _analytics.logScreenView('deep_result_screen');

    // Start reveal animation, confetti and play success sound after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _revealController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
      _soundService.play(SoundType.confetti);
    });

    // Show interstitial ad after 2 seconds for non-premium users
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        if (!authProvider.isPremium) {
          AdService().showInterstitialAd();
        }
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    _soundService.play(SoundType.copy);
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: SeductiveColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check,
                color: SeductiveColors.lunarWhite,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Kopyalandi!',
              style: TextStyle(color: SeductiveColors.lunarWhite),
            ),
          ],
        ),
        backgroundColor: SeductiveColors.velvetPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: SeductiveColors.neonMagenta.withOpacity(0.3),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<AnalysisProvider>().deepResult;
    final username = context.watch<AnalysisProvider>().instagramUsername;
    final postCount = context.watch<AnalysisProvider>().postCountAnalyzed;

    if (result == null) {
      return Scaffold(
        backgroundColor: SeductiveColors.voidBlack,
        body: const Center(
          child: Text(
            'Sonuc bulunamadi',
            style: TextStyle(color: SeductiveColors.lunarWhite),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: Stack(
        children: [
          LightLeak(
            topLeft: true,
            bottomRight: true,
            intensity: 0.12,
            child: SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: SeductiveColors.lunarWhite,
                          ),
                          onPressed: () {
                            context.read<AnalysisProvider>().reset();
                            Navigator.pop(context);
                          },
                        ),
                        const Spacer(),
                        // Share button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: SeductiveColors.primaryGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: SeductiveColors.neonGlow(
                                color: SeductiveColors.neonMagenta,
                                blur: 10,
                              ),
                            ),
                            child: const Icon(
                              Icons.share_rounded,
                              color: SeductiveColors.lunarWhite,
                              size: 20,
                            ),
                          ),
                          onPressed: () => _shareResult(context, result, username),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _revealAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _revealAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 30 * (1 - _revealAnimation.value)),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Header with archetype
                                  _buildArchetypeCard(result, username, postCount),
                                  const SizedBox(height: 20),

                                  // Content Patterns
                                  _buildSectionCard(
                                    title: 'Icerik Kaliplari',
                                    icon: Icons.pattern_rounded,
                                    child: Column(
                                      children: result.contentPatterns
                                          .map((pattern) => _buildPatternItem(pattern))
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Engagement Analysis
                                  _buildEngagementCard(result),
                                  const SizedBox(height: 16),

                                  // Deep Roast
                                  _buildDeepRoastCard(result),
                                  const SizedBox(height: 16),

                                  // Relationship Prediction
                                  _buildSectionCard(
                                    title: 'Iliski Tahmini',
                                    icon: Icons.favorite_rounded,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
                                    ),
                                    child: Text(
                                      result.relationshipPrediction,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: SeductiveColors.lunarWhite,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Warning Signs
                                  _buildWarningSignsCard(result),
                                  const SizedBox(height: 24),

                                  // Try Another Button
                                  GlowButton(
                                    text: 'Yeni Analiz',
                                    onPressed: () {
                                      context.read<AnalysisProvider>().reset();
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                SeductiveColors.neonMagenta,
                SeductiveColors.neonPurple,
                SeductiveColors.neonCoral,
                SeductiveColors.neonWine,
                Color(0xFFFFD700),
                Color(0xFF00FF88),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchetypeCard(result, String? username, int postCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SeductiveColors.neonMagenta.withOpacity(0.2),
            SeductiveColors.neonPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: SeductiveColors.neonMagenta.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: SeductiveColors.neonGlow(
          color: SeductiveColors.neonMagenta,
          blur: 20,
        ),
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: SeductiveColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.psychology_rounded, size: 16, color: SeductiveColors.lunarWhite),
                const SizedBox(width: 6),
                Text(
                  'Derin Analiz - $postCount post',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Emoji
          Text(
            result.archetypeEmoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          // Archetype title
          GradientText(
            result.profileArchetype,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            gradient: SeductiveColors.primaryGradient,
          ),
          if (username != null) ...[
            const SizedBox(height: 8),
            Text(
              '@$username',
              style: const TextStyle(
                fontSize: 16,
                color: SeductiveColors.dustyRose,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Gradient? gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SeductiveColors.neonMagenta.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient ?? SeductiveColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: SeductiveColors.lunarWhite, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildPatternItem(String pattern) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: SeductiveColors.primaryGradient,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pattern,
              style: const TextStyle(
                fontSize: 14,
                color: SeductiveColors.silverMist,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementCard(result) {
    final rate = result.engagementRate;
    final quality = result.engagementQuality;

    Color qualityColor;
    if (rate >= 6) {
      qualityColor = const Color(0xFF4CAF50);
    } else if (rate >= 3) {
      qualityColor = const Color(0xFF2196F3);
    } else if (rate >= 1) {
      qualityColor = const Color(0xFFFF9800);
    } else {
      qualityColor = const Color(0xFFF44336);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: qualityColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: qualityColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Engagement Analizi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: qualityColor),
                ),
                child: Text(
                  quality,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: qualityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Text(
                result.engagementRateString,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: qualityColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (rate / 10).clamp(0.0, 1.0),
                    backgroundColor: SeductiveColors.obsidianDark,
                    valueColor: AlwaysStoppedAnimation<Color>(qualityColor),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.engagementAnalysis,
            style: const TextStyle(
              fontSize: 14,
              color: SeductiveColors.silverMist,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepRoastCard(result) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context, result.deepRoast),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SeductiveColors.neonCoral.withOpacity(0.2),
              SeductiveColors.neonWine.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: SeductiveColors.neonCoral.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: SeductiveColors.neonCoral.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SeductiveColors.buttonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Derin Roast',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SeductiveColors.neonCoral.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 14, color: SeductiveColors.neonCoral),
                      SizedBox(width: 4),
                      Text(
                        'Kopyala',
                        style: TextStyle(
                          fontSize: 11,
                          color: SeductiveColors.neonCoral,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '"${result.deepRoast}"',
              style: const TextStyle(
                fontSize: 16,
                color: SeductiveColors.lunarWhite,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSignsCard(result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SeductiveColors.dangerRed.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SeductiveColors.dangerRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Uyari Isaretleri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.warningSigns.map<Widget>((sign) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: SeductiveColors.dangerRed,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sign,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SeductiveColors.silverMist,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _shareResult(BuildContext context, result, String? username) {
    // Log analytics
    _analytics.logShareResult(method: 'text');

    final text = '''${result.archetypeEmoji} ${result.profileArchetype}
${username != null ? '@$username' : ''}

DERIN ROAST: "${result.deepRoast}"

Iliski Tahmini: ${result.relationshipPrediction}

Uyari Isaretleri:
${result.warningSigns.map((s) => '- $s').join('\n')}

Derin Profil Analizi - Profile Whisperer''';
    Share.share(text);
  }
}
