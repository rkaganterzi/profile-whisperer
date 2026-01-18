import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/seductive_colors.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/effects/light_leak.dart';
import '../animations/page_transitions.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      emoji: '🔮',
      title: 'Profile Whisperer',
      subtitle: 'Kesfet. Coz. Fethet.',
      description: 'Instagram profillerini AI ile analiz et, gizemlerini coz!',
      color: SeductiveColors.neonMagenta,
    ),
    OnboardingPage(
      emoji: '📡',
      title: 'Screenshot veya Link',
      subtitle: 'Iki yol, bir hedef',
      description: 'Profil linkini yapistir veya screenshot yukle. Gerisini bize birak!',
      color: SeductiveColors.neonPurple,
    ),
    OnboardingPage(
      emoji: '🧠',
      title: 'Derin Analiz',
      subtitle: 'AI destekli tarama',
      description: 'Kisilik analizi, tehlike isaretleri ve firsatlari kesfet.',
      color: SeductiveColors.neonCyan,
    ),
    OnboardingPage(
      emoji: '💬',
      title: 'Silahlarin',
      subtitle: 'Hazir mesajlar',
      description: 'AI\'in hazirladigi kisiye ozel acilis repliklerini kopyala ve at!',
      color: SeductiveColors.neonCoral,
    ),
    OnboardingPage(
      emoji: '🚀',
      title: 'Hazir misin?',
      subtitle: 'Hadi baslayalim!',
      description: 'Ilk taramani yap ve sirlari coz!',
      color: SeductiveColors.neonMagenta,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        SeductivePageRoute(page: const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedLightLeak(
          intensity: 0.2,
          child: Stack(
            children: [
              // Background gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _pages[_currentPage].color.withOpacity(0.15),
                      SeductiveColors.voidBlack,
                      SeductiveColors.voidBlack,
                    ],
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Skip button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentPage < _pages.length - 1)
                            TextButton(
                              onPressed: _completeOnboarding,
                              child: const Text(
                                'Atla',
                                style: TextStyle(
                                  color: SeductiveColors.dustyRose,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Page view
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                          HapticFeedback.selectionClick();
                        },
                        itemBuilder: (context, index) {
                          return _buildPage(_pages[index], index);
                        },
                      ),
                    ),
                    // Bottom section
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Page indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: _currentPage == index
                                      ? _pages[_currentPage].color
                                      : SeductiveColors.smokyViolet,
                                  boxShadow: _currentPage == index
                                      ? [
                                          BoxShadow(
                                            color: _pages[_currentPage]
                                                .color
                                                .withOpacity(0.5),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Next/Start button
                          SizedBox(
                            width: double.infinity,
                            child: _currentPage == _pages.length - 1
                                ? _buildStartButton()
                                : _buildNextButton(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated emoji container
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_bounceAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    page.color.withOpacity(0.3),
                    page.color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: SeductiveColors.neonGlow(
                  color: page.color,
                  blur: 25,
                ),
                border: Border.all(
                  color: page.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  page.emoji,
                  style: const TextStyle(fontSize: 70),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Title
          NeonText(
            page.title,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            glowColor: page.color,
            glowIntensity: 0.5,
          ),
          const SizedBox(height: 12),
          // Subtitle badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: page.color.withOpacity(0.3),
              ),
            ),
            child: Text(
              page.subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: page.color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: SeductiveColors.silverMist,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return GlowButton(
      text: 'Devam',
      icon: Icons.arrow_forward_rounded,
      glowColor: _pages[_currentPage].color,
      gradient: LinearGradient(
        colors: [
          _pages[_currentPage].color,
          _pages[_currentPage].color.withOpacity(0.8),
        ],
      ),
      animate: false,
      onPressed: () {
        HapticFeedback.lightImpact();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      },
    );
  }

  Widget _buildStartButton() {
    return GlowButton(
      text: 'Basla',
      icon: Icons.rocket_launch_rounded,
      gradient: SeductiveColors.primaryGradient,
      animate: true,
      onPressed: () {
        HapticFeedback.mediumImpact();
        _completeOnboarding();
      },
    );
  }
}

class OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
