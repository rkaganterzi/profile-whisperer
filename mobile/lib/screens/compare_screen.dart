import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analysis_result.dart';
import '../providers/history_provider.dart';
import '../services/analytics_service.dart';
import '../theme/seductive_colors.dart';
import '../widgets/effects/light_leak.dart';

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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Karsilastir',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: SeductiveColors.lunarWhite,
                          ),
                        ),
                        Text(
                          'Kim daha uyumlu?',
                          style: TextStyle(
                            fontSize: 12,
                            color: SeductiveColors.silverMist,
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
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              gradient: SeductiveColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: SeductiveColors.neonGlow(
                                color: SeductiveColors.neonMagenta,
                                blur: 10,
                              ),
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                color: SeductiveColors.lunarWhite,
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Comparison results
                      if (_profile1 != null && _profile2 != null) ...[
                        _buildComparisonSection(),
                      ] else ...[
                        _buildEmptyState(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSelector(
    BuildContext context, {
    required AnalysisResult? profile,
    required String label,
    required Function(AnalysisResult) onSelect,
  }) {
    if (profile == null) {
      return GestureDetector(
        onTap: () => _showProfilePicker(context, onSelect),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: SeductiveColors.velvetPurple,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SeductiveColors.neonMagenta.withOpacity(0.3),
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
                  color: SeductiveColors.neonMagenta.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 32,
                  color: SeductiveColors.neonMagenta,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: SeductiveColors.lunarWhite,
                ),
              ),
              const Text(
                'Secmek icin dokun',
                style: TextStyle(
                  fontSize: 12,
                  color: SeductiveColors.silverMist,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showProfilePicker(context, onSelect),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: SeductiveColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: SeductiveColors.neonGlow(
            color: SeductiveColors.neonMagenta,
            blur: 15,
          ),
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
                color: SeductiveColors.lunarWhite,
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
                  color: SeductiveColors.lunarWhite,
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
  ) {
    final history = context.read<HistoryProvider>().history;

    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Henuz analiz gecmisin yok! Once profil analiz et.'),
          backgroundColor: SeductiveColors.neonMagenta,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: SeductiveColors.velvetPurple,
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
                color: SeductiveColors.smokyViolet,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profil Sec',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SeductiveColors.lunarWhite,
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
                      color: SeductiveColors.obsidianDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: SeductiveColors.primaryGradient,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: SeductiveColors.lunarWhite,
                        ),
                      ),
                      subtitle: Text(
                        item.instagramUsername != null
                            ? '@${item.instagramUsername}'
                            : item.result.energy,
                        style: const TextStyle(
                          color: SeductiveColors.silverMist,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: SeductiveColors.dustyRose,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SeductiveColors.smokyViolet),
      ),
      child: Column(
        children: [
          Icon(
            Icons.compare_arrows_rounded,
            size: 64,
            color: SeductiveColors.dustyRose,
          ),
          const SizedBox(height: 16),
          const Text(
            'Iki profil sec ve karsilastir!',
            style: TextStyle(
              fontSize: 16,
              color: SeductiveColors.silverMist,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Gecmisinden profilleri secerek\nuyumluluk analizini gor',
            style: TextStyle(
              fontSize: 13,
              color: SeductiveColors.dustyRose,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
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
            gradient: SeductiveColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: SeductiveColors.neonGlow(
              color: SeductiveColors.neonMagenta,
              blur: 20,
            ),
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
                      color: SeductiveColors.lunarWhite,
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
                  color: SeductiveColors.lunarWhite,
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
          title: 'Enerji Karsilastirmasi',
          icon: '⚡',
          value1: _profile1!.energy,
          value2: _profile2!.energy,
        ),
        const SizedBox(height: 12),
        _buildTraitsComparison(),
        const SizedBox(height: 12),
        _buildFlagsComparison(),
      ],
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String icon,
    required String value1,
    required String value2,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SeductiveColors.smokyViolet),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
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
                    color: SeductiveColors.neonMagenta.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SeductiveColors.lunarWhite,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'vs',
                  style: TextStyle(color: SeductiveColors.dustyRose),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: SeductiveColors.neonPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: SeductiveColors.lunarWhite,
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

  Widget _buildTraitsComparison() {
    final commonTraits = _profile1!.traits
        .where((t) => _profile2!.traits.contains(t))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SeductiveColors.smokyViolet),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Ortak Ozellikler',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (commonTraits.isEmpty)
            const Text(
              'Ortak ozellik yok',
              style: TextStyle(color: SeductiveColors.silverMist),
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
                    gradient: SeductiveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    trait,
                    style: const TextStyle(
                      color: SeductiveColors.lunarWhite,
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

  Widget _buildFlagsComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SeductiveColors.smokyViolet),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Tehlike Sayisi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
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
                color: SeductiveColors.dangerRed,
              ),
              Container(
                width: 1,
                height: 40,
                color: SeductiveColors.smokyViolet,
              ),
              _buildFlagCount(
                count: _profile2!.redFlags.length,
                label: 'Profil 2',
                color: SeductiveColors.dangerRed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('💚', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text(
                'Firsat Sayisi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SeductiveColors.lunarWhite,
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
                color: SeductiveColors.successGreen,
              ),
              Container(
                width: 1,
                height: 40,
                color: SeductiveColors.smokyViolet,
              ),
              _buildFlagCount(
                count: _profile2!.greenFlags.length,
                label: 'Profil 2',
                color: SeductiveColors.successGreen,
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
          style: const TextStyle(
            fontSize: 12,
            color: SeductiveColors.silverMist,
          ),
        ),
      ],
    );
  }

  int _calculateCompatibilityScore() {
    if (_profile1 == null || _profile2 == null) return 0;

    int score = 50;

    final commonTraits = _profile1!.traits
        .where((t) => _profile2!.traits.contains(t))
        .length;
    score += commonTraits * 5;

    final totalGreenFlags = _profile1!.greenFlags.length + _profile2!.greenFlags.length;
    score += (totalGreenFlags * 2);

    final totalRedFlags = _profile1!.redFlags.length + _profile2!.redFlags.length;
    score -= (totalRedFlags * 3);

    if (_profile1!.energy == _profile2!.energy) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String _getCompatibilityMessage(int score) {
    if (score >= 80) {
      return 'Mukemmel uyum! Askin tadini cikarin';
    } else if (score >= 60) {
      return 'Iyi bir potansiyel var! Sans verin';
    } else if (score >= 40) {
      return 'Biraz caba gerekebilir';
    } else {
      return 'Belki sadece arkadas kalin...';
    }
  }
}
