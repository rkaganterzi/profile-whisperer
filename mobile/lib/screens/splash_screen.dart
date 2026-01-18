import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../theme/seductive_colors.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/effects/particle_background.dart';
import '../widgets/loading/ai_loading_indicator.dart';
import '../animations/page_transitions.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _navigateNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    if (!onboardingComplete) {
      Navigator.of(context).pushReplacement(
        SeductivePageRoute(page: const OnboardingScreen()),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.status == AuthStatus.initial ||
        authProvider.status == AuthStatus.loading) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    final isAuthenticated = authProvider.isAuthenticated;

    Navigator.of(context).pushReplacement(
      SeductivePageRoute(
        page: isAuthenticated ? const HomeScreen() : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: ParticleBackground(
        particleCount: 40,
        particleColor: SeductiveColors.neonMagenta.withOpacity(0.5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SeductiveColors.voidBlack,
                SeductiveColors.velvetPurple.withOpacity(0.5),
                SeductiveColors.voidBlack,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo with glow
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: SeductiveColors.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: SeductiveColors.neonGlow(
                                color: SeductiveColors.neonMagenta,
                                blur: 30,
                              ),
                            ),
                            child: const Icon(
                              Icons.psychology_rounded,
                              size: 60,
                              color: SeductiveColors.lunarWhite,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // App name with neon effect
                          const AnimatedNeonText(
                            'Profile Whisperer',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            glowColor: SeductiveColors.neonMagenta,
                          ),
                          const SizedBox(height: 12),
                          // Tagline
                          const Text(
                            'Kesfet. Coz. Fethet.',
                            style: TextStyle(
                              color: SeductiveColors.silverMist,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Loading indicator
                          const CircularPulseLoader(
                            size: 40,
                            color: SeductiveColors.neonMagenta,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
