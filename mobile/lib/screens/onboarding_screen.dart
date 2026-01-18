import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
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
      emoji: '🔥',
      title: 'Profile Whisperer',
      subtitle: 'Stalk. Anla. Yürü.',
      description: 'Instagram profillerini AI ile analiz et, vibe\'ını keşfet!',
      color: AppTheme.primaryPink,
    ),
    OnboardingPage(
      emoji: '📸',
      title: 'Screenshot veya Link',
      subtitle: 'İki yol, bir sonuç',
      description: 'Profil linkini yapıştır veya screenshot yükle. Gerisini bize bırak!',
      color: AppTheme.primaryOrange,
    ),
    OnboardingPage(
      emoji: '✨',
      title: 'Vibe Analizi',
      subtitle: 'AI destekli analiz',
      description: 'Kişiliği, red/green flag\'leri ve uyumluluk analizini gör.',
      color: AppTheme.accentPurple,
    ),
    OnboardingPage(
      emoji: '💬',
      title: 'Açılış Replikleri',
      subtitle: 'Hazır mesajlar',
      description: 'AI\'ın hazırladığı kişiye özel açılış repliklerini kopyala ve gönder!',
      color: const Color(0xFF26A69A),
    ),
    OnboardingPage(
      emoji: '🚀',
      title: 'Hazır mısın?',
      subtitle: 'Hadi başlayalım!',
      description: 'İlk analizini yap ve vibe\'ını keşfet!',
      color: AppTheme.primaryRed,
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
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
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
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AuthScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _pages[_currentPage].color.withOpacity(isDark ? 0.2 : 0.1),
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pages[_currentPage].color.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pages[_currentPage].color.withOpacity(0.05),
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
                            child: Text(
                              'Atla',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.textGrayDark
                                    : AppTheme.textGray,
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
                        return _buildPage(_pages[index], isDark, index);
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
                                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
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
                              : _buildNextButton(isDark),
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
    );
  }

  Widget _buildPage(OnboardingPage page, bool isDark, int index) {
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
                    page.color.withOpacity(isDark ? 0.3 : 0.2),
                    page.color.withOpacity(isDark ? 0.15 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: page.color.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
                border: Border.all(
                  color: page.color.withOpacity(0.3),
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
          Text(
            page.title,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
            textAlign: TextAlign.center,
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
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(bool isDark) {
    return OutlinedButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18),
        side: BorderSide(
          color: _pages[_currentPage].color,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Devam',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _pages[_currentPage].color,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_rounded,
            color: _pages[_currentPage].color,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            _completeOnboarding();
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Başla',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
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
