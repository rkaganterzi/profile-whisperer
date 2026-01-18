import 'package:flutter/material.dart';

/// Seductive Dark Theme - Color Palette
/// A dark, mysterious, and sophisticated color scheme with neon accents
class SeductiveColors {
  SeductiveColors._();

  // ============================================
  // NEON ACCENT COLORS
  // ============================================

  /// Primary neon magenta - Main accent color
  static const Color neonMagenta = Color(0xFFFF2D92);

  /// Neon purple - Secondary accent
  static const Color neonPurple = Color(0xFFA855F7);

  /// Wine red - Tertiary accent for depth
  static const Color neonWine = Color(0xFF9D174D);

  /// Warm coral - For highlights and CTAs
  static const Color neonCoral = Color(0xFFFF6B6B);

  /// Electric cyan - For special effects
  static const Color neonCyan = Color(0xFF22D3EE);

  // ============================================
  // DARK BACKGROUNDS
  // ============================================

  /// Void black - Primary background (deepest)
  static const Color voidBlack = Color(0xFF0A0A0F);

  /// Obsidian dark - Secondary background
  static const Color obsidianDark = Color(0xFF12121A);

  /// Velvet purple - Card/surface background
  static const Color velvetPurple = Color(0xFF1A1625);

  /// Smoky violet - Hover/pressed states
  static const Color smokyViolet = Color(0xFF251D30);

  /// Midnight blue - Alternative surface
  static const Color midnightBlue = Color(0xFF1A1A2E);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Lunar white - Primary text
  static const Color lunarWhite = Color(0xFFF8F8FF);

  /// Silver mist - Secondary text
  static const Color silverMist = Color(0xFFB4B4C4);

  /// Dusty rose - Hints and placeholders
  static const Color dustyRose = Color(0xFF9D8189);

  /// Faded lavender - Disabled text
  static const Color fadedLavender = Color(0xFF6B6B7B);

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  /// Success/Opportunity green (Green Flags -> "Firsat")
  static const Color successGreen = Color(0xFF10B981);

  /// Danger/Warning red (Red Flags -> "Tehlike")
  static const Color dangerRed = Color(0xFFEF4444);

  /// Warning amber
  static const Color warningAmber = Color(0xFFF59E0B);

  /// Info blue
  static const Color infoBlue = Color(0xFF3B82F6);

  // ============================================
  // GRADIENTS
  // ============================================

  /// Primary neon gradient - Main brand gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonMagenta, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Button gradient - For CTAs
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [neonMagenta, neonCoral],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Seductive gradient - Full spectrum
  static const LinearGradient seductiveGradient = LinearGradient(
    colors: [neonPurple, neonMagenta, neonCoral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark fade gradient - For backgrounds
  static const LinearGradient darkFadeGradient = LinearGradient(
    colors: [voidBlack, obsidianDark, velvetPurple],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Glass overlay gradient - For glassmorphism
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glow gradient - For neon effects
  static const RadialGradient glowGradient = RadialGradient(
    colors: [
      Color(0x40FF2D92),
      Color(0x00FF2D92),
    ],
  );

  /// Corner light leak gradient
  static LinearGradient lightLeakGradient(AlignmentGeometry begin) => LinearGradient(
    colors: [
      neonMagenta.withOpacity(0.3),
      neonPurple.withOpacity(0.1),
      Colors.transparent,
    ],
    begin: begin as Alignment,
    end: Alignment.center,
  );

  // ============================================
  // SHADOWS & GLOWS
  // ============================================

  /// Neon glow shadow - For buttons and cards
  static List<BoxShadow> neonGlow({
    Color color = neonMagenta,
    double blur = 20,
    double spread = 0,
  }) => [
    BoxShadow(
      color: color.withOpacity(0.6),
      blurRadius: blur,
      spreadRadius: spread,
    ),
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: blur * 2,
      spreadRadius: spread,
    ),
  ];

  /// Soft shadow - For cards
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /// Deep shadow - For modals
  static List<BoxShadow> deepShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.6),
      blurRadius: 40,
      offset: const Offset(0, 20),
    ),
  ];

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get color with opacity
  static Color withAlpha(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Create a glow color from base
  static Color glowColor(Color base, [double opacity = 0.5]) {
    return base.withOpacity(opacity);
  }
}
