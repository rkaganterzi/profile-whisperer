import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';

/// ScanlineEffect - Vertical scanline that moves top to bottom
class ScanlineEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? scanlineColor;
  final double scanlineHeight;
  final bool repeat;

  const ScanlineEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.scanlineColor,
    this.scanlineHeight = 3,
    this.repeat = true,
  });

  @override
  State<ScanlineEffect> createState() => _ScanlineEffectState();
}

class _ScanlineEffectState extends State<ScanlineEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.repeat) {
      _controller.repeat();
    } else {
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
    final color = widget.scanlineColor ?? SeductiveColors.neonMagenta;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ScanlinePainter(
                    progress: _animation.value,
                    color: color,
                    scanlineHeight: widget.scanlineHeight,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double scanlineHeight;

  _ScanlinePainter({
    required this.progress,
    required this.color,
    required this.scanlineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;

    // Main scanline
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withOpacity(0.8),
          color,
          color.withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, y - scanlineHeight, size.width, scanlineHeight * 2));

    canvas.drawRect(
      Rect.fromLTWH(0, y - scanlineHeight / 2, size.width, scanlineHeight),
      scanPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawRect(
      Rect.fromLTWH(0, y - 15, size.width, 30),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// CRTEffect - CRT monitor scanlines overlay
class CRTEffect extends StatelessWidget {
  final Widget child;
  final double lineSpacing;
  final double opacity;

  const CRTEffect({
    super.key,
    required this.child,
    this.lineSpacing = 4,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CRTPainter(
                lineSpacing: lineSpacing,
                opacity: opacity,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CRTPainter extends CustomPainter {
  final double lineSpacing;
  final double opacity;

  _CRTPainter({required this.lineSpacing, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_CRTPainter oldDelegate) {
    return oldDelegate.lineSpacing != lineSpacing || oldDelegate.opacity != opacity;
  }
}

/// HackerScanline - Multiple scanlines moving in different directions
class HackerScanline extends StatefulWidget {
  final Widget child;
  final int lineCount;

  const HackerScanline({
    super.key,
    required this.child,
    this.lineCount = 3,
  });

  @override
  State<HackerScanline> createState() => _HackerScanlineState();
}

class _HackerScanlineState extends State<HackerScanline>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.lineCount,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500 + i * 500),
      )..repeat(),
    );

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(c);
    }).toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge(_controllers),
              builder: (context, _) {
                return CustomPaint(
                  painter: _HackerScanlinePainter(
                    progresses: _animations.map((a) => a.value).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HackerScanlinePainter extends CustomPainter {
  final List<double> progresses;

  _HackerScanlinePainter({required this.progresses});

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      SeductiveColors.neonMagenta,
      SeductiveColors.neonCyan,
      SeductiveColors.neonPurple,
    ];

    for (int i = 0; i < progresses.length; i++) {
      final y = progresses[i] * size.height;
      final color = colors[i % colors.length];

      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawRect(
        Rect.fromLTWH(0, y - 1, size.width, 2),
        paint,
      );

      // Brighter center
      final brightPaint = Paint()..color = color.withOpacity(0.6);
      canvas.drawRect(
        Rect.fromLTWH(0, y - 0.5, size.width, 1),
        brightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HackerScanlinePainter oldDelegate) {
    return true;
  }
}
