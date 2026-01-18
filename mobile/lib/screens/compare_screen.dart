import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analysis_result.dart';
import '../providers/history_provider.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final AnalyticsService _analytics = AnalyticsService();
  AnalysisResult? _profile1;
  AnalysisResult? _profile2;

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('compare_screen');
  }

  void _logComparisonIfBothSelected(AnalysisResult? p1, AnalysisResult? p2) {
    if (p1 != null && p2 != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analytics.logCompareProfiles(
          compatibilityScore: _calculateCompatibilityScore(),
        );
      });
    }
  }

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
                        'Profil Karşılaştır',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Kim daha uyumlu? 💕',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Profile selection row
                    Row(
                      children: [
                        Expanded(
                          child: _buildProfileSelector(
                            context,
                            profile: _profile1,
                            label: 'Profil 1',
                            onSelect: (result) {
                              setState(() => _profile1 = result);
                              _logComparisonIfBothSelected(result, _profile2);
                            },
                            isDark: isDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildProfileSelector(
                            context,
                            profile: _profile2,
                            label: 'Profil 2',
                            onSelect: (result) {
                              setState(() => _profile2 = result);
                              _logComparisonIfBothSelected(_profile1, result);
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Comparison results
                    if (_profile1 != null && _profile2 != null) ...[
                      _buildComparisonSection(isDark),
                    ] else ...[
                      _buildEmptyState(isDark),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSelector(
    BuildContext context, {
    required AnalysisResult? profile,
    required String label,
    required Function(AnalysisResult) onSelect,
    required bool isDark,
  }) {
    if (profile == null) {
      return GestureDetector(
        onTap: () => _showProfilePicker(context, onSelect, isDark),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryPink.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: AppTheme.primaryPink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                ),
              ),
              Text(
                'Seçmek için dokun',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showProfilePicker(context, onSelect, isDark),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.vibeEmoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              profile.vibeType,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                profile.energy,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfilePicker(
    BuildContext context,
    Function(AnalysisResult) onSelect,
    bool isDark,
  ) {
    final history = context.read<HistoryProvider>().history;

    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Henüz analiz geçmişin yok! Önce profil analiz et.'),
          backgroundColor: AppTheme.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Profil Seç',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textWhite : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            item.result.vibeEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        item.result.vibeType,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                      ),
                      subtitle: Text(
                        item.instagramUsername != null
                            ? '@${item.instagramUsername}'
                            : item.result.energy,
                        style: TextStyle(
                          color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                      ),
                      onTap: () {
                        onSelect(item.result);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 64,
            color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
          ),
          const SizedBox(height: 16),
          Text(
            'İki profil seç ve karşılaştır!',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Geçmişinden profilleri seçerek\nuyumluluk analizini gör',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppTheme.textGrayDark.withOpacity(0.7) : AppTheme.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(bool isDark) {
    final score = _calculateCompatibilityScore();
    final emoji = score >= 80
        ? '💕'
        : score >= 60
            ? '💛'
            : score >= 40
                ? '🤔'
                : '💔';

    return Column(
      children: [
        // Compatibility score
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'Uyumluluk Skoru',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '%$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getCompatibilityMessage(score),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Detailed comparison
        _buildComparisonCard(
          title: 'Enerji Karşılaştırması',
          icon: '⚡',
          value1: _profile1!.energy,
          value2: _profile2!.energy,
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildTraitsComparison(isDark),
        const SizedBox(height: 12),
        _buildFlagsComparison(isDark),
      ],
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String icon,
    required String value1,
    required String value2,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value1,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'vs',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value2,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTraitsComparison(bool isDark) {
    final commonTraits = _profile1!.traits
        .where((t) => _profile2!.traits.contains(t))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Ortak Özellikler',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (commonTraits.isEmpty)
            Text(
              'Ortak özellik yok 😅',
              style: TextStyle(
                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: commonTraits.map((trait) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    trait,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFlagsComparison(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🚩', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Red Flag Sayısı',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFlagCount(
                count: _profile1!.redFlags.length,
                label: 'Profil 1',
                color: Colors.red,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              _buildFlagCount(
                count: _profile2!.redFlags.length,
                label: 'Profil 2',
                color: Colors.red,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💚', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Green Flag Sayısı',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFlagCount(
                count: _profile1!.greenFlags.length,
                label: 'Profil 1',
                color: Colors.green,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.grey[700] : Colors.grey[300],
              ),
              _buildFlagCount(
                count: _profile2!.greenFlags.length,
                label: 'Profil 2',
                color: Colors.green,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlagCount({
    required int count,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  int _calculateCompatibilityScore() {
    if (_profile1 == null || _profile2 == null) return 0;

    int score = 50; // Base score

    // Common traits bonus
    final commonTraits = _profile1!.traits
        .where((t) => _profile2!.traits.contains(t))
        .length;
    score += commonTraits * 5;

    // Green flags bonus
    final totalGreenFlags = _profile1!.greenFlags.length + _profile2!.greenFlags.length;
    score += (totalGreenFlags * 2);

    // Red flags penalty
    final totalRedFlags = _profile1!.redFlags.length + _profile2!.redFlags.length;
    score -= (totalRedFlags * 3);

    // Same energy bonus
    if (_profile1!.energy == _profile2!.energy) {
      score += 10;
    }

    // Clamp score between 0 and 100
    return score.clamp(0, 100);
  }

  String _getCompatibilityMessage(int score) {
    if (score >= 80) {
      return 'Mükemmel uyum! Aşkın tadını çıkarın 💕';
    } else if (score >= 60) {
      return 'İyi bir potansiyel var! Şans verin 💛';
    } else if (score >= 40) {
      return 'Biraz çaba gerekebilir 🤔';
    } else {
      return 'Belki sadece arkadaş kalın... 💔';
    }
  }
}
