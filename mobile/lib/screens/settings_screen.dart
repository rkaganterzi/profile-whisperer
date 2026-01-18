import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../services/sound_service.dart';
import '../services/analytics_service.dart';
import '../theme/seductive_colors.dart';
import '../widgets/core/neon_text.dart';
import '../widgets/core/glass_card.dart';

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
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Ayarlar',
          style: TextStyle(color: SeductiveColors.lunarWhite),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: SeductiveColors.lunarWhite,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Analysis Mode Section
          _buildSectionTitle('Analiz Modu'),
          const SizedBox(height: 12),
          _buildCard(
            children: [
              _buildSwitchTile(
                icon: Icons.local_fire_department_rounded,
                title: 'Roast Modu',
                subtitle: 'Acimasiz ve komik analizler',
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
                      color: SeductiveColors.neonCyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: SeductiveColors.neonCyan.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: SeductiveColors.neonCyan,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Roast modu kapaliyken daha nazik analizler alirsin',
                            style: TextStyle(
                              fontSize: 12,
                              color: SeductiveColors.silverMist,
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
          _buildSectionTitle('Ses'),
          const SizedBox(height: 12),
          _buildCard(
            children: [
              _buildSwitchTile(
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
          _buildSectionTitle('Hakkinda'),
          const SizedBox(height: 12),
          _buildCard(
            children: [
              _buildInfoTile(
                icon: Icons.info_outline,
                title: 'Versiyon',
                trailing: '1.0.0',
              ),
              Container(
                height: 1,
                color: SeductiveColors.smokyViolet,
              ),
              _buildInfoTile(
                icon: Icons.favorite_outline,
                title: 'Yapimci',
                trailing: 'Profile Whisperer',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Fun Stats
          _buildSectionTitle('Eglenceli Istatistikler'),
          const SizedBox(height: 12),
          Consumer<HistoryProvider>(
            builder: (context, historyProvider, _) {
              return _buildCard(
                children: [
                  _buildStatTile(
                    emoji: '🔮',
                    title: 'Toplam Tarama',
                    value: historyProvider.totalAnalyses.toString(),
                  ),
                  Container(
                    height: 1,
                    color: SeductiveColors.smokyViolet,
                  ),
                  _buildStatTile(
                    emoji: '📊',
                    title: 'En Cok Gorulen Vibe',
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: SeductiveColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: SeductiveColors.neonGlow(
                      color: SeductiveColors.neonMagenta,
                      blur: 15,
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    size: 28,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Profile Whisperer',
                  style: TextStyle(
                    color: SeductiveColors.silverMist,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kesfet. Coz. Fethet.',
                  style: TextStyle(
                    color: SeductiveColors.dustyRose,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SeductiveColors.dustyRose,
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: SeductiveColors.velvetPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SeductiveColors.smokyViolet,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            color: SeductiveColors.dustyRose,
            size: 22,
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: SeductiveColors.lunarWhite,
            ),
          ),
          const Spacer(),
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 14,
              color: SeductiveColors.silverMist,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String emoji,
    required String title,
    required String value,
    bool isSmallValue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: SeductiveColors.lunarWhite,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallValue ? 8 : 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              gradient: SeductiveColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: SeductiveColors.neonMagenta.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallValue ? 11 : 14,
                fontWeight: FontWeight.bold,
                color: SeductiveColors.lunarWhite,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SeductiveColors.obsidianDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: SeductiveColors.dustyRose,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: SeductiveColors.silverMist,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: SeductiveColors.neonMagenta,
            activeTrackColor: SeductiveColors.neonMagenta.withOpacity(0.3),
            inactiveThumbColor: SeductiveColors.dustyRose,
            inactiveTrackColor: SeductiveColors.smokyViolet,
          ),
        ],
      ),
    );
  }
}
