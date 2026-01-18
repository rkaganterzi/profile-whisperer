import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/seductive_colors.dart';

/// ParticleBackground - Floating particles effect
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color? particleColor;
  final double maxParticleSize;
  final double minParticleSize;
  final Duration animationDuration;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 30,
    this.particleColor,
    this.maxParticleSize = 4,
    this.minParticleSize = 1,
    this.animationDuration = const Duration(seconds: 20),
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (_) => _createParticle(),
    );
  }

  Particle _createParticle() {
    return Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: widget.minParticleSize +
          _random.nextDouble() * (widget.maxParticleSize - widget.minParticleSize),
      speed: 0.5 + _random.nextDouble() * 1.5,
      opacity: 0.3 + _random.nextDouble() * 0.5,
      angle: _random.nextDouble() * 2 * pi,
    );
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
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _controller.value,
                    color: widget.particleColor ?? SeductiveColors.neonMagenta,
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

class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.angle,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate position based on progress
      final offsetX = sin(progress * 2 * pi + particle.angle) * 0.02;
      final offsetY = cos(progress * 2 * pi + particle.angle) * 0.02;

      // Float upward slowly
      final y = (particle.y - progress * particle.speed * 0.1) % 1.0;

      final x = (particle.x + offsetX) % 1.0;
      final actualY = (y + offsetY) % 1.0;

      final paint = Paint()
        ..color = color.withOpacity(particle.opacity * (1 - (progress * 0.3)))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x * size.width, actualY * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// StarField - Twinkling stars background
class StarField extends StatefulWidget {
  final Widget child;
  final int starCount;
  final Color starColor;

  const StarField({
    super.key,
    required this.child,
    this.starCount = 50,
    this.starColor = SeductiveColors.lunarWhite,
  });

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _stars = List.generate(widget.starCount, (_) => _createStar());
  }

  Star _createStar() {
    return Star(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 0.5 + _random.nextDouble() * 2,
      twinkleOffset: _random.nextDouble() * 2 * pi,
      twinkleSpeed: 0.5 + _random.nextDouble() * 2,
    );
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
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: StarPainter(
                    stars: _stars,
                    progress: _controller.value,
                    color: widget.starColor,
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

class Star {
  final double x;
  final double y;
  final double size;
  final double twinkleOffset;
  final double twinkleSpeed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleOffset,
    required this.twinkleSpeed,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;
  final Color color;

  StarPainter({
    required this.stars,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      final twinkle = sin(progress * 2 * pi * star.twinkleSpeed + star.twinkleOffset);
      final opacity = 0.3 + (twinkle + 1) / 2 * 0.7;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// BokehBackground - Soft bokeh light effect
class BokehBackground extends StatefulWidget {
  final Widget child;
  final int bokehCount;
  final List<Color>? colors;

  const BokehBackground({
    super.key,
    required this.child,
    this.bokehCount = 10,
    this.colors,
  });

  @override
  State<BokehBackground> createState() => _BokehBackgroundState();
}

class _BokehBackgroundState extends State<BokehBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<BokehCircle> _circles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final colors = widget.colors ??
        [
          SeductiveColors.neonMagenta,
          SeductiveColors.neonPurple,
          SeductiveColors.neonCoral,
        ];

    _circles = List.generate(widget.bokehCount, (_) {
      return BokehCircle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 30 + _random.nextDouble() * 100,
        color: colors[_random.nextInt(colors.length)],
        speed: 0.2 + _random.nextDouble() * 0.5,
        angle: _random.nextDouble() * 2 * pi,
      );
    });
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
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: BokehPainter(
                    circles: _circles,
                    progress: _controller.value,
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

class BokehCircle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double angle;

  BokehCircle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
  });
}

class BokehPainter extends CustomPainter {
  final List<BokehCircle> circles;
  final double progress;

  BokehPainter({
    required this.circles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final circle in circles) {
      final offsetX = sin(progress * 2 * pi + circle.angle) * 30;
      final offsetY = cos(progress * 2 * pi + circle.angle) * 30;

      final paint = Paint()
        ..color = circle.color.withOpacity(0.1)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, circle.size / 3);

      canvas.drawCircle(
        Offset(
          circle.x * size.width + offsetX,
          circle.y * size.height + offsetY,
        ),
        circle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BokehPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
