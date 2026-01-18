import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';

/// GlowingBorder - Animated neon border effect
class GlowingBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? colors;
  final Duration duration;
  final double glowBlur;
  final bool animate;

  const GlowingBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.colors,
    this.duration = const Duration(seconds: 3),
    this.glowBlur = 15,
    this.animate = true,
  });

  @override
  State<GlowingBorder> createState() => _GlowingBorderState();
}

class _GlowingBorderState extends State<GlowingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          SeductiveColors.neonMagenta,
          SeductiveColors.neonPurple,
          SeductiveColors.neonCoral,
          SeductiveColors.neonMagenta,
        ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: widget.glowBlur,
                spreadRadius: 0,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _GlowingBorderPainter(
              progress: widget.animate ? _controller.value : 0,
              borderRadius: widget.borderRadius,
              borderWidth: widget.borderWidth,
              colors: colors,
            ),
            child: Container(
              margin: EdgeInsets.all(widget.borderWidth),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _GlowingBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;
  final List<Color> colors;

  _GlowingBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final gradient = SweepGradient(
      startAngle: progress * 2 * math.pi,
      colors: colors,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlowingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// PulsatingBorder - Border that pulses in opacity
class PulsatingBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Color color;
  final Duration duration;

  const PulsatingBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.color = SeductiveColors.neonMagenta,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsatingBorder> createState() => _PulsatingBorderState();
}

class _PulsatingBorderState extends State<PulsatingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.color.withOpacity(_animation.value),
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_animation.value * 0.3),
                blurRadius: 15,
                spreadRadius: 0,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// NeonOutline - Static neon outline with glow
class NeonOutline extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double borderWidth;
  final Color color;
  final double glowIntensity;

  const NeonOutline({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderWidth = 2,
    this.color = SeductiveColors.neonMagenta,
    this.glowIntensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6 * glowIntensity),
            blurRadius: 10,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: color.withOpacity(0.3 * glowIntensity),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
