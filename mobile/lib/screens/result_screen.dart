import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/analysis_provider.dart';
import '../services/sound_service.dart';
import '../services/analytics_service.dart';
import '../services/ad_service.dart';
import '../providers/auth_provider.dart';
import '../theme/seductive_colors.dart';
import '../widgets/vibe_card.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/effects/light_leak.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  final ScreenshotController _screenshotController = ScreenshotController();
  final SoundService _soundService = SoundService();
  final AnalyticsService _analytics = AnalyticsService();
  int _selectedCategoryIndex = -1; // -1 means "All"
  int _currentStarterIndex = 0;
  final PageController _pageController = PageController();

  static const List<Map<String, dynamic>> _categories = [
    {'emoji': '', 'name': 'Merak', 'color': Color(0xFF5C6BC0)},
    {'emoji': '', 'name': 'Sakaci', 'color': Color(0xFFFF7043)},
    {'emoji': '', 'name': 'Komik', 'color': Color(0xFFFFCA28)},
    {'emoji': '', 'name': 'Smooth', 'color': Color(0xFF26A69A)},
    {'emoji': '', 'name': 'Cesur', 'color': Color(0xFFEF5350)},
  ];

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
    _analytics.logScreenView('result_screen');

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
    _pageController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text, {int? index}) {
    Clipboard.setData(ClipboardData(text: text));
    _soundService.play(SoundType.copy);
    HapticFeedback.mediumImpact();

    // Log analytics
    _analytics.logStarterCopied(index: index);

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
              'Kopyalandi! Simdi git yaz',
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

  Future<void> _shareAsImage(BuildContext context) async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/vibe_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      // Log analytics
      _analytics.logShareResult(method: 'image');

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: "Senin vibe tipin ne? Profile Whisperer'da kesfet!",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylasim hatasi: $e'),
          backgroundColor: SeductiveColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = context.watch<AnalysisProvider>().result;

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
                        // Share as image button
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SeductiveColors.velvetPurple,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    SeductiveColors.neonMagenta.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.image_rounded,
                              color: SeductiveColors.lunarWhite,
                              size: 20,
                            ),
                          ),
                          onPressed: () => _shareAsImage(context),
                        ),
                        // Share text button
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
                          onPressed: () => _shareResult(context, result),
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
                                  // Vibe Card with screenshot wrapper
                                  Screenshot(
                                    controller: _screenshotController,
                                    child: Container(
                                      color: SeductiveColors.voidBlack,
                                      child: VibeCard(result: result),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Conversation Starters Title
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient:
                                              SeductiveColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: SeductiveColors.neonGlow(
                                            color: SeductiveColors.neonMagenta,
                                            blur: 10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.bolt_rounded,
                                          color: SeductiveColors.lunarWhite,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const GradientText(
                                            'Silahlarin',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            gradient:
                                                SeductiveColors.primaryGradient,
                                          ),
                                          Text(
                                            'sec, kopyala, at',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: SeductiveColors.dustyRose,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Category filter chips
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // "All" chip
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8),
                                          child: _buildCategoryChip(
                                            context,
                                            emoji: '',
                                            name: 'Hepsi',
                                            color: SeductiveColors.neonMagenta,
                                            isSelected:
                                                _selectedCategoryIndex == -1,
                                            onTap: () => setState(
                                                () => _selectedCategoryIndex = -1),
                                          ),
                                        ),
                                        // Category chips
                                        ..._categories.asMap().entries.map((entry) {
                                          final cat = entry.value;
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: _buildCategoryChip(
                                              context,
                                              emoji: cat['emoji'],
                                              name: cat['name'],
                                              color: cat['color'],
                                              isSelected:
                                                  _selectedCategoryIndex ==
                                                      entry.key,
                                              onTap: () => setState(() =>
                                                  _selectedCategoryIndex =
                                                      entry.key),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Swipeable starters
                                  SizedBox(
                                    height: 180,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount:
                                          result.conversationStarters.length,
                                      onPageChanged: (index) {
                                        setState(
                                            () => _currentStarterIndex = index);
                                        HapticFeedback.selectionClick();
                                      },
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: _buildSwipeableStarterCard(
                                            context,
                                            index + 1,
                                            result.conversationStarters[index],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Page indicator dots
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      result.conversationStarters.length,
                                      (index) => AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 3),
                                        width: _currentStarterIndex == index
                                            ? 20
                                            : 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          gradient:
                                              _currentStarterIndex == index
                                                  ? SeductiveColors
                                                      .primaryGradient
                                                  : null,
                                          color: _currentStarterIndex == index
                                              ? null
                                              : SeductiveColors.smokyViolet,
                                          boxShadow: _currentStarterIndex ==
                                                  index
                                              ? SeductiveColors.neonGlow(
                                                  color:
                                                      SeductiveColors.neonMagenta,
                                                  blur: 8,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Swipe hint
                                  const Text(
                                    ' kaydir ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: SeductiveColors.dustyRose,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  // Try Another Button
                                  GlowButton(
                                    text: l10n.tryAnother,
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

  Widget _buildCategoryChip(
    BuildContext context, {
    required String emoji,
    required String name,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : SeductiveColors.velvetPurple,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? SeductiveColors.lunarWhite
                    : SeductiveColors.silverMist,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeableStarterCard(
    BuildContext context,
    int number,
    String text,
  ) {
    final labels = [
      {'emoji': '', 'name': 'Merak', 'color': const Color(0xFF5C6BC0)},
      {'emoji': '', 'name': 'Sakaci', 'color': const Color(0xFFFF7043)},
      {'emoji': '', 'name': 'Komik', 'color': const Color(0xFFFFCA28)},
      {'emoji': '', 'name': 'Smooth', 'color': const Color(0xFF26A69A)},
      {'emoji': '', 'name': 'Cesur', 'color': const Color(0xFFEF5350)},
    ];
    final label = number <= labels.length ? labels[number - 1] : labels[0];

    return GestureDetector(
      onTap: () => _copyToClipboard(context, text, index: number),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (label['color'] as Color).withOpacity(0.2),
              SeductiveColors.velvetPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (label['color'] as Color).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: (label['color'] as Color).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: label['color'] as Color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (label['color'] as Color).withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label['emoji'] as String,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: SeductiveColors.lunarWhite,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Copy hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: (label['color'] as Color).withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  'kopyalamak icin dokun',
                  style: TextStyle(
                    fontSize: 12,
                    color: (label['color'] as Color).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult(BuildContext context, result) {
    // Log analytics
    _analytics.logShareResult(method: 'text');

    final text = '''${result.vibeEmoji} ${result.vibeType}

${result.description}

ROAST: "${result.roast}"

Tehlike: ${result.redFlags.join(' - ')}
Firsat: ${result.greenFlags.join(' - ')}

${result.compatibility}

Senin vibe tipin ne? Profile Whisperer'da kesfet!''';
    Share.share(text);
  }
}
