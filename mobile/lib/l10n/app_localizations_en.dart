// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Profile Whisperer';

  @override
  String get tagline => 'Stalk. Understand. Slide.';

  @override
  String get uploadPhoto => 'Upload Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get analyzing => 'Analyzing vibe...';

  @override
  String get vibeType => 'Vibe Type';

  @override
  String get conversationStarters => 'Conversation Starters';

  @override
  String get shareResult => 'Share Result';

  @override
  String get tryAnother => 'Try Another';

  @override
  String get dailyLimitReached => 'Daily limit reached! Come back tomorrow.';

  @override
  String usesRemaining(int count) {
    return '$count uses remaining today';
  }

  @override
  String get onboardingTitle1 => 'Analyze Any Profile';

  @override
  String get onboardingDesc1 => 'Upload a screenshot of any Instagram profile';

  @override
  String get onboardingTitle2 => 'Get Their Vibe';

  @override
  String get onboardingDesc2 => 'AI reveals their personality and energy';

  @override
  String get onboardingTitle3 => 'Slide Into DMs';

  @override
  String get onboardingDesc3 => 'Get personalized conversation starters';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';
}
