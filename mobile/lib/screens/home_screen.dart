import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/analysis_provider.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'compare_screen.dart';
import 'achievements_screen.dart';
import 'paywall_screen.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';
import '../widgets/loading_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _instagramController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _showInstagramInput = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    context.read<AnalysisProvider>().fetchRemainingUses();
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
      // Show paywall
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 48,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Kredin Bitti!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Analiz yapabilmek için kredi satın al veya Premium\'a geç.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaywallScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kredi Al',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

  Future<void> _useCredit() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.useCredit();
  }

  Future<void> _pickImage(ImageSource source) async {
    // Check credits first
    if (!_checkCredits()) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      final provider = context.read<AnalysisProvider>();
      final imageSource = source == ImageSource.camera ? 'camera' : 'gallery';
      await provider.analyzeProfile(File(image.path));

      if (mounted && provider.state == AnalysisState.success && provider.result != null) {
        // Use credit after successful analysis
        await _useCredit();

        // Save to history
        final historyProvider = context.read<HistoryProvider>();
        await historyProvider.addToHistory(
          result: provider.result!,
          imageSource: imageSource,
        );

        // Check achievements
        final achievementProvider = context.read<AchievementProvider>();
        await achievementProvider.checkAnalysisAchievements(historyProvider.totalAnalyses);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResultScreen(),
            ),
          );
        }
      }
    }
  }

  Future<void> _analyzeInstagram() async {
    final url = _instagramController.text.trim();
    if (url.isEmpty) return;

    // Check credits first
    if (!_checkCredits()) return;

    HapticFeedback.lightImpact();
    final provider = context.read<AnalysisProvider>();
    await provider.analyzeInstagram(url);

    if (mounted && provider.state == AnalysisState.success && provider.result != null) {
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
          MaterialPageRoute(
            builder: (context) => const ResultScreen(),
          ),
        );
      }
    }
  }

  void _showAnalysisOptions() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Nasıl analiz edelim?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                // Instagram Link Option
                _buildOptionCard(
                  icon: Icons.link_rounded,
                  title: 'Instagram Linki',
                  subtitle: 'Profil linkini yapıştır',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE1306C), Color(0xFFF77737)],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _showInstagramInput = true);
                  },
                ),
                const SizedBox(height: 12),
                // Screenshot Option
                _buildOptionCard(
                  icon: Icons.screenshot_rounded,
                  title: 'Screenshot Yükle',
                  subtitle: 'Profil ekran görüntüsü',
                  gradient: AppTheme.primaryGradient,
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
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textGray,
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
      backgroundColor: Colors.white,
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
                  color: Colors.grey[300],
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
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textDark,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textGray,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
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
                        // History button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.history_rounded,
                            color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                          ),
                        ),
                        // Credits badge
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaywallScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: authProvider.isPremium
                                      ? AppTheme.primaryGradient
                                      : null,
                                  color: authProvider.isPremium
                                      ? null
                                      : (isDark ? AppTheme.surfaceDark : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      authProvider.isPremium
                                          ? Icons.workspace_premium
                                          : Icons.local_fire_department_rounded,
                                      size: 18,
                                      color: authProvider.isPremium
                                          ? Colors.white
                                          : AppTheme.primaryOrange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      authProvider.isPremium
                                          ? 'Premium'
                                          : '${authProvider.credits}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: authProvider.isPremium
                                            ? Colors.white
                                            : (isDark ? AppTheme.textWhite : AppTheme.textDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Right side buttons
                        Row(
                          children: [
                            // Achievements button
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AchievementsScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.emoji_events_rounded,
                                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                              ),
                            ),
                            // Compare button
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CompareScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.compare_arrows_rounded,
                                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                              ),
                            ),
                            // Settings button
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.settings_rounded,
                                color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Logo
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.tagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Main content
                    if (provider.state == AnalysisState.loading)
                      _buildLoadingState(l10n)
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
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return const LoadingAnimation();
  }

  Widget _buildRateLimitedState(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.dailyLimitReached,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textGray,
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
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          provider.errorMessage ?? 'Bir hata olustu',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => provider.reset(),
          child: const Text('Tekrar Dene'),
        ),
      ],
    );
  }

  Widget _buildDefaultState(AnalysisProvider provider, AppLocalizations l10n) {
    return Column(
      children: [
        // Upload button with pulse animation
        ScaleTransition(
          scale: _pulseAnimation,
          child: GestureDetector(
            onTap: _showAnalysisOptions,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Analiz Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Instructions
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(width: 12),
              const Flexible(
                child: Text(
                  'Instagram linki veya screenshot\nile profili analiz et!',
                  style: TextStyle(
                    color: AppTheme.textGray,
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
    return Column(
      children: [
        // Instagram icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE1306C), Color(0xFFF77737)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Instagram Profili',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kullanıcı adı veya profil linkini yapıştır',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textGray,
          ),
        ),
        const SizedBox(height: 24),
        // Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _instagramController,
            decoration: InputDecoration(
              hintText: '@username veya instagram.com/username',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.alternate_email, color: AppTheme.primaryPink),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _analyzeInstagram(),
          ),
        ),
        const SizedBox(height: 16),
        // Analyze button
        GradientButton(
          text: 'Analiz Et 🔍',
          onPressed: _analyzeInstagram,
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        // Back button
        TextButton.icon(
          onPressed: () {
            setState(() => _showInstagramInput = false);
            _instagramController.clear();
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Geri Dön'),
        ),
      ],
    );
  }

  Widget _buildFallbackState(AnalysisProvider provider) {
    final username = provider.instagramUsername;

    return Column(
      children: [
        // Warning icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          username != null ? '@$username' : 'Instagram',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          provider.errorMessage ?? 'Profil çekilemedi',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 24),
        // Fallback message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Profilin screenshot\'ını yükleyerek devam edebilirsin!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Upload screenshot button
        GradientButton(
          text: 'Screenshot Yükle 📸',
          onPressed: () {
            provider.reset();
            setState(() => _showInstagramInput = false);
            _showImageSourceDialog();
          },
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        // Try again button
        TextButton(
          onPressed: () {
            provider.reset();
            setState(() => _showInstagramInput = true);
          },
          child: const Text('Farklı Link Dene'),
        ),
      ],
    );
  }
}
