import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/seductive_colors.dart';
import '../widgets/core/glow_button.dart';
import '../widgets/effects/light_leak.dart';
import '../animations/page_transitions.dart';
import 'onboarding_screen.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  static const String _termsAcceptedKey = 'terms_accepted';

  static Future<bool> hasAcceptedTerms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _accepted = false;

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TermsScreen._termsAcceptedKey, true);

    if (!mounted) return;

    // Navigate to onboarding
    Navigator.of(context).pushReplacement(
      SeductivePageRoute(page: const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeductiveColors.voidBlack,
      body: LightLeak(
        topLeft: true,
        bottomRight: true,
        intensity: 0.1,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: SeductiveColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: SeductiveColors.neonGlow(
                        color: SeductiveColors.neonMagenta,
                        blur: 20,
                      ),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      size: 40,
                      color: SeductiveColors.lunarWhite,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kullanim Sartlari',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: SeductiveColors.lunarWhite,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Lutfen devam etmeden once okuyun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: SeductiveColors.silverMist,
                  ),
                ),
                const SizedBox(height: 24),
                // Terms content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: SeductiveColors.velvetPurple,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: SeductiveColors.smokyViolet,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            icon: '🎭',
                            title: 'Eglence Amacli Icerik',
                            content:
                                'HuysuzApp tarafindan uretilen tum analizler, vibe tipleri, roast\'lar ve kisilik degerlendirmeleri TAMAMEN EGLENCE AMACIDIR. Bu icerikler bilimsel, psikolojik veya profesyonel bir analiz DEGILDIR.',
                          ),
                          _buildSection(
                            icon: '🤖',
                            title: 'Yapay Zeka Uretimi',
                            content:
                                'Tum sonuclar yapay zeka tarafindan rastgele ve algoritmik olarak uretilmektedir. Sonuclar gercek kisilik ozelliklerini, niyetleri veya davranislari YANSITMAZ.',
                          ),
                          _buildSection(
                            icon: '⚠️',
                            title: 'Sorumluluk Reddi',
                            content:
                                'Uygulama sonuclarina dayanarak alinacak kararlardan HuysuzApp sorumlu tutulamaz. Sonuclar sadece eglence icin kullanilmali, kisisel veya profesyonel kararlarda REFERANS ALINMAMALIDIR.',
                          ),
                          _buildSection(
                            icon: '🔒',
                            title: 'Gizlilik ve Kullanim',
                            content:
                                'Baskalarinin profillerini analiz ederken, bu kisilerin mahremiyetine saygi gostermeyi ve sonuclari onlari asagilamak veya taciz etmek icin KULLANMAYACAGINIZI kabul edersiniz.',
                          ),
                          _buildSection(
                            icon: '📢',
                            title: 'Paylasim Kurallari',
                            content:
                                'Analiz sonuclarini paylasirken, bunlarin eglence amacli oldugunu belirtmeyi ve baskalarini incitecek sekilde kullanmamayı kabul edersiniz.',
                          ),
                          _buildSection(
                            icon: '🚫',
                            title: 'Yasak Kullanim',
                            content:
                                'Uygulamayi zorbalik, taciz, nefret soylemi veya herhangi bir yasa disi amac icin kullanmak KESINLIKLE YASAKTIR. Bu kurallari ihlal edenler kalici olarak engellenebilir.',
                          ),
                          _buildSection(
                            icon: '✅',
                            title: 'Kabul',
                            content:
                                'Uygulamayi kullanarak, yukaridaki tum sartlari okudugunuzu, anladiginizi ve kabul ettiginizi beyan edersiniz.',
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Checkbox
                GestureDetector(
                  onTap: () => setState(() => _accepted = !_accepted),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SeductiveColors.obsidianDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _accepted
                            ? SeductiveColors.neonMagenta
                            : SeductiveColors.smokyViolet,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: _accepted
                                ? SeductiveColors.primaryGradient
                                : null,
                            color: _accepted ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _accepted
                                  ? SeductiveColors.neonMagenta
                                  : SeductiveColors.silverMist,
                              width: 2,
                            ),
                          ),
                          child: _accepted
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: SeductiveColors.lunarWhite,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Kullanim sartlarini okudum ve kabul ediyorum',
                            style: TextStyle(
                              fontSize: 14,
                              color: SeductiveColors.lunarWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Accept button
                GlowButton(
                  text: 'Kabul Et ve Devam Et',
                  onPressed: _accepted ? _acceptTerms : null,
                  enabled: _accepted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SeductiveColors.neonMagenta,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: SeductiveColors.silverMist,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
