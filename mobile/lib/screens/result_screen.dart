import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/analysis_provider.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/vibe_card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confettiController;
  final ScreenshotController _screenshotController = ScreenshotController();
  final SoundService _soundService = SoundService();
  int _selectedCategoryIndex = -1; // -1 means "All"
  int _currentStarterIndex = 0;
  final PageController _pageController = PageController();

  static const List<Map<String, dynamic>> _categories = [
    {'emoji': '🎯', 'name': 'Merak', 'color': Color(0xFF5C6BC0)},
    {'emoji': '😏', 'name': 'Şakacı', 'color': Color(0xFFFF7043)},
    {'emoji': '😂', 'name': 'Komik', 'color': Color(0xFFFFCA28)},
    {'emoji': '✨', 'name': 'Smooth', 'color': Color(0xFF26A69A)},
    {'emoji': '🔥', 'name': 'Cesur', 'color': Color(0xFFEF5350)},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Start confetti and play success sound after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
      _soundService.play(SoundType.confetti);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    _soundService.play(SoundType.copy);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 18)),
            SizedBox(width: 12),
            Text('Kopyalandı! Şimdi git yaz 😏'),
          ],
        ),
        backgroundColor: AppTheme.primaryPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareAsImage(BuildContext context) async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/vibe_card_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: 'Senin vibe tipin ne? Profile Whisperer\'da keşfet! 🔥',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = context.watch<AnalysisProvider>().result;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Sonuç bulunamadı',
            style: TextStyle(
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
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
                        onPressed: () {
                          context.read<AnalysisProvider>().reset();
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      // Share as image button
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.surfaceDark
                                : AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.image_rounded,
                            color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                            size: 20,
                          ),
                        ),
                        onPressed: () => _shareAsImage(context),
                      ),
                      // Share text button
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () => _shareResult(context, result),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vibe Card with screenshot wrapper
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                            child: VibeCard(result: result),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Conversation Starters Title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Açılış Replikleri',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  'kopyala, yapıştır, gönder 😏',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Category filter chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // "All" chip
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildCategoryChip(
                                  context,
                                  emoji: '💬',
                                  name: 'Hepsi',
                                  color: AppTheme.primaryPink,
                                  isSelected: _selectedCategoryIndex == -1,
                                  onTap: () => setState(() => _selectedCategoryIndex = -1),
                                  isDark: isDark,
                                ),
                              ),
                              // Category chips
                              ..._categories.asMap().entries.map((entry) {
                                final cat = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildCategoryChip(
                                    context,
                                    emoji: cat['emoji'],
                                    name: cat['name'],
                                    color: cat['color'],
                                    isSelected: _selectedCategoryIndex == entry.key,
                                    onTap: () => setState(() => _selectedCategoryIndex = entry.key),
                                    isDark: isDark,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Swipeable starters
                        SizedBox(
                          height: 180,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: result.conversationStarters.length,
                            onPageChanged: (index) {
                              setState(() => _currentStarterIndex = index);
                              HapticFeedback.selectionClick();
                            },
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: _buildSwipeableStarterCard(
                                  context,
                                  index + 1,
                                  result.conversationStarters[index],
                                  isDark,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Page indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            result.conversationStarters.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentStarterIndex == index ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: _currentStarterIndex == index
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: _currentStarterIndex == index
                                    ? null
                                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Swipe hint
                        Text(
                          '← kaydır →',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textGrayDark : AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Try Another Button
                        GradientButton(
                          text: l10n.tryAnother,
                          onPressed: () {
                            context.read<AnalysisProvider>().reset();
                            Navigator.pop(context);
                          },
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                AppTheme.primaryOrange,
                AppTheme.primaryPink,
                AppTheme.primaryRed,
                AppTheme.accentPurple,
                Colors.yellow,
                Colors.green,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterCard(BuildContext context, int number, String text, bool isDark) {
    final labels = [
      '🎯 Merak',
      '😏 Şakacı',
      '😂 Komik',
      '✨ Smooth',
      '🔥 Cesur',
    ];
    final label = number <= labels.length ? labels[number - 1] : '💬';

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
          onTap: () => _copyToClipboard(context, text),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: AppTheme.primaryPink.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'dokun → kopyala → yapıştır',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryPink.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String emoji,
    required String name,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : (isDark ? AppTheme.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.textWhite : AppTheme.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, String>> _getFilteredStarters(List<String> starters) {
    final entries = starters.asMap().entries.toList();
    if (_selectedCategoryIndex == -1) {
      return entries; // Return all
    }
    // Return only the selected category
    if (_selectedCategoryIndex < entries.length) {
      return [entries[_selectedCategoryIndex]];
    }
    return entries;
  }

  Widget _buildSwipeableStarterCard(
    BuildContext context,
    int number,
    String text,
    bool isDark,
  ) {
    final labels = [
      {'emoji': '🎯', 'name': 'Merak', 'color': const Color(0xFF5C6BC0)},
      {'emoji': '😏', 'name': 'Şakacı', 'color': const Color(0xFFFF7043)},
      {'emoji': '😂', 'name': 'Komik', 'color': const Color(0xFFFFCA28)},
      {'emoji': '✨', 'name': 'Smooth', 'color': const Color(0xFF26A69A)},
      {'emoji': '🔥', 'name': 'Cesur', 'color': const Color(0xFFEF5350)},
    ];
    final label = number <= labels.length ? labels[number - 1] : labels[0];

    return GestureDetector(
      onTap: () => _copyToClipboard(context, text),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (label['color'] as Color).withOpacity(isDark ? 0.3 : 0.1),
              isDark ? AppTheme.surfaceDark : Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (label['color'] as Color).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: (label['color'] as Color).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: label['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label['emoji'] as String,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Copy hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: (label['color'] as Color).withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'kopyalamak için dokun',
                  style: TextStyle(
                    fontSize: 12,
                    color: (label['color'] as Color).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareResult(BuildContext context, result) {
    final text = '''${result.vibeEmoji} ${result.vibeType}

${result.description}

🔥 ROAST: "${result.roast}"

🚩 Red Flags: ${result.redFlags.join(' • ')}
💚 Green Flags: ${result.greenFlags.join(' • ')}

💕 ${result.compatibility}

Senin vibe tipin ne? Profile Whisperer'da keşfet!''';
    Share.share(text);
  }
}
