import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rozetler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                      ),
                      Consumer<AchievementProvider>(
                        builder: (context, provider, _) {
                          return Text(
                            '${provider.unlockedCount}/${provider.totalAchievements} açıldı',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: isDark
                              ? AppTheme.surfaceDark
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryPink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toInt()}% tamamlandı',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
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
                        isDark,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
    bool isDark,
  ) {
    final isUnlocked = achievement.isUnlocked;
    final showSecret = achievement.isSecret && !isUnlocked;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isUnlocked
            ? Border.all(
                color: AppTheme.primaryPink.withOpacity(0.5),
                width: 2,
              )
            : null,
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
                        ? AppTheme.primaryGradient
                        : null,
                    color: isUnlocked
                        ? null
                        : (isDark
                            ? AppTheme.backgroundDarkSecondary
                            : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: showSecret
                        ? Icon(
                            Icons.help_outline_rounded,
                            size: 28,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
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
                        ? (isDark ? AppTheme.textWhite : AppTheme.textDark)
                        : (isDark ? Colors.grey[600] : Colors.grey[500]),
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
                        ? (isDark ? AppTheme.textGrayDark : AppTheme.textGray)
                        : (isDark ? Colors.grey[700] : Colors.grey[400]),
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
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
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
                color: isDark ? Colors.grey[600] : Colors.grey[400],
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
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                    'Rozet Açıldı! 🎉',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: Colors.white,
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
