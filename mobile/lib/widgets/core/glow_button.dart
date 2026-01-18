import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/seductive_colors.dart';
import '../../theme/seductive_theme.dart';

/// GlowButton - Neon glow effect button with pulsating animation
class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final bool isLoading;
  final bool enabled;
  final IconData? icon;
  final Gradient? gradient;
  final Color? glowColor;
  final double borderRadius;
  final bool animate;

  const GlowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height = 56,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
    this.gradient,
    this.glowColor,
    this.borderRadius = 16,
    this.animate = true,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SeductiveAnimations.glowPulse,
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate && widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GlowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if ((!widget.animate || !widget.enabled) && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ?? SeductiveColors.buttonGradient;
    final effectiveGlowColor = widget.glowColor ?? SeductiveColors.neonMagenta;
    final isEnabled = widget.enabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: isEnabled ? _handleTapDown : null,
          onTapUp: isEnabled ? _handleTapUp : null,
          onTapCancel: isEnabled ? _handleTapCancel : null,
          onTap: isEnabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: SeductiveAnimations.fast,
            curve: Curves.easeOut,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: isEnabled ? effectiveGradient : null,
                color: isEnabled ? null : SeductiveColors.smokyViolet,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: effectiveGlowColor.withOpacity(
                            widget.animate
                                ? _glowAnimation.value
                                : (_isPressed ? 0.8 : 0.5),
                          ),
                          blurRadius: _isPressed ? 25 : 20,
                          spreadRadius: _isPressed ? 2 : 0,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: null, // Handled by GestureDetector
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: SeductiveColors.lunarWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: isEnabled
                                      ? SeductiveColors.lunarWhite
                                      : SeductiveColors.dustyRose,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  color: isEnabled
                                      ? SeductiveColors.lunarWhite
                                      : SeductiveColors.dustyRose,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// GlowIconButton - Circular icon button with glow effect
class GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final Gradient? gradient;
  final Color? glowColor;
  final bool animate;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
    this.iconColor,
    this.gradient,
    this.glowColor,
    this.animate = false,
  });

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SeductiveAnimations.glowPulse,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGlowColor = widget.glowColor ?? SeductiveColors.neonMagenta;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onPressed?.call();
          },
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: SeductiveAnimations.fast,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: widget.gradient ?? SeductiveColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: effectiveGlowColor.withOpacity(
                      widget.animate ? _glowAnimation.value : 0.4,
                    ),
                    blurRadius: 20,
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? SeductiveColors.lunarWhite,
                size: widget.size * 0.45,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// PulsingGlowButton - Large pulsing button (for main CTA like "Tara")
class PulsingGlowButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Gradient? gradient;

  const PulsingGlowButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.size = 200,
    this.gradient,
  });

  @override
  State<PulsingGlowButton> createState() => _PulsingGlowButtonState();
}

class _PulsingGlowButtonState extends State<PulsingGlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.7).animate(
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              widget.onPressed?.call();
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: widget.gradient ?? SeductiveColors.primaryGradient,
                borderRadius: BorderRadius.circular(widget.size / 2),
                boxShadow: [
                  BoxShadow(
                    color: SeductiveColors.neonMagenta
                        .withOpacity(_glowAnimation.value),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: widget.size * 0.28,
                    color: SeductiveColors.lunarWhite,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: SeductiveColors.lunarWhite,
                      fontSize: widget.size * 0.08,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
