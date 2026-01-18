import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';
import '../../theme/seductive_theme.dart';

/// AILoadingIndicator - AI-themed loading animation with brain/neural icon
class AILoadingIndicator extends StatefulWidget {
  final double size;
  final String? text;
  final Color? color;

  const AILoadingIndicator({
    super.key,
    this.size = 100,
    this.text,
    this.color,
  });

  @override
  State<AILoadingIndicator> createState() => _AILoadingIndicatorState();
}

class _AILoadingIndicatorState extends State<AILoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? SeductiveColors.neonMagenta;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _rotateController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating rings
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _NeuralRingPainter(
                          color: color,
                          progress: _rotateController.value,
                        ),
                      ),
                    ),
                    // Center icon
                    Container(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      decoration: BoxDecoration(
                        gradient: SeductiveColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology_rounded,
                        size: widget.size * 0.3,
                        color: SeductiveColors.lunarWhite,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.text != null) ...[
          const SizedBox(height: 24),
          _AnimatedLoadingText(text: widget.text!),
        ],
      ],
    );
  }
}

class _NeuralRingPainter extends CustomPainter {
  final Color color;
  final double progress;

  _NeuralRingPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final outerPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 5, outerPaint);

    // Inner ring with dash effect
    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 15);

    // Draw multiple arcs for dash effect
    for (int i = 0; i < 6; i++) {
      final startAngle = (i * math.pi / 3) + progress * 2 * math.pi;
      canvas.drawArc(rect, startAngle, math.pi / 6, false, innerPaint);
    }

    // Neural nodes
    final nodePaint = Paint()..color = color;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + progress * math.pi;
      final nodeRadius = radius - 25;
      final nodePos = Offset(
        center.dx + nodeRadius * math.cos(angle),
        center.dy + nodeRadius * math.sin(angle),
      );
      canvas.drawCircle(nodePos, 3, nodePaint);
    }
  }

  @override
  bool shouldRepaint(_NeuralRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AnimatedLoadingText extends StatefulWidget {
  final String text;

  const _AnimatedLoadingText({required this.text});

  @override
  State<_AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<_AnimatedLoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.text}${'.' * _dotCount}',
      style: const TextStyle(
        color: SeductiveColors.silverMist,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// CircularPulseLoader - Simple pulsing circle loader
class CircularPulseLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CircularPulseLoader({
    super.key,
    this.size = 50,
    this.color,
  });

  @override
  State<CircularPulseLoader> createState() => _CircularPulseLoaderState();
}

class _CircularPulseLoaderState extends State<CircularPulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? SeductiveColors.neonMagenta;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing ring
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(_opacityAnimation.value),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
          // Center dot
          Container(
            width: widget.size * 0.3,
            height: widget.size * 0.3,
            decoration: BoxDecoration(
              gradient: SeductiveColors.primaryGradient,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

/// DataStreamLoader - Matrix-style data stream effect
class DataStreamLoader extends StatefulWidget {
  final double width;
  final double height;
  final String? label;

  const DataStreamLoader({
    super.key,
    this.width = 200,
    this.height = 100,
    this.label,
  });

  @override
  State<DataStreamLoader> createState() => _DataStreamLoaderState();
}

class _DataStreamLoaderState extends State<DataStreamLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _DataStreamPainter(
                  progress: _controller.value,
                  color: SeductiveColors.neonMagenta,
                ),
              );
            },
          ),
        ),
        if (widget.label != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.label!,
            style: const TextStyle(
              color: SeductiveColors.silverMist,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }
}

class _DataStreamPainter extends CustomPainter {
  final double progress;
  final Color color;

  _DataStreamPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final columns = 20;
    final columnWidth = size.width / columns;

    for (int i = 0; i < columns; i++) {
      final offset = (progress + i * 0.1) % 1.0;
      final height = size.height * (0.3 + offset * 0.7);

      final paint = Paint()
        ..color = color.withOpacity(0.3 + offset * 0.5)
        ..strokeWidth = columnWidth * 0.3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(i * columnWidth + columnWidth / 2, size.height - height),
        Offset(i * columnWidth + columnWidth / 2, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DataStreamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
