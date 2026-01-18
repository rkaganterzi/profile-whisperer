import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';

/// LightLeak - Creates subtle light leak effects in corners
class LightLeak extends StatelessWidget {
  final Widget child;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;
  final double intensity;
  final double size;

  const LightLeak({
    super.key,
    required this.child,
    this.topLeft = true,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = true,
    this.intensity = 0.3,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (topLeft) _buildLeak(Alignment.topLeft),
        if (topRight) _buildLeak(Alignment.topRight),
        if (bottomLeft) _buildLeak(Alignment.bottomLeft),
        if (bottomRight) _buildLeak(Alignment.bottomRight),
      ],
    );
  }

  Widget _buildLeak(Alignment alignment) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  SeductiveColors.neonMagenta.withOpacity(intensity),
                  SeductiveColors.neonPurple.withOpacity(intensity * 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// AnimatedLightLeak - Light leak with subtle animation
class AnimatedLightLeak extends StatefulWidget {
  final Widget child;
  final double intensity;
  final Duration duration;

  const AnimatedLightLeak({
    super.key,
    required this.child,
    this.intensity = 0.25,
    this.duration = const Duration(seconds: 4),
  });

  @override
  State<AnimatedLightLeak> createState() => _AnimatedLightLeakState();
}

class _AnimatedLightLeakState extends State<AnimatedLightLeak>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(
      begin: widget.intensity * 0.7,
      end: widget.intensity,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _positionAnimation = Tween<double>(begin: 0, end: 20).animate(
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
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            widget.child,
            // Top left leak
            Positioned(
              top: -50 + _positionAnimation.value,
              left: -50 + _positionAnimation.value,
              child: _buildAnimatedLeak(_opacityAnimation.value),
            ),
            // Bottom right leak
            Positioned(
              bottom: -50 + _positionAnimation.value,
              right: -50 + _positionAnimation.value,
              child: _buildAnimatedLeak(
                _opacityAnimation.value * 0.8,
                color: SeductiveColors.neonPurple,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLeak(double opacity, {Color? color}) {
    return IgnorePointer(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              (color ?? SeductiveColors.neonMagenta).withOpacity(opacity),
              (color ?? SeductiveColors.neonMagenta).withOpacity(opacity * 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

/// CornerGlow - Single corner glow effect
class CornerGlow extends StatelessWidget {
  final Alignment position;
  final Color color;
  final double size;
  final double opacity;

  const CornerGlow({
    super.key,
    required this.position,
    this.color = SeductiveColors.neonMagenta,
    this.size = 200,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: position,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.7,
                colors: [
                  color.withOpacity(opacity),
                  color.withOpacity(opacity * 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
