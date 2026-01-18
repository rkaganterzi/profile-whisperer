// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Profile Whisperer';

  @override
  String get tagline => 'Stalk\'la. Anla. Yuru.';

  @override
  String get uploadPhoto => 'Fotograf Yukle';

  @override
  String get takePhoto => 'Fotograf Cek';

  @override
  String get chooseFromGallery => 'Galeriden Sec';

  @override
  String get analyzing => 'Vibe analiz ediliyor...';

  @override
  String get vibeType => 'Vibe Tipi';

  @override
  String get conversationStarters => 'Sohbet Baslangici';

  @override
  String get shareResult => 'Sonucu Paylas';

  @override
  String get tryAnother => 'Baskasini Dene';

  @override
  String get dailyLimitReached => 'Gunluk limit doldu! Yarin tekrar gel.';

  @override
  String usesRemaining(int count) {
    return 'Bugun $count hak kaldi';
  }

  @override
  String get onboardingTitle1 => 'Herhangi Bir Profili Analiz Et';

  @override
  String get onboardingDesc1 => 'Instagram profilinin ekran goruntusunu yukle';

  @override
  String get onboardingTitle2 => 'Vibe\'ini Ogren';

  @override
  String get onboardingDesc2 => 'AI kisiliğini ve enerjisini ortaya cikarir';

  @override
  String get onboardingTitle3 => 'DM\'e Dal';

  @override
  String get onboardingDesc3 => 'Kisisellestirilmis sohbet baslangici al';

  @override
  String get getStarted => 'Basla';

  @override
  String get next => 'Ileri';

  @override
  String get skip => 'Atla';
}
