// TryOn App Theme - Premium Design System
import 'package:flutter/material.dart';
import 'dart:ui';

// ============================================================================
// COLORS - Premium Dark Theme Palette
// ============================================================================
class AppColors {
  // Primary - Vibrant Indigo
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryGlow = Color(0x406366F1);

  // Secondary - Hot Pink
  static const Color secondary = Color(0xFFEC4899);
  static const Color secondaryDark = Color(0xFFDB2777);
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryGlow = Color(0x40EC4899);

  // Accent Colors
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentGlow = Color(0x4006B6D4);
  static const Color gold = Color(0xFFFFD700);
  static const Color neon = Color(0xFF00FF88);

  // Neutrals - Deep Space
  static const Color background = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF12121A);
  static const Color surfaceLight = Color(0xFF1E1E2E);
  static const Color surfaceBright = Color(0xFF2A2A3E);
  static const Color card = Color(0xFF151520);

  // Glass Effect Colors
  static const Color glassBorder = Color(0x20FFFFFF);
  static const Color glassBackground = Color(0x10FFFFFF);
  static const Color glassSurface = Color(0x08FFFFFF);

  // Text
  static const Color text = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B4C0);
  static const Color textMuted = Color(0xFF6B6B80);
  static const Color textDim = Color(0xFF4A4A5A);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color successGlow = Color(0x4010B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorGlow = Color(0x40EF4444);

  // Gradients
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
  ];
  
  static const List<Color> gradientSecondary = [
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
  ];
  
  static const List<Color> gradientSuccess = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  
  static const List<Color> gradientSunset = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
  ];
  
  static const List<Color> gradientOcean = [
    Color(0xFF667EEA),
    Color(0xFF64B5F6),
  ];
  
  static const List<Color> gradientNeon = [
    Color(0xFF00FF88),
    Color(0xFF00D4FF),
  ];
}

// Spacing
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

// Border Radius
class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get xlRadius => BorderRadius.circular(xl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

// Typography
class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.text,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    color: AppColors.text,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    color: AppColors.text,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.text,
  );
}

// ============================================================================
// SHADOWS - Enhanced with Glow Effects
// ============================================================================
class AppShadows {
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          offset: const Offset(0, 2),
          blurRadius: 4,
        ),
      ];

  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];

  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          offset: const Offset(0, 8),
          blurRadius: 24,
        ),
      ];

  // Glow shadows for buttons and accents
  static List<BoxShadow> primaryGlow(double opacity) => [
        BoxShadow(
          color: AppColors.primary.withOpacity(opacity),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> secondaryGlow(double opacity) => [
        BoxShadow(
          color: AppColors.secondary.withOpacity(opacity),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> successGlow(double opacity) => [
        BoxShadow(
          color: AppColors.success.withOpacity(opacity),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 20,
        ),
      ];
}

// ============================================================================
// ANIMATIONS - Timing Constants
// ============================================================================
class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration enter = Duration(milliseconds: 300);
  static const Duration exit = Duration(milliseconds: 200);

  // Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeOutCubic;
  
  // Scale factors
  static const double pressScale = 0.96;
  static const double hoverScale = 1.02;
}

// App Theme Data
class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h3,
          iconTheme: IconThemeData(color: AppColors.text),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: AppRadius.mediumRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumRadius,
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.mediumRadius,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.mediumRadius,
            ),
            textStyle: AppTypography.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTypography.body,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.largeRadius,
          ),
          elevation: 0,
        ),
      );
}
