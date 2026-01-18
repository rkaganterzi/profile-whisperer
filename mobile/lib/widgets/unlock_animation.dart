import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/seductive_colors.dart';

/// Animated unlock overlay that shows blur disappearing
class UnlockAnimation extends StatefulWidget {
  final Widget child;
  final bool isUnlocking;
  final VoidCallback? onUnlockComplete;
  final Duration duration;

  const UnlockAnimation({
    super.key,
    required this.child,
    required this.isUnlocking,
    this.onUnlockComplete,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<UnlockAnimation> createState() => _UnlockAnimationState();
}

class _UnlockAnimationState extends State<UnlockAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _blurAnimation = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onUnlockComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(UnlockAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocking && !oldWidget.isUnlocking) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final blur = _blurAnimation.value;
        final opacity = _opacityAnimation.value;
        final scale = _scaleAnimation.value;

        return Transform.scale(
          scale: scale,
          child: Stack(
            children: [
              // Content with decreasing blur
              if (blur > 0.1)
                ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: blur,
                      sigmaY: blur,
                    ),
                    child: widget.child,
                  ),
                )
              else
                widget.child,
              // Fading overlay
              if (opacity > 0.01)
                Positioned.fill(
                  child: Container(
                    color: SeductiveColors.voidBlack.withOpacity(opacity),
                  ),
                ),
              // Sparkle effect during unlock
              if (_controller.isAnimating && _controller.value < 0.8)
                Positioned.fill(
                  child: _buildSparkles(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSparkles() {
    return IgnorePointer(
      child: CustomPaint(
        painter: SparklesPainter(
          progress: _controller.value,
          color: SeductiveColors.neonMagenta,
        ),
      ),
    );
  }
}

class SparklesPainter extends CustomPainter {
  final double progress;
  final Color color;

  SparklesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    final random = [0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.4, 0.6, 0.8];

    for (int i = 0; i < 8; i++) {
      final x = size.width * random[i];
      final y = size.height * random[(i + 3) % 9];
      final radius = 3.0 * (1 - progress) + 1;

      canvas.drawCircle(
        Offset(x, y - (progress * 20)),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SparklesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Shimmer effect for premium content reveal
class PremiumShimmer extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PremiumShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<PremiumShimmer> createState() => _PremiumShimmerState();
}

class _PremiumShimmerState extends State<PremiumShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white,
                Colors.white.withOpacity(0.5),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
