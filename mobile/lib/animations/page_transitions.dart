import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/seductive_colors.dart';
import '../theme/seductive_theme.dart';

/// SeductivePageRoute - Custom page route with fade + scale + blur transition
class SeductivePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SeductivePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: SeductiveAnimations.pageTransition,
          reverseTransitionDuration: SeductiveAnimations.slow,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _SeductiveTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

class _SeductiveTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _SeductiveTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    ));

    final blurAnimation = Tween<double>(
      begin: 5,
      end: 0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ));

    // Exit animation for previous page
    final exitFade = Tween<double>(
      begin: 1,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeIn,
    ));

    return FadeTransition(
      opacity: exitFade,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: AnimatedBuilder(
            animation: blurAnimation,
            builder: (context, _) {
              if (blurAnimation.value < 0.5) {
                return child;
              }
              return ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: blurAnimation.value,
                  sigmaY: blurAnimation.value,
                ),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// SlideUpPageRoute - Page slides up from bottom with fade
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: SeductiveAnimations.slow,
          reverseTransitionDuration: SeductiveAnimations.normal,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}

/// GlowPageRoute - Page appears with a glow effect
class GlowPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  GlowPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: SeductiveAnimations.verySlow,
          reverseTransitionDuration: SeductiveAnimations.normal,
          opaque: false,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _GlowTransition(
              animation: animation,
              child: child,
            );
          },
        );
}

class _GlowTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _GlowTransition({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    final glowAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    return Stack(
      children: [
        // Glow overlay
        AnimatedBuilder(
          animation: glowAnimation,
          builder: (context, _) {
            return Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        SeductiveColors.neonMagenta
                            .withOpacity(0.3 * glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Page content
        FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      ],
    );
  }
}

/// PortalPageRoute - Page appears through a portal-like effect
class PortalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  PortalPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ));

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Helper function to push with seductive transition
Future<T?> pushSeductive<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(SeductivePageRoute(page: page));
}

/// Helper function to push replacement with seductive transition
Future<T?> pushReplacementSeductive<T>(BuildContext context, Widget page) {
  return Navigator.of(context).pushReplacement(SeductivePageRoute(page: page));
}

/// StaggeredListAnimation - Helper for staggered list item animations
class StaggeredListAnimation extends StatefulWidget {
  final int index;
  final int totalItems;
  final Widget child;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredListAnimation({
    super.key,
    required this.index,
    required this.totalItems,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 400),
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.itemDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation with delay based on index
    Future.delayed(
      Duration(milliseconds: widget.staggerDelay.inMilliseconds * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// RevealAnimation - Widget that reveals with a clip animation
class RevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Axis direction;

  const RevealAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.direction = Axis.vertical,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation>
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
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
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
        return ClipRect(
          child: Align(
            alignment: widget.direction == Axis.vertical
                ? Alignment.topCenter
                : Alignment.centerLeft,
            heightFactor:
                widget.direction == Axis.vertical ? _animation.value : 1,
            widthFactor:
                widget.direction == Axis.horizontal ? _animation.value : 1,
            child: widget.child,
          ),
        );
      },
    );
  }
}
