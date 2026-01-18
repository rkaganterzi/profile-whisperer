import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// GrainOverlay - Adds a subtle film grain texture effect
class GrainOverlay extends StatefulWidget {
  final Widget child;
  final double opacity;
  final bool animate;
  final Duration animationDuration;

  const GrainOverlay({
    super.key,
    required this.child,
    this.opacity = 0.05,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    if (widget.animate) {
      _controller.addListener(() {
        if (_controller.status == AnimationStatus.completed) {
          setState(() {
            _seed = Random().nextInt(1000);
          });
          _controller.reset();
          _controller.forward();
        }
      });
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
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: GrainPainter(
                opacity: widget.opacity,
                seed: _seed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for grain effect
class GrainPainter extends CustomPainter {
  final double opacity;
  final int seed;

  GrainPainter({
    this.opacity = 0.05,
    this.seed = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint()..strokeWidth = 1;

    // Draw random noise dots
    for (int i = 0; i < (size.width * size.height * 0.02).toInt(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final brightness = random.nextDouble();

      paint.color = Color.fromRGBO(
        255,
        255,
        255,
        brightness * opacity,
      );

      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(GrainPainter oldDelegate) {
    return oldDelegate.seed != seed || oldDelegate.opacity != opacity;
  }
}

/// StaticGrainOverlay - Non-animated grain overlay (lighter performance)
class StaticGrainOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;

  const StaticGrainOverlay({
    super.key,
    required this.child,
    this.opacity = 0.03,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/noise.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// VignetteOverlay - Adds a vignette (dark corners) effect
class VignetteOverlay extends StatelessWidget {
  final Widget child;
  final double intensity;
  final Color color;

  const VignetteOverlay({
    super.key,
    required this.child,
    this.intensity = 0.5,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    color.withOpacity(intensity * 0.3),
                    color.withOpacity(intensity * 0.6),
                  ],
                  stops: const [0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// CombinedOverlay - Combines grain and vignette effects
class CombinedOverlay extends StatelessWidget {
  final Widget child;
  final double grainOpacity;
  final double vignetteIntensity;
  final bool animateGrain;

  const CombinedOverlay({
    super.key,
    required this.child,
    this.grainOpacity = 0.03,
    this.vignetteIntensity = 0.3,
    this.animateGrain = false,
  });

  @override
  Widget build(BuildContext context) {
    return VignetteOverlay(
      intensity: vignetteIntensity,
      child: GrainOverlay(
        opacity: grainOpacity,
        animate: animateGrain,
        child: child,
      ),
    );
  }
}
