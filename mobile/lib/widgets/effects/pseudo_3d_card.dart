import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';

/// Pseudo3DCard - Card with 3D depth effect using shadows and gradients
class Pseudo3DCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final Gradient? gradient;
  final bool enableTilt;
  final VoidCallback? onTap;

  const Pseudo3DCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.depth = 8,
    this.baseColor,
    this.gradient,
    this.enableTilt = true,
    this.onTap,
  });

  @override
  State<Pseudo3DCard> createState() => _Pseudo3DCardState();
}

class _Pseudo3DCardState extends State<Pseudo3DCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _isHovered = false;

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enableTilt) return;
    setState(() {
      _rotateY = (details.localPosition.dx - 100) / 1000;
      _rotateX = -(details.localPosition.dy - 100) / 1000;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? SeductiveColors.velvetPurple;

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_rotateX)
          ..rotateY(_rotateY)
          ..scale(_isHovered ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              // Deep shadow for 3D effect
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: Offset(0, widget.depth * 2),
                spreadRadius: -5,
              ),
              // Colored glow
              BoxShadow(
                color: SeductiveColors.neonMagenta.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              children: [
                // Base layer
                Container(
                  decoration: BoxDecoration(
                    gradient: widget.gradient ??
                        LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            baseColor,
                            Color.lerp(
                                baseColor, SeductiveColors.voidBlack, 0.3)!,
                          ],
                        ),
                  ),
                ),
                // Inner shadow (top-left light)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hybrid3DGlassCard - Combines 3D effect with glassmorphism
class Hybrid3DGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Gradient? headerGradient;
  final Widget? header;
  final VoidCallback? onTap;

  const Hybrid3DGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.blur = 10,
    this.headerGradient,
    this.header,
    this.onTap,
  });

  @override
  State<Hybrid3DGlassCard> createState() => _Hybrid3DGlassCardState();
}

class _Hybrid3DGlassCardState extends State<Hybrid3DGlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: SeductiveColors.neonMagenta.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient header
                if (widget.header != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: widget.headerGradient ??
                          SeductiveColors.primaryGradient,
                    ),
                    child: widget.header,
                  ),
                // Glass body
                Flexible(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SeductiveColors.velvetPurple.withOpacity(0.8),
                        border: widget.header == null
                            ? Border.all(
                                color: SeductiveColors.neonMagenta
                                    .withOpacity(0.2),
                                width: 1,
                              )
                            : null,
                      ),
                      padding: widget.padding,
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FloatingCard - Card that appears to float with animated shadow
class FloatingCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Duration animationDuration;

  const FloatingCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends State<FloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
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
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: SeductiveColors.velvetPurple,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20 + _floatAnimation.value,
                  offset: Offset(0, 10 + _floatAnimation.value),
                ),
                BoxShadow(
                  color: SeductiveColors.neonMagenta
                      .withOpacity(0.1 + _floatAnimation.value / 80),
                  blurRadius: 30,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: widget.padding,
            child: widget.child,
          ),
        );
      },
    );
  }
}
