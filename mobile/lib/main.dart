import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/analysis_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/history_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'services/sound_service.dart';
import 'services/analytics_service.dart';
import 'services/ad_service.dart';
import 'services/purchase_service.dart';
import 'screens/splash_screen.dart';
import 'theme/seductive_theme.dart';

bool firebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    firebaseInitialized = false;
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize analytics
  AnalyticsService().init();
  AnalyticsService().logAppOpen();

  // Initialize AdMob
  await AdService().init();

  // Initialize RevenueCat
  await PurchaseService().init();

  // Initialize sound service
  await SoundService().init();

  runApp(const ProfileWhispererApp());
}

class ProfileWhispererApp extends StatelessWidget {
  const ProfileWhispererApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Configure system UI for dark theme
          SeductiveTheme.configureSystemUI();

          return MaterialApp(
            title: 'Profile Whisperer',
            debugShowCheckedModeBanner: false,
            theme: SeductiveTheme.darkTheme,
            darkTheme: SeductiveTheme.darkTheme,
            themeMode: ThemeMode.dark,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
            ],
            locale: const Locale('tr'),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
