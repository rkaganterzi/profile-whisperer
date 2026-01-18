import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/analysis_history.dart';
import '../providers/history_provider.dart';
import '../providers/analysis_provider.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analiz Geçmişi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                          ),
                        ),
                        Consumer<HistoryProvider>(
                          builder: (context, provider, _) {
                            return Text(
                              '${provider.totalAnalyses} analiz',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red.shade400,
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
              child: Consumer<HistoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (provider.history.isEmpty) {
                    return _buildEmptyState(isDark);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.history.length,
                    itemBuilder: (context, index) {
                      final item = provider.history[index];
                      return _buildHistoryCard(context, item, isDark);
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceDark
                  : AppTheme.primaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 64,
              color: isDark ? AppTheme.textGrayDark : AppTheme.primaryPink,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Henüz analiz yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk analizini yap, burada görünsün!',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, AnalysisHistoryItem item, bool isDark) {
    final result = item.result;
    final timeAgo = _getTimeAgo(item.analyzedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      result.vibeEmoji,
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
                      Text(
                        result.vibeType,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getSourceIcon(item.imageSource),
                            size: 14,
                            color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                          ),
                          const SizedBox(width: 4),
                          if (item.instagramUsername != null) ...[
                            Text(
                              '@${item.instagramUsername}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryPink,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Energy badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.energy,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryPink,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
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
      default:
        return Icons.image_rounded;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dk önce';
    } else {
      return 'Az önce';
    }
  }

  void _viewResult(BuildContext context, AnalysisHistoryItem item) {
    // Set the result in provider and navigate to result screen
    context.read<AnalysisProvider>().setResult(item.result);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  void _showClearConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Text('🗑️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              'Geçmişi Sil',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Tüm analiz geçmişini silmek istediğine emin misin? Bu işlem geri alınamaz.',
          style: TextStyle(
            color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryProvider>().clearHistory();
              Navigator.pop(context);
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
