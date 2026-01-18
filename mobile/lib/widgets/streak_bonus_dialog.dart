import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/seductive_colors.dart';
import '../utils/premium_features.dart';
import 'core/glow_button.dart';
import 'core/neon_text.dart';

class StreakBonusDialog extends StatelessWidget {
  final int streakDay;
  final int currentStreak;
  final bool isPremium;
  final VoidCallback onClaim;
  final VoidCallback onDismiss;

  const StreakBonusDialog({
    super.key,
    required this.streakDay,
    required this.currentStreak,
    required this.isPremium,
    required this.onClaim,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDay3 = streakDay == 3;
    final multiplier = PremiumFeatures.getStreakMultiplier(isPremium);
    final bonusAmount = isDay3
        ? PremiumFeatures.day3BonusCredits * multiplier
        : PremiumFeatures.day7BonusDeepAnalysis * multiplier;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SeductiveColors.velvetPurple,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: SeductiveColors.neonMagenta.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: SeductiveColors.neonGlow(
            color: SeductiveColors.neonMagenta,
            blur: 30,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Streak fire animation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    SeductiveColors.neonCoral.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Text(
                isDay3 ? '🔥' : '🌟',
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 20),
            // Streak count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 8),
                GradientText(
                  '$currentStreak Gun Seri!',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  gradient: const LinearGradient(
                    colors: [Colors.orange, SeductiveColors.neonCoral],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bonus description
            Text(
              isDay3
                  ? 'Tebrikler! 3 gun ust uste girdin!'
                  : 'Muhtesem! 7 gun ust uste girdin!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: SeductiveColors.silverMist,
              ),
            ),
            const SizedBox(height: 24),
            // Bonus reward
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SeductiveColors.neonMagenta.withOpacity(0.2),
                    SeductiveColors.neonPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: SeductiveColors.neonMagenta.withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDay3 ? Icons.flash_on_rounded : Icons.psychology_rounded,
                    color: SeductiveColors.neonMagenta,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+$bonusAmount ${isDay3 ? 'Analiz' : 'Derin Analiz'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: SeductiveColors.lunarWhite,
                        ),
                      ),
                      if (isPremium)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: SeductiveColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VIP 2x Bonus!',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: SeductiveColors.lunarWhite,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Claim button
            GlowButton(
              text: 'Odulu Al',
              icon: Icons.card_giftcard_rounded,
              onPressed: () {
                HapticFeedback.heavyImpact();
                onClaim();
              },
            ),
            const SizedBox(height: 12),
            // Dismiss button
            TextButton(
              onPressed: onDismiss,
              child: const Text(
                'Sonra',
                style: TextStyle(color: SeductiveColors.dustyRose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small badge to show streak count in home screen
class StreakBadge extends StatelessWidget {
  final int streakCount;
  final VoidCallback? onTap;

  const StreakBadge({
    super.key,
    required this.streakCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (streakCount <= 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Color(0xFFFF5722)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              '$streakCount',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
