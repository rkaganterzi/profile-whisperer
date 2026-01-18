// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HuysuzApp';

  @override
  String get tagline => 'Discover. Decode. Conquer.';

  @override
  String get uploadPhoto => 'Upload Image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get analyzing => 'Infiltrating target...';

  @override
  String get vibeType => 'Vibe Type';

  @override
  String get conversationStarters => 'Your Arsenal';

  @override
  String get conversationStartersSubtitle => 'pick, copy, fire';

  @override
  String get shareResult => 'Share Result';

  @override
  String get tryAnother => 'New Target';

  @override
  String get dailyLimitReached => 'Energy depleted! Upgrade to VIP.';

  @override
  String usesRemaining(int count) {
    return '$count power remaining today';
  }

  @override
  String get onboardingTitle1 => 'Scan Any Profile';

  @override
  String get onboardingDesc1 => 'Upload a screenshot of any Instagram profile';

  @override
  String get onboardingTitle2 => 'Decode Their Vibe';

  @override
  String get onboardingDesc2 => 'AI reveals their personality and energy';

  @override
  String get onboardingTitle3 => 'Make Your Move';

  @override
  String get onboardingDesc3 => 'Get personalized weapons';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get scan => 'Scan';

  @override
  String get power => 'Power';

  @override
  String get vip => 'VIP';

  @override
  String get upgradeToVip => 'Upgrade to VIP';

  @override
  String get buyPower => 'Get Power';

  @override
  String get powerDepleted => 'Energy depleted.';

  @override
  String get danger => 'Danger';

  @override
  String get opportunity => 'Opportunity';

  @override
  String get roast => 'ROAST';

  @override
  String get weapons => 'Your Arsenal';

  @override
  String get targetLocked => 'Infiltrating target...';

  @override
  String get analyzingVibe => 'Analyzing vibe...';

  @override
  String get searchingDanger => 'Searching for dangers...';

  @override
  String get countingOpportunities => 'Counting opportunities...';

  @override
  String get preparingWeapons => 'Preparing weapons...';

  @override
  String get preparingRoast => 'Preparing roast...';

  @override
  String get finalTouches => 'Final touches...';

  @override
  String get copyToSend => 'tap to copy';

  @override
  String get copied => 'Copied! Now go text them';

  @override
  String get swipeHint => 'swipe';
}
