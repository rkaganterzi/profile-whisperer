import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../services/sound_service.dart';
import '../services/analytics_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();
  final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analytics.logScreenView('settings_screen');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionTitle(context, 'Görünüm'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildThemeOption(
                context,
                icon: Icons.brightness_auto,
                title: 'Sistem',
                subtitle: 'Cihaz ayarını takip et',
                isSelected: themeProvider.themeMode == ThemeMode.system,
                onTap: () => themeProvider.setThemeMode(ThemeMode.system),
              ),
              const Divider(height: 1),
              _buildThemeOption(
                context,
                icon: Icons.light_mode,
                title: 'Aydınlık',
                subtitle: 'Her zaman açık tema',
                isSelected: themeProvider.themeMode == ThemeMode.light,
                onTap: () => themeProvider.setThemeMode(ThemeMode.light),
              ),
              const Divider(height: 1),
              _buildThemeOption(
                context,
                icon: Icons.dark_mode,
                title: 'Karanlık',
                subtitle: 'Her zaman koyu tema',
                isSelected: themeProvider.themeMode == ThemeMode.dark,
                onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Analysis Mode Section
          _buildSectionTitle(context, 'Analiz Modu'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.local_fire_department_rounded,
                title: 'Roast Modu',
                subtitle: 'Acımasız ve komik analizler',
                value: settingsProvider.roastModeEnabled,
                onChanged: (value) async {
                  await settingsProvider.setRoastMode(value);
                },
              ),
              if (!settingsProvider.roastModeEnabled) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Roast modu kapalıyken daha nazik analizler alırsın',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 24),

          // Sound Section
          _buildSectionTitle(context, 'Ses'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.volume_up_rounded,
                title: 'Ses Efektleri',
                subtitle: 'Uygulama sesleri',
                value: _soundService.soundEnabled,
                onChanged: (value) async {
                  await _soundService.setSoundEnabled(value);
                  setState(() {});
                  if (value) {
                    _soundService.play(SoundType.tap);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle(context, 'Hakkında'),
          const SizedBox(height: 12),
          _buildCard(
            context,
            children: [
              _buildInfoTile(
                context,
                icon: Icons.info_outline,
                title: 'Versiyon',
                trailing: '1.0.0',
              ),
              const Divider(height: 1),
              _buildInfoTile(
                context,
                icon: Icons.favorite_outline,
                title: 'Yapımcı',
                trailing: 'Profile Whisperer',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Fun Stats
          _buildSectionTitle(context, 'Eğlenceli İstatistikler'),
          const SizedBox(height: 12),
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, _) {
              return _buildCard(
                context,
                children: [
                  _buildStatTile(
                    context,
                    emoji: '🔥',
                    title: 'Toplam Analiz',
                    value: historyProvider.totalAnalyses.toString(),
                  ),
                  const Divider(height: 1),
                  _buildStatTile(
                    context,
                    emoji: '📊',
                    title: 'En Çok Görülen Vibe',
                    value: historyProvider.getMostCommonVibeType() ?? '-',
                    isSmallValue: true,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // App Credits
          Center(
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Profile Whisperer',
                  style: TextStyle(
                    color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stalk. Anla. Yürü.',
                  style: TextStyle(
                    color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected
                    ? null
                    : (isDark
                        ? AppTheme.backgroundDarkSecondary
                        : AppTheme.backgroundLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppTheme.textGrayDark : AppTheme.textGray),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryPink,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
            size: 22,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.textWhite : AppTheme.textDark,
            ),
          ),
          const Spacer(),
          Text(
            trailing,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String emoji,
    required String title,
    required String value,
    bool isSmallValue = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppTheme.textWhite : AppTheme.textDark,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallValue ? 8 : 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallValue ? 11 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.backgroundDarkSecondary
                  : AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppTheme.textWhite : AppTheme.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textGrayDark : AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryPink,
          ),
        ],
      ),
    );
  }
}
