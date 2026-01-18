import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/analysis_provider.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/seductive_colors.dart';
import '../services/analytics_service.dart';
import '../services/ad_service.dart';
import '../animations/page_transitions.dart';
import '../widgets/effects/light_leak.dart';
import '../widgets/effects/particle_background.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/loading/ai_loading_indicator.dart';
import '../widgets/streak_bonus_dialog.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'compare_screen.dart';
import 'achievements_screen.dart';
import 'paywall_screen.dart';
import 'deep_result_screen.dart';
import '../providers/achievement_provider.dart';
import '../widgets/banner_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _instagramController = TextEditingController();
  final AnalyticsService _analytics = AnalyticsService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  bool _showInstagramInput = false;
  bool _isDeepAnalysis = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    context.read<AnalysisProvider>().fetchRemainingUses();

    // Log screen view
    _analytics.logScreenView('home_screen');

    // Check streak and show bonus dialog if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStreakBonus();
    });
  }

  void _checkStreakBonus() async {
    final streakProvider = context.read<StreakProvider>();
    await streakProvider.checkAndUpdateStreak();

    if (streakProvider.showBonusDialog && mounted) {
      _showStreakBonusDialog();
    }
  }

  void _showStreakBonusDialog() {
    final streakProvider = context.read<StreakProvider>();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreakBonusDialog(
        streakDay: streakProvider.pendingBonusDay,
        currentStreak: streakProvider.streak.currentStreak,
        isPremium: authProvider.isPremium,
        onClaim: () async {
          Navigator.pop(context);
          int credits = 0;
          if (streakProvider.pendingBonusDay == 3) {
            credits = await streakProvider.claimDay3Bonus(authProvider.isPremium);
          } else if (streakProvider.pendingBonusDay == 7) {
            credits = await streakProvider.claimDay7Bonus(authProvider.isPremium);
          }
          if (credits > 0) {
            await authProvider.addCredits(credits);
            _analytics.logStreakBonusClaimed(
              day: streakProvider.pendingBonusDay,
              credits: credits,
            );
          }
        },
        onDismiss: () {
          Navigator.pop(context);
          streakProvider.dismissBonusDialog();
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  bool _checkCredits() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.canAnalyze) {
      // Show paywall with rewarded ad option
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: SeductiveColors.velvetPurple,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SeductiveColors.smokyViolet,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: SeductiveColors.buttonGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: SeductiveColors.neonGlow(
                      color: SeductiveColors.neonCoral,
                      blur: 20,
                    ),
                  ),
                  child: const Icon(
                    Icons.flash_off_rounded,
                    size: 48,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
                const SizedBox(height: 20),
                const GradientText(
                  'Enerjin tukendi.',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  gradient: SeductiveColors.buttonGradient,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Analiz yapabilmek icin guc satin al veya VIP'e yuksel.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: SeductiveColors.silverMist,
                  ),
                ),
                const SizedBox(height: 24),
                // Rewarded Ad Button
                if (AdService().isRewardedAdReady)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _showRewardedAdForCredit();
                        },
                        icon: const Icon(
                          Icons.play_circle_outline_rounded,
                          color: SeductiveColors.neonMagenta,
                        ),
                        label: const Text(
                          'Reklam Izle = +1 Analiz',
                          style: TextStyle(
                            color: SeductiveColors.neonMagenta,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(
                            color: SeductiveColors.neonMagenta,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                GlowButton(
                  text: 'Guc Al',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      SeductivePageRoute(page: const PaywallScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _showRewardedAdForCredit() async {
    final adService = AdService();
    final authProvider = context.read<AuthProvider>();

    final shown = await adService.showRewardedAd(
      onRewarded: (amount) async {
        // Award 1 credit regardless of the reward amount from AdMob
        await authProvider.addCredits(1);
        _analytics.logRewardedAdWatched(credits: 1);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: SeductiveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: SeductiveColors.lunarWhite,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '+1 Analiz hakki kazandin!',
                    style: TextStyle(color: SeductiveColors.lunarWhite),
                  ),
                ],
              ),
              backgroundColor: SeductiveColors.velvetPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: SeductiveColors.neonMagenta.withOpacity(0.3),
                ),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );

    if (!shown) {
      _analytics.logRewardedAdFailed(reason: 'ad_not_ready');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reklam yukleniyor, lutfen tekrar deneyin.'),
            backgroundColor: SeductiveColors.neonCoral,
          ),
        );
      }
    }
  }

  void _showStreakInfoDialog(int streak) {
    final streakProvider = context.read<StreakProvider>();
    final nextMilestone = streakProvider.streak.nextMilestone;
    final daysUntil = streakProvider.streak.daysUntilNextMilestone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SeductiveColors.velvetPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔥',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              '$streak Gun Seri!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: SeductiveColors.lunarWhite,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Her gun gir, oduller kazan!',
              style: TextStyle(
                fontSize: 14,
                color: SeductiveColors.silverMist,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SeductiveColors.obsidianDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sonraki odul:',
                        style: TextStyle(
                          color: SeductiveColors.dustyRose,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Gun $nextMilestone',
                        style: const TextStyle(
                          color: SeductiveColors.neonMagenta,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (streak % nextMilestone) / nextMilestone,
                    backgroundColor: SeductiveColors.smokyViolet,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      SeductiveColors.neonMagenta,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$daysUntil gun kaldi',
                    style: const TextStyle(
                      color: SeductiveColors.silverMist,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tamam',
              style: TextStyle(color: SeductiveColors.neonMagenta),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCredit() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.useCredit();
  }

  Future<void> _pickImage(ImageSource source) async {
    debugPrint('HomeScreen: _pickImage called with source=$source');
    // Check credits first
    if (!_checkCredits()) {
      debugPrint('HomeScreen: Credit check failed for image');
      return;
    }

    debugPrint('HomeScreen: Opening image picker...');
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    debugPrint('HomeScreen: Image picked: ${image?.path}');
    if (image != null && mounted) {
      final provider = context.read<AnalysisProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final imageSource = source == ImageSource.camera ? 'camera' : 'gallery';

      // Log analyze started
      _analytics.logAnalyzeStarted(source: imageSource);

      debugPrint('HomeScreen: Starting image analysis...');
      await provider.analyzeProfile(
        File(image.path),
        roastMode: settingsProvider.roastModeEnabled,
      );

      debugPrint('HomeScreen: After analysis - state=${provider.state}, result=${provider.result}, mounted=$mounted');
      if (mounted && provider.state == AnalysisState.success && provider.result != null) {
        debugPrint('HomeScreen: Analysis success! Processing...');

        // Log analyze completed
        _analytics.logAnalyzeCompleted(
          source: imageSource,
          vibeType: provider.result!.vibeType,
        );

        try {
          // Use credit after successful analysis
          debugPrint('HomeScreen: Using credit...');
          await _useCredit();
          debugPrint('HomeScreen: Credit used');

          // Save to history
          debugPrint('HomeScreen: Saving to history...');
          final historyProvider = context.read<HistoryProvider>();
          await historyProvider.addToHistory(
            result: provider.result!,
            imageSource: imageSource,
          );
          debugPrint('HomeScreen: Saved to history');

          // Check achievements
          debugPrint('HomeScreen: Checking achievements...');
          final achievementProvider = context.read<AchievementProvider>();
          await achievementProvider.checkAnalysisAchievements(historyProvider.totalAnalyses);
          debugPrint('HomeScreen: Achievements checked');

          if (mounted) {
            debugPrint('HomeScreen: NOW navigating to ResultScreen!');
            Navigator.push(
              context,
              SeductivePageRoute(page: const ResultScreen()),
            );
            debugPrint('HomeScreen: Navigation complete');
          }
        } catch (e) {
          debugPrint('HomeScreen: Error during post-analysis: $e');
        }
      }
    }
  }

  Future<void> _analyzeInstagram() async {
    final url = _instagramController.text.trim();
    debugPrint('HomeScreen: _analyzeInstagram called with url=$url, isDeepAnalysis=$_isDeepAnalysis');
    if (url.isEmpty) {
      debugPrint('HomeScreen: URL is empty, returning');
      return;
    }

    // Check credits first
    final authProvider = context.read<AuthProvider>();
    debugPrint('HomeScreen: Credits check - credits=${authProvider.credits}, canAnalyze=${authProvider.canAnalyze}');
    if (!_checkCredits()) {
      debugPrint('HomeScreen: Credit check failed');
      return;
    }

    // Log analyze started
    _analytics.logAnalyzeStarted(source: _isDeepAnalysis ? 'instagram_deep' : 'instagram');

    debugPrint('HomeScreen: Starting analysis...');
    HapticFeedback.lightImpact();
    final provider = context.read<AnalysisProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    if (_isDeepAnalysis) {
      // Deep analysis
      await provider.analyzeInstagramDeep(url);

      if (mounted && provider.state == AnalysisState.deepSuccess && provider.deepResult != null) {
        // Log analyze completed
        _analytics.logAnalyzeCompleted(
          source: 'instagram_deep',
          vibeType: provider.deepResult!.profileArchetype,
        );

        // Use credit after successful analysis
        await _useCredit();

        // Check achievements
        final historyProvider = context.read<HistoryProvider>();
        final achievementProvider = context.read<AchievementProvider>();
        await achievementProvider.checkAnalysisAchievements(historyProvider.totalAnalyses);

        if (mounted) {
          Navigator.push(
            context,
            SeductivePageRoute(page: const DeepResultScreen()),
          );
        }
      }
    } else {
      // Regular analysis
      await provider.analyzeInstagram(
        url,
        roastMode: settingsProvider.roastModeEnabled,
      );

      if (mounted && provider.state == AnalysisState.success && provider.result != null) {
        // Log analyze completed
        _analytics.logAnalyzeCompleted(
          source: 'instagram',
          vibeType: provider.result!.vibeType,
        );

        // Use credit after successful analysis
        await _useCredit();

        // Save to history
        final historyProvider = context.read<HistoryProvider>();
        await historyProvider.addToHistory(
          result: provider.result!,
          instagramUsername: provider.instagramUsername,
          imageSource: 'instagram',
        );

        // Check achievements
        final achievementProvider = context.read<AchievementProvider>();
        await achievementProvider.checkAnalysisAchievements(historyProvider.totalAnalyses);

        if (mounted) {
          Navigator.push(
            context,
            SeductivePageRoute(page: const ResultScreen()),
          );
        }
      }
    }
  }

  void _showAnalysisOptions() {
    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: SeductiveColors.velvetPurple,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SeductiveColors.smokyViolet,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const GradientText(
                  'Nasil analiz edelim?',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  gradient: SeductiveColors.primaryGradient,
                ),
                const SizedBox(height: 24),
                // Deep Analysis Option (Premium)
                _buildOptionCard(
                  icon: Icons.psychology_rounded,
                  title: 'Derin Analiz',
                  subtitle: authProvider.isPremium ? '6-9 post analizi' : 'VIP ozellik',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (authProvider.isPremium) {
                      setState(() => _showInstagramInput = true);
                      _isDeepAnalysis = true;
                    } else {
                      Navigator.push(
                        context,
                        SeductivePageRoute(page: const PaywallScreen()),
                      );
                    }
                  },
                  isPremium: true,
                  isLocked: !authProvider.isPremium,
                ),
                const SizedBox(height: 12),
                // Instagram Link Option
                _buildOptionCard(
                  icon: Icons.link_rounded,
                  title: 'Instagram Linki',
                  subtitle: 'Profil linkini yapistir',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1306C), Color(0xFFF77737)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _showInstagramInput = true;
                      _isDeepAnalysis = false;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Screenshot Option
                _buildOptionCard(
                  icon: Icons.screenshot_rounded,
                  title: 'Screenshot Yukle',
                  subtitle: 'Profil ekran goruntusu',
                  gradient: SeductiveColors.primaryGradient,
                  onTap: () {
                    Navigator.pop(context);
                    _showImageSourceDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isPremium = false,
    bool isLocked = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SeductiveColors.obsidianDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? SeductiveColors.neonMagenta.withOpacity(0.4)
                : SeductiveColors.neonMagenta.withOpacity(0.2),
            width: isPremium ? 1.5 : 1,
          ),
          boxShadow: isPremium
              ? SeductiveColors.neonGlow(
                  color: SeductiveColors.neonMagenta,
                  blur: 10,
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: SeductiveColors.neonMagenta.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(icon, color: SeductiveColors.lunarWhite),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: SeductiveColors.lunarWhite,
                        ),
                      ),
                      if (isPremium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: SeductiveColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: SeductiveColors.lunarWhite,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SeductiveColors.dustyRose,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isLocked ? Icons.lock_rounded : Icons.arrow_forward_ios,
              size: 16,
              color: isLocked
                  ? SeductiveColors.neonMagenta
                  : SeductiveColors.dustyRose,
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: SeductiveColors.velvetPurple,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SeductiveColors.smokyViolet,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildSourceOption(
                icon: Icons.camera_alt_rounded,
                label: l10n.takePhoto,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildSourceOption(
                icon: Icons.photo_library_rounded,
                label: l10n.chooseFromGallery,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SeductiveColors.obsidianDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SeductiveColors.neonMagenta.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: SeductiveColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: SeductiveColors.neonGlow(
                  color: SeductiveColors.neonMagenta,
                  blur: 10,
                ),
              ),
              child: Icon(icon, color: SeductiveColors.lunarWhite),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: SeductiveColors.lunarWhite,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: SeductiveColors.dustyRose,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: ParticleBackground(
        particleCount: 30,
        particleColor: SeductiveColors.neonMagenta.withOpacity(0.3),
        child: LightLeak(
          topLeft: true,
          bottomRight: true,
          intensity: 0.12,
          child: SafeArea(
            child: Consumer<AnalysisProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Top bar with history, compare and settings buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side: History + Streak
                            Row(
                              children: [
                                // History button
                                _buildTopBarButton(
                                  icon: Icons.history_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SeductivePageRoute(page: const HistoryScreen()),
                                    );
                                  },
                                ),
                                // Streak badge
                                Consumer<StreakProvider>(
                                  builder: (context, streakProvider, _) {
                                    final streak = streakProvider.streak.currentStreak;
                                    if (streak <= 0) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: StreakBadge(
                                        streakCount: streak,
                                        onTap: () {
                                          // Show streak info
                                          _showStreakInfoDialog(streak);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            // Credits badge
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SeductivePageRoute(page: const PaywallScreen()),
                                    );
                                  },
                                  child: AnimatedBuilder(
                                    animation: _glowAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: authProvider.isPremium
                                              ? SeductiveColors.primaryGradient
                                              : null,
                                          color: authProvider.isPremium
                                              ? null
                                              : SeductiveColors.velvetPurple,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: SeductiveColors.neonMagenta
                                                  .withOpacity(_glowAnimation.value * 0.5),
                                              blurRadius: 15,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                          border: Border.all(
                                            color: SeductiveColors.neonMagenta
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              authProvider.isPremium
                                                  ? Icons.workspace_premium
                                                  : Icons.flash_on_rounded,
                                              size: 18,
                                              color: authProvider.isPremium
                                                  ? SeductiveColors.lunarWhite
                                                  : SeductiveColors.neonMagenta,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              authProvider.isPremium
                                                  ? 'VIP'
                                                  : '${authProvider.credits}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: authProvider.isPremium
                                                    ? SeductiveColors.lunarWhite
                                                    : SeductiveColors.neonMagenta,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            // Right side buttons
                            Row(
                              children: [
                                // Achievements button
                                _buildTopBarButton(
                                  icon: Icons.emoji_events_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SeductivePageRoute(page: const AchievementsScreen()),
                                    );
                                  },
                                ),
                                // Compare button
                                _buildTopBarButton(
                                  icon: Icons.compare_arrows_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SeductivePageRoute(page: const CompareScreen()),
                                    );
                                  },
                                ),
                                // Settings button
                                _buildTopBarButton(
                                  icon: Icons.settings_rounded,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      SeductivePageRoute(page: const SettingsScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Logo
                        const AnimatedNeonText(
                          'Profile Whisperer',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          glowColor: SeductiveColors.neonMagenta,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tagline,
                          style: const TextStyle(
                            fontSize: 16,
                            color: SeductiveColors.silverMist,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Main content
                        if (provider.state == AnalysisState.loading)
                          _buildLoadingState()
                        else if (provider.state == AnalysisState.rateLimited)
                          _buildRateLimitedState(l10n)
                        else if (provider.state == AnalysisState.error)
                          _buildErrorState(provider, l10n)
                        else if (provider.state == AnalysisState.needsFallback)
                          _buildFallbackState(provider)
                        else if (_showInstagramInput)
                          _buildInstagramInputState(provider)
                        else
                          _buildDefaultState(provider, l10n),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: SeductiveColors.dustyRose,
      ),
    );
  }

  Widget _buildLoadingState() {
    final provider = context.watch<AnalysisProvider>();
    return Column(
      children: [
        const AILoadingIndicator(),
        if (provider.loadingMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            provider.loadingMessage!,
            style: const TextStyle(
              fontSize: 14,
              color: SeductiveColors.silverMist,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRateLimitedState(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SeductiveColors.velvetPurple,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SeductiveColors.neonCoral.withOpacity(0.3),
            ),
          ),
          child: const Icon(
            Icons.hourglass_empty,
            size: 64,
            color: SeductiveColors.neonCoral,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.dailyLimitReached,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: SeductiveColors.silverMist,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(AnalysisProvider provider, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SeductiveColors.velvetPurple,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SeductiveColors.dangerRed.withOpacity(0.3),
            ),
          ),
          child: const Icon(
            Icons.error_outline,
            size: 64,
            color: SeductiveColors.dangerRed,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          provider.errorMessage ?? 'Bir hata olustu',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: SeductiveColors.dangerRed,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => provider.reset(),
          child: const Text(
            'Tekrar Dene',
            style: TextStyle(color: SeductiveColors.neonMagenta),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultState(AnalysisProvider provider, AppLocalizations l10n) {
    return Column(
      children: [
        // Upload button with pulse animation
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: GestureDetector(
                onTap: _showAnalysisOptions,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: SeductiveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: SeductiveColors.neonMagenta
                            .withOpacity(_glowAnimation.value),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: SeductiveColors.neonPurple
                            .withOpacity(_glowAnimation.value * 0.5),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_search_rounded,
                        size: 56,
                        color: SeductiveColors.lunarWhite,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Tara',
                        style: TextStyle(
                          color: SeductiveColors.lunarWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        // Instructions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: SeductiveColors.velvetPurple,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SeductiveColors.neonMagenta.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    SeductiveColors.buttonGradient.createShader(bounds),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: SeductiveColors.lunarWhite,
                ),
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Instagram linki veya screenshot\nile profili analiz et!',
                  style: TextStyle(
                    color: SeductiveColors.silverMist,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstagramInputState(AnalysisProvider provider) {
    final isDeep = _isDeepAnalysis;
    final gradient = isDeep
        ? const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)])
        : const LinearGradient(colors: [Color(0xFFE1306C), Color(0xFFF77737)]);
    final primaryColor = isDeep ? const Color(0xFF9C27B0) : const Color(0xFFE1306C);

    return Column(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isDeep ? Icons.psychology_rounded : Icons.camera_alt_rounded,
            size: 48,
            color: SeductiveColors.lunarWhite,
          ),
        ),
        const SizedBox(height: 24),
        // Title with VIP badge for deep analysis
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GradientText(
              isDeep ? 'Derin Profil Analizi' : 'Instagram Profili',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              gradient: gradient,
            ),
            if (isDeep) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: SeductiveColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isDeep
              ? '6-9 post analizi ile detayli karakter tahmini'
              : 'Kullanici adi veya profil linkini yapistir',
          style: const TextStyle(
            fontSize: 14,
            color: SeductiveColors.silverMist,
          ),
          textAlign: TextAlign.center,
        ),
        if (isDeep) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SeductiveColors.velvetPurple,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: const Text(
              'Sadece acik profiller icin',
              style: TextStyle(
                fontSize: 12,
                color: SeductiveColors.dustyRose,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        // Input field
        Container(
          decoration: BoxDecoration(
            color: SeductiveColors.obsidianDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 15,
              ),
            ],
          ),
          child: TextField(
            controller: _instagramController,
            style: const TextStyle(color: SeductiveColors.lunarWhite),
            decoration: InputDecoration(
              hintText: '@username veya instagram.com/username',
              hintStyle: TextStyle(color: SeductiveColors.dustyRose.withOpacity(0.7)),
              prefixIcon: Icon(
                Icons.alternate_email,
                color: primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: SeductiveColors.obsidianDark,
            ),
            onSubmitted: (_) => _analyzeInstagram(),
          ),
        ),
        const SizedBox(height: 16),
        // Analyze button
        GlowButton(
          text: isDeep ? 'Derin Analiz Baslat' : 'Tara',
          onPressed: _analyzeInstagram,
          icon: isDeep ? Icons.psychology_rounded : Icons.search_rounded,
        ),
        const SizedBox(height: 12),
        // Back button
        TextButton.icon(
          onPressed: () {
            setState(() {
              _showInstagramInput = false;
              _isDeepAnalysis = false;
            });
            _instagramController.clear();
          },
          icon: const Icon(Icons.arrow_back, color: SeductiveColors.dustyRose),
          label: const Text(
            'Geri Don',
            style: TextStyle(color: SeductiveColors.dustyRose),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackState(AnalysisProvider provider) {
    final username = provider.instagramUsername;

    return Column(
      children: [
        // Instagram icon with lock overlay
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SeductiveColors.neonPurple.withOpacity(0.2),
                    SeductiveColors.neonMagenta.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: SeductiveColors.neonPurple.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 48,
                color: SeductiveColors.neonPurple,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: SeductiveColors.neonCoral,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (username != null) ...[
          Text(
            '@$username',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SeductiveColors.lunarWhite,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          'Instagram Engelliyor',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: SeductiveColors.neonCoral.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            provider.errorMessage ?? 'Profil bilgilerine erişilemiyor',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: SeductiveColors.dustyRose,
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Attractive screenshot CTA
        Container(
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
            borderRadius: BorderRadius.circular(20),
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
                  Icon(
                    Icons.auto_awesome,
                    color: SeductiveColors.neonMagenta,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kolay Çözüm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SeductiveColors.lunarWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Profil sayfasının ekran görüntüsünü çek ve yükle - aynı sonucu alacaksın!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: SeductiveColors.silverMist,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              GlowButton(
                text: 'Screenshot Yükle',
                icon: Icons.add_photo_alternate_rounded,
                onPressed: () {
                  provider.reset();
                  setState(() => _showInstagramInput = false);
                  _showImageSourceDialog();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Secondary options
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () {
                provider.reset();
                setState(() => _showInstagramInput = true);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tekrar Dene'),
              style: TextButton.styleFrom(
                foregroundColor: SeductiveColors.dustyRose,
              ),
            ),
            Container(
              width: 1,
              height: 20,
              color: SeductiveColors.dustyRose.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            TextButton.icon(
              onPressed: () {
                provider.reset();
                setState(() => _showInstagramInput = false);
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Geri Dön'),
              style: TextButton.styleFrom(
                foregroundColor: SeductiveColors.dustyRose,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
