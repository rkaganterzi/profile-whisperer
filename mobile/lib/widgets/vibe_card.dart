import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../theme/seductive_colors.dart';
import 'premium_blur_overlay.dart';

class VibeCard extends StatefulWidget {
  final AnalysisResult result;
  final bool isPremium;
  final VoidCallback? onUnlockFlags;

  const VibeCard({
    super.key,
    required this.result,
    this.isPremium = true,
    this.onUnlockFlags,
  });

  @override
  State<VibeCard> createState() => _VibeCardState();
}

class _VibeCardState extends State<VibeCard> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: SeductiveColors.velvetPurple,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: SeductiveColors.neonMagenta.withOpacity(_glowAnimation.value),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gradient header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: const BoxDecoration(
                    gradient: SeductiveColors.primaryGradient,
                  ),
                  child: Column(
                    children: [
                      // Emoji
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            widget.result.vibeEmoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Vibe Type
                      Text(
                        widget.result.vibeType,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: SeductiveColors.lunarWhite,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Energy badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.result.energy,
                          style: const TextStyle(
                            color: SeductiveColors.lunarWhite,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Content area with glass effect
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: SeductiveColors.velvetPurple.withOpacity(0.9),
                        border: Border(
                          top: BorderSide(
                            color: SeductiveColors.neonMagenta.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description
                          Text(
                            widget.result.description,
                            style: const TextStyle(
                              fontSize: 15,
                              color: SeductiveColors.silverMist,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          // Roast section
                          if (widget.result.roast.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    SeductiveColors.neonCoral.withOpacity(0.2),
                                    SeductiveColors.neonMagenta.withOpacity(0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: SeductiveColors.neonMagenta.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: SeductiveColors.buttonGradient,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'ROAST',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: SeductiveColors.lunarWhite,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.result.roast,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: SeductiveColors.lunarWhite,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          // Red & Green Flags (Tehlike & Firsat)
                          PremiumBlurOverlay(
                            isLocked: !widget.isPremium,
                            onUnlock: widget.onUnlockFlags,
                            blurSigma: 6.0,
                            customText: 'Flags\'i Gormek Icin',
                            customIcon: Icons.visibility_rounded,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tehlike (Red Flags)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('⚠️', style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tehlike',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: SeductiveColors.dangerRed,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ...widget.result.redFlags.map((flag) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '• $flag',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: SeductiveColors.dangerRed.withOpacity(0.8),
                                            height: 1.4,
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Firsat (Green Flags)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text('💎', style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Firsat',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: SeductiveColors.successGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ...widget.result.greenFlags.map((flag) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          '• $flag',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: SeductiveColors.successGreen.withOpacity(0.8),
                                            height: 1.4,
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Traits
                          Center(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: widget.result.traits.map((trait) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: SeductiveColors.neonMagenta.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: SeductiveColors.neonMagenta.withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    trait,
                                    style: const TextStyle(
                                      color: SeductiveColors.neonMagenta,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Compatibility
                          if (widget.result.compatibility.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: SeductiveColors.neonPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: SeductiveColors.neonPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text('💕', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.result.compatibility,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: SeductiveColors.neonPurple.withOpacity(0.9),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          // Branding
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      SeductiveColors.primaryGradient.createShader(bounds),
                                  child: const Icon(
                                    Icons.psychology_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'HuysuzApp',
                                  style: TextStyle(
                                    color: SeductiveColors.dustyRose,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
