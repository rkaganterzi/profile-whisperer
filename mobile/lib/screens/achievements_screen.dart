import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../theme/seductive_colors.dart';
import '../widgets/effects/light_leak.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: LightLeak(
        topLeft: true,
        bottomRight: true,
        intensity: 0.15,
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: SeductiveColors.lunarWhite,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rozetler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: SeductiveColors.lunarWhite,
                          ),
                        ),
                        Consumer<AchievementProvider>(
                          builder: (context, provider, _) {
                            return Text(
                              '${provider.unlockedCount}/${provider.totalAchievements} acildi',
                              style: const TextStyle(
                                fontSize: 12,
                                color: SeductiveColors.silverMist,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Progress bar
              Consumer<AchievementProvider>(
                builder: (context, provider, _) {
                  final progress = provider.unlockedCount / provider.totalAchievements;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: SeductiveColors.obsidianDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: SeductiveColors.primaryGradient,
                                      boxShadow: [
                                        BoxShadow(
                                          color: SeductiveColors.neonMagenta.withOpacity(0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '%${(progress * 100).toInt()} tamamlandi',
                          style: const TextStyle(
                            fontSize: 12,
                            color: SeductiveColors.silverMist,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Achievements grid
              Expanded(
                child: Consumer<AchievementProvider>(
                  builder: (context, provider, _) {
                    final achievements = provider.allAchievements;
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementCard(
                          context,
                          achievements[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
  ) {
    final isUnlocked = achievement.isUnlocked;
    final showSecret = achievement.isSecret && !isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isUnlocked
            ? Border.all(
                color: SeductiveColors.neonMagenta.withOpacity(0.5),
                width: 2,
              )
            : Border.all(
                color: SeductiveColors.smokyViolet,
              ),
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Emoji or lock
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isUnlocked
                        ? SeductiveColors.primaryGradient
                        : null,
                    color: isUnlocked
                        ? null
                        : SeductiveColors.obsidianDark,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isUnlocked
                        ? SeductiveColors.neonGlow(
                            color: SeductiveColors.neonMagenta,
                            blur: 15,
                          )
                        : null,
                  ),
                  child: Center(
                    child: showSecret
                        ? const Icon(
                            Icons.help_outline_rounded,
                            size: 28,
                            color: SeductiveColors.dustyRose,
                          )
                        : Text(
                            achievement.emoji,
                            style: TextStyle(
                              fontSize: 28,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  showSecret ? '???' : achievement.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? SeductiveColors.lunarWhite
                        : SeductiveColors.dustyRose,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  showSecret ? 'Gizli rozet' : achievement.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnlocked
                        ? SeductiveColors.silverMist
                        : SeductiveColors.fadedLavender,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Unlocked badge
          if (isUnlocked)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: SeductiveColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: SeductiveColors.neonGlow(
                    color: SeductiveColors.neonMagenta,
                    blur: 8,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: SeductiveColors.lunarWhite,
                  size: 14,
                ),
              ),
            ),
          // Lock icon for locked achievements
          if (!isUnlocked && !showSecret)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.lock_outline,
                size: 16,
                color: SeductiveColors.dustyRose,
              ),
            ),
        ],
      ),
    );
  }
}

// Achievement unlock toast widget
class AchievementUnlockToast extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementUnlockToast({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: SeductiveColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: SeductiveColors.neonGlow(
            color: SeductiveColors.neonMagenta,
            blur: 25,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  achievement.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rozet Acildi!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: SeductiveColors.lunarWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
