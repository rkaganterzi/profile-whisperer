import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analysis_history.dart';
import '../providers/history_provider.dart';
import '../providers/analysis_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/seductive_colors.dart';
import '../widgets/effects/light_leak.dart';
import '../animations/page_transitions.dart';
import '../utils/premium_features.dart';
import 'result_screen.dart';
import 'deep_result_screen.dart';
import 'paywall_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tarama Gecmisi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: SeductiveColors.lunarWhite,
                            ),
                          ),
                          Consumer<HistoryProvider>(
                            builder: (context, provider, _) {
                              return Text(
                                '${provider.totalAnalyses} tarama',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: SeductiveColors.silverMist,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Clear all button
                    Consumer<HistoryProvider>(
                      builder: (context, provider, _) {
                        if (provider.history.isEmpty) return const SizedBox();
                        return IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: SeductiveColors.dangerRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: SeductiveColors.dangerRed.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: SeductiveColors.dangerRed,
                              size: 20,
                            ),
                          ),
                          onPressed: () => _showClearConfirmation(context),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Consumer2<HistoryProvider, AuthProvider>(
                  builder: (context, historyProvider, authProvider, _) {
                    if (historyProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: SeductiveColors.neonMagenta,
                        ),
                      );
                    }

                    if (historyProvider.history.isEmpty) {
                      return _buildEmptyState();
                    }

                    final isPremium = authProvider.isPremium;
                    final visibleHistory = historyProvider.getVisibleHistory(isPremium);
                    final hiddenCount = historyProvider.getHiddenCount(isPremium);

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibleHistory.length + (hiddenCount > 0 ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show premium unlock card at the end
                        if (index == visibleHistory.length && hiddenCount > 0) {
                          return _buildPremiumUnlockCard(context, hiddenCount);
                        }
                        final item = visibleHistory[index];
                        return _buildHistoryCard(context, item);
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

  Widget _buildPremiumUnlockCard(BuildContext context, int hiddenCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            SeductiveColors.neonMagenta.withOpacity(0.15),
            SeductiveColors.neonPurple.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SeductiveColors.neonMagenta.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: SeductiveColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: SeductiveColors.lunarWhite,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+$hiddenCount Gizli Tarama',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SeductiveColors.lunarWhite,
                    ),
                  ),
                  Text(
                    'Premium ile tum gecmisi ac',
                    style: TextStyle(
                      fontSize: 12,
                      color: SeductiveColors.dustyRose,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SeductivePageRoute(page: const PaywallScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SeductiveColors.neonMagenta,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium, color: SeductiveColors.lunarWhite, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Premium\'a Yukselt',
                    style: TextStyle(
                      color: SeductiveColors.lunarWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SeductiveColors.velvetPurple,
              shape: BoxShape.circle,
              boxShadow: SeductiveColors.neonGlow(
                color: SeductiveColors.neonMagenta,
                blur: 20,
              ),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 64,
              color: SeductiveColors.neonMagenta,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henuz tarama yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: SeductiveColors.lunarWhite,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ilk taramani yap, burada gorunsun!',
            style: TextStyle(
              fontSize: 14,
              color: SeductiveColors.silverMist,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AnalysisHistoryItem item) {
    final timeAgo = _getTimeAgo(item.analyzedAt);
    final isDeep = item.isDeepAnalysis;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDeep
              ? SeductiveColors.neonPurple.withOpacity(0.5)
              : SeductiveColors.smokyViolet,
          width: isDeep ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          if (isDeep)
            BoxShadow(
              color: SeductiveColors.neonPurple.withOpacity(0.2),
              blurRadius: 10,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewResult(context, item),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isDeep
                        ? const LinearGradient(
                            colors: [SeductiveColors.neonPurple, SeductiveColors.neonMagenta],
                          )
                        : SeductiveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: SeductiveColors.neonGlow(
                      color: isDeep ? SeductiveColors.neonPurple : SeductiveColors.neonMagenta,
                      blur: 10,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.displayEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.displayTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SeductiveColors.lunarWhite,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDeep) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [SeductiveColors.neonPurple, SeductiveColors.neonMagenta],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'DERİN',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: SeductiveColors.lunarWhite,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getSourceIcon(item.imageSource),
                            size: 14,
                            color: SeductiveColors.silverMist,
                          ),
                          const SizedBox(width: 4),
                          if (item.instagramUsername != null) ...[
                            Text(
                              '@${item.instagramUsername}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: SeductiveColors.neonMagenta,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: SeductiveColors.silverMist,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Badge - Energy for normal, Engagement for deep
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDeep ? SeductiveColors.neonPurple : SeductiveColors.neonMagenta).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (isDeep ? SeductiveColors.neonPurple : SeductiveColors.neonMagenta).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          isDeep
                              ? item.deepResult?.engagementQuality ?? 'Analiz'
                              : item.result?.energy ?? 'Analiz',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDeep ? SeductiveColors.neonPurple : SeductiveColors.neonMagenta,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SeductiveColors.dustyRose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSourceIcon(String? source) {
    switch (source) {
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'gallery':
        return Icons.photo_library_rounded;
      case 'instagram':
        return Icons.link_rounded;
      case 'instagram_deep':
        return Icons.psychology_rounded;
      default:
        return Icons.image_rounded;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ay once';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gun once';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat once';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk once';
    } else {
      return 'Az once';
    }
  }

  void _viewResult(BuildContext context, AnalysisHistoryItem item) {
    final analysisProvider = context.read<AnalysisProvider>();

    if (item.isDeepAnalysis && item.deepResult != null) {
      analysisProvider.setDeepResult(item.deepResult!, username: item.instagramUsername);
      Navigator.push(
        context,
        SeductivePageRoute(page: const DeepResultScreen(fromHistory: true)),
      );
    } else if (item.result != null) {
      analysisProvider.setResult(item.result!);
      Navigator.push(
        context,
        SeductivePageRoute(page: const ResultScreen()),
      );
    }
  }

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SeductiveColors.velvetPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('🗑️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 12),
            Text(
              'Gecmisi Sil',
              style: TextStyle(color: SeductiveColors.lunarWhite),
            ),
          ],
        ),
        content: const Text(
          'Tum tarama gecmisini silmek istedigine emin misin? Bu islem geri alinamaz.',
          style: TextStyle(color: SeductiveColors.silverMist),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Iptal',
              style: TextStyle(color: SeductiveColors.dustyRose),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: SeductiveColors.dangerRed),
            ),
          ),
        ],
      ),
    );
  }
}
