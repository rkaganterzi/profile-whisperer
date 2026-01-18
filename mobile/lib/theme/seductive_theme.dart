import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'seductive_colors.dart';

/// Seductive Dark Theme
/// A dark-only, mysterious, and sophisticated theme with neon accents
class SeductiveTheme {
  SeductiveTheme._();

  /// The single dark theme for the app
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SeductiveColors.voidBlack,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: SeductiveColors.neonMagenta,
        secondary: SeductiveColors.neonPurple,
        tertiary: SeductiveColors.neonCoral,
        surface: SeductiveColors.velvetPurple,
        error: SeductiveColors.dangerRed,
        onPrimary: SeductiveColors.lunarWhite,
        onSecondary: SeductiveColors.lunarWhite,
        onSurface: SeductiveColors.lunarWhite,
        onError: SeductiveColors.lunarWhite,
        outline: SeductiveColors.smokyViolet,
      ),

      // Text Theme
      textTheme: const TextTheme(
        // Display
        displayLarge: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.bold,
          fontSize: 57,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.bold,
          fontSize: 45,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),

        // Headline
        headlineLarge: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        headlineMedium: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ),
        headlineSmall: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),

        // Title
        titleLarge: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        titleSmall: TextStyle(
          color: SeductiveColors.silverMist,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),

        // Body
        bodyLarge: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: SeductiveColors.silverMist,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: SeductiveColors.dustyRose,
          fontSize: 12,
          height: 1.4,
        ),

        // Label
        labelLarge: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        labelMedium: TextStyle(
          color: SeductiveColors.silverMist,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        labelSmall: TextStyle(
          color: SeductiveColors.dustyRose,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SeductiveColors.neonMagenta,
          foregroundColor: SeductiveColors.lunarWhite,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          elevation: 0,
          shadowColor: SeductiveColors.neonMagenta.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SeductiveColors.neonMagenta,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          side: const BorderSide(
            color: SeductiveColors.neonMagenta,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SeductiveColors.neonMagenta,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: SeductiveColors.velvetPurple,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: SeductiveColors.lunarWhite),
        titleTextStyle: TextStyle(
          color: SeductiveColors.lunarWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: SeductiveColors.voidBlack,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SeductiveColors.obsidianDark,
        selectedItemColor: SeductiveColors.neonMagenta,
        unselectedItemColor: SeductiveColors.dustyRose,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SeductiveColors.obsidianDark,
        hintStyle: const TextStyle(color: SeductiveColors.dustyRose),
        labelStyle: const TextStyle(color: SeductiveColors.silverMist),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: SeductiveColors.neonMagenta,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: SeductiveColors.dangerRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: SeductiveColors.dangerRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: SeductiveColors.velvetPurple,
        elevation: 24,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          color: SeductiveColors.lunarWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: SeductiveColors.silverMist,
          fontSize: 14,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SeductiveColors.velvetPurple,
        modalBackgroundColor: SeductiveColors.velvetPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: SeductiveColors.smokyViolet,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SeductiveColors.velvetPurple,
        contentTextStyle: const TextStyle(color: SeductiveColors.lunarWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SeductiveColors.neonMagenta;
          }
          return SeductiveColors.dustyRose;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return SeductiveColors.neonMagenta.withOpacity(0.3);
          }
          return SeductiveColors.smokyViolet;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: SeductiveColors.neonMagenta,
        inactiveTrackColor: SeductiveColors.smokyViolet,
        thumbColor: SeductiveColors.neonMagenta,
        overlayColor: SeductiveColors.neonMagenta.withOpacity(0.2),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: SeductiveColors.neonMagenta,
        linearTrackColor: SeductiveColors.smokyViolet,
        circularTrackColor: SeductiveColors.smokyViolet,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: SeductiveColors.lunarWhite,
        unselectedLabelColor: SeductiveColors.dustyRose,
        indicatorColor: SeductiveColors.neonMagenta,
        dividerColor: Colors.transparent,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: SeductiveColors.smokyViolet,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: SeductiveColors.obsidianDark,
        selectedColor: SeductiveColors.neonMagenta,
        labelStyle: const TextStyle(
          color: SeductiveColors.lunarWhite,
          fontSize: 12,
        ),
        side: const BorderSide(
          color: SeductiveColors.smokyViolet,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: SeductiveColors.lunarWhite,
        size: 24,
      ),

      // Page Transitions Theme
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash & Highlight Colors
      splashColor: SeductiveColors.neonMagenta.withOpacity(0.1),
      highlightColor: SeductiveColors.neonMagenta.withOpacity(0.05),
      hoverColor: SeductiveColors.neonMagenta.withOpacity(0.05),
      focusColor: SeductiveColors.neonMagenta.withOpacity(0.1),
    );
  }

  /// Configure system UI overlay style for the dark theme
  static void configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: SeductiveColors.voidBlack,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}

/// Animation Constants for Seductive Theme
class SeductiveAnimations {
  SeductiveAnimations._();

  // Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow = Duration(milliseconds: 800);
  static const Duration pageTransition = Duration(milliseconds: 800);
  static const Duration glowPulse = Duration(milliseconds: 2000);
  static const Duration stagger = Duration(milliseconds: 50);

  // Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeOutExpo;
  static const Curve dramaticCurve = Curves.easeInOutQuart;
}

/// Spacing Constants
class SeductiveSpacing {
  SeductiveSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  static const EdgeInsets screenPadding = EdgeInsets.all(24);
  static const EdgeInsets cardPadding = EdgeInsets.all(20);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 32,
    vertical: 16,
  );
}

/// Border Radius Constants
class SeductiveBorderRadius {
  SeductiveBorderRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;

  static BorderRadius get small => BorderRadius.circular(sm);
  static BorderRadius get medium => BorderRadius.circular(md);
  static BorderRadius get large => BorderRadius.circular(lg);
  static BorderRadius get extraLarge => BorderRadius.circular(xl);
  static BorderRadius get card => BorderRadius.circular(xxl);
}
