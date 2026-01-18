import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';
import '../../theme/seductive_theme.dart';

/// NeonText - Text with glowing neon effect using multiple shadows
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Color? glowColor;
  final double glowIntensity;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const NeonText(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.glowColor,
    this.glowIntensity = 1.0,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? SeductiveColors.lunarWhite;
    final effectiveGlowColor = glowColor ?? SeductiveColors.neonMagenta;

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: effectiveColor,
        shadows: [
          // Inner glow
          Shadow(
            color: effectiveGlowColor.withOpacity(0.8 * glowIntensity),
            blurRadius: 4,
          ),
          // Middle glow
          Shadow(
            color: effectiveGlowColor.withOpacity(0.6 * glowIntensity),
            blurRadius: 10,
          ),
          // Outer glow
          Shadow(
            color: effectiveGlowColor.withOpacity(0.4 * glowIntensity),
            blurRadius: 20,
          ),
          // Distant glow
          Shadow(
            color: effectiveGlowColor.withOpacity(0.2 * glowIntensity),
            blurRadius: 40,
          ),
        ],
      ),
    );
  }
}

/// AnimatedNeonText - NeonText with pulsating glow animation
class AnimatedNeonText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Color? glowColor;
  final Duration duration;
  final TextAlign textAlign;

  const AnimatedNeonText(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.glowColor,
    this.duration = const Duration(milliseconds: 2000),
    this.textAlign = TextAlign.center,
  });

  @override
  State<AnimatedNeonText> createState() => _AnimatedNeonTextState();
}

class _AnimatedNeonTextState extends State<AnimatedNeonText>
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

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
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
        return NeonText(
          widget.text,
          fontSize: widget.fontSize,
          fontWeight: widget.fontWeight,
          color: widget.color,
          glowColor: widget.glowColor,
          glowIntensity: _animation.value,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

/// GradientText - Text with gradient fill
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Gradient? gradient;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.gradient,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          (gradient ?? SeductiveColors.primaryGradient).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white, // This color will be masked by the gradient
        ),
      ),
    );
  }
}

/// GlitchText - Text with glitch/cyberpunk effect
class GlitchText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final bool animate;

  const GlitchText(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.color,
    this.animate = true,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glitchAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _glitchAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.animate) {
      _startGlitchLoop();
    }
  }

  void _startGlitchLoop() async {
    while (mounted && widget.animate) {
      await Future.delayed(Duration(milliseconds: 2000 + (500 * (DateTime.now().millisecond % 3))));
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) _controller.reverse();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? SeductiveColors.lunarWhite;

    return AnimatedBuilder(
      animation: _glitchAnimation,
      builder: (context, child) {
        final glitchOffset = _glitchAnimation.value * 3;

        return Stack(
          children: [
            // Cyan offset
            Transform.translate(
              offset: Offset(-glitchOffset, 0),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  color: SeductiveColors.neonCyan.withOpacity(
                    _glitchAnimation.value * 0.7,
                  ),
                ),
              ),
            ),
            // Magenta offset
            Transform.translate(
              offset: Offset(glitchOffset, 0),
              child: Text(
                widget.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: widget.fontWeight,
                  color: SeductiveColors.neonMagenta.withOpacity(
                    _glitchAnimation.value * 0.7,
                  ),
                ),
              ),
            ),
            // Main text
            Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: effectiveColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// TypewriterText - Text that types out character by character
class TypewriterText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final Duration charDuration;
  final VoidCallback? onComplete;

  const TypewriterText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.charDuration = const Duration(milliseconds: 50),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    for (int i = 0; i <= widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.charDuration);
      if (mounted) {
        setState(() {
          _displayedText = widget.text.substring(0, i);
          _currentIndex = i;
        });
      }
    }
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _displayedText,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: widget.color ?? SeductiveColors.lunarWhite,
            ),
          ),
          // Blinking cursor
          if (_currentIndex < widget.text.length)
            TextSpan(
              text: '|',
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: widget.fontWeight,
                color: SeductiveColors.neonMagenta,
              ),
            ),
        ],
      ),
    );
  }
}
