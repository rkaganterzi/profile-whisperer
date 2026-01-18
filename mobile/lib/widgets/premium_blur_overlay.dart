import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/seductive_colors.dart';

/// A widget that shows a blur overlay with "Premium ile Ac" button
/// for locked content
class PremiumBlurOverlay extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final VoidCallback? onUnlock;
  final double blurSigma;
  final String? customText;
  final IconData? customIcon;

  const PremiumBlurOverlay({
    super.key,
    required this.child,
    required this.isLocked,
    this.onUnlock,
    this.blurSigma = 8.0,
    this.customText,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) {
      return child;
    }

    return Stack(
      children: [
        // Blurred content
        ClipRect(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurSigma,
              sigmaY: blurSigma,
            ),
            child: child,
          ),
        ),
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  SeductiveColors.voidBlack.withOpacity(0.3),
                  SeductiveColors.voidBlack.withOpacity(0.6),
                ],
              ),
            ),
            child: Center(
              child: GestureDetector(
                onTap: onUnlock,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: SeductiveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: SeductiveColors.neonGlow(
                      color: SeductiveColors.neonMagenta,
                      blur: 15,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        customIcon ?? Icons.lock_open_rounded,
                        color: SeductiveColors.lunarWhite,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        customText ?? 'Premium ile Ac',
                        style: const TextStyle(
                          color: SeductiveColors.lunarWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A smaller version of the blur overlay for inline content
class PremiumBlurBadge extends StatelessWidget {
  final Widget child;
  final bool isLocked;
  final VoidCallback? onUnlock;

  const PremiumBlurBadge({
    super.key,
    required this.child,
    required this.isLocked,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLocked) {
      return child;
    }

    return GestureDetector(
      onTap: onUnlock,
      child: Stack(
        children: [
          // Blurred content
          ClipRect(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: child,
            ),
          ),
          // Lock icon overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: SeductiveColors.voidBlack.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: SeductiveColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: SeductiveColors.lunarWhite,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
