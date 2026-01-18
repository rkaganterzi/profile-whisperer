import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/seductive_colors.dart';

class LoadingAnimation extends StatefulWidget {
  const LoadingAnimation({super.key});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  final List<String> _loadingTexts = [
    'Hedefe siziyorum...',
    "Vibe'i analiz ediyorum...",
    'Tehlikeleri ariyorum...',
    'Firsatlari sayiyorum...',
    'Silah hazirliyorum...',
    'Roast hazirliyorum...',
    'Son rotuslar...',
  ];

  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Change text periodically
    _textController.addListener(() {
      if (_textController.value == 0) {
        setState(() {
          _currentTextIndex = (_currentTextIndex + 1) % _loadingTexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated logo
        ScaleTransition(
          scale: _pulseAnimation,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating gradient ring
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * pi,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            SeductiveColors.neonMagenta,
                            SeductiveColors.neonPurple,
                            SeductiveColors.neonWine,
                            SeductiveColors.neonCoral,
                            SeductiveColors.neonMagenta,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Inner circle
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SeductiveColors.voidBlack,
                      boxShadow: [
                        BoxShadow(
                          color: SeductiveColors.neonMagenta
                              .withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Brain/AI icon
              ShaderMask(
                shaderCallback: (bounds) =>
                    SeductiveColors.primaryGradient.createShader(bounds),
                child: const Icon(
                  Icons.psychology_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Animated text with fade
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _loadingTexts[_currentTextIndex],
            key: ValueKey(_currentTextIndex),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: SeductiveColors.lunarWhite,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Progress dots with glow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = sin((_pulseController.value + delay) * pi);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SeductiveColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: SeductiveColors.neonMagenta
                            .withOpacity(0.5 * value.abs()),
                        blurRadius: 10 * value.abs(),
                        spreadRadius: 3 * value.abs(),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// Shimmer effect widget for loading states
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                SeductiveColors.velvetPurple,
                SeductiveColors.smokyViolet,
                SeductiveColors.velvetPurple,
              ],
            ),
          ),
        );
      },
    );
  }
}
