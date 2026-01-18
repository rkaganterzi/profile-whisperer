import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';

/// GlassCard - Glassmorphism effect card with blur and gradient border
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final double opacity;
  final bool showBorder;
  final Color? borderColor;
  final Gradient? borderGradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blur = 10,
    this.opacity = 0.1,
    this.showBorder = true,
    this.borderColor,
    this.borderGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(opacity),
                    Colors.white.withOpacity(opacity * 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: showBorder
                    ? Border.all(
                        color: borderColor ??
                            SeductiveColors.neonMagenta.withOpacity(0.3),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// GlassCardAnimated - GlassCard with animated gradient border
class GlassCardAnimated extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const GlassCardAnimated({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blur = 10,
    this.animationDuration = const Duration(seconds: 3),
    this.onTap,
  });

  @override
  State<GlassCardAnimated> createState() => _GlassCardAnimatedState();
}

class _GlassCardAnimatedState extends State<GlassCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: SweepGradient(
                center: Alignment.center,
                startAngle: _animation.value * 6.28,
                colors: const [
                  SeductiveColors.neonMagenta,
                  SeductiveColors.neonPurple,
                  SeductiveColors.neonCoral,
                  SeductiveColors.neonMagenta,
                ],
              ),
              boxShadow: SeductiveColors.neonGlow(
                color: SeductiveColors.neonMagenta,
                blur: 15,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: SeductiveColors.velvetPurple,
                borderRadius: BorderRadius.circular(widget.borderRadius - 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius - 2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blur,
                    sigmaY: widget.blur,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: SeductiveColors.glassGradient,
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius - 2),
                    ),
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
