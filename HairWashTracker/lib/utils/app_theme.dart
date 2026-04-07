import 'package:flutter/material.dart';

/// AppTheme - Design system for Hair Wash Tracker
///
/// Color Palette (Salon Luxury):
/// - warmCoral: Primary accent color - warm, inviting, salon feel
/// - softSand: Secondary accent - warm neutrals, luxury tones
/// - sageMist: Tertiary - muted green for freshness hints
/// - warmCream: Light background - warm, inviting
/// - deepCharcoal: Dark background - sophisticated, modern
/// - peachBlush: Alternative accent - soft highlights, glows
///
/// Border Radius Standards:
/// - Cards/Containers: 24.0 (large elements)
/// - Buttons/Chips/Badges: 12.0 (small elements)
/// - Circular elements: 70.0 (full circles)
/// - Icons in circles: Uses circular shape with padding
///
/// Spacing Standards:
/// - Screen padding: 16.0 horizontal
/// - Card padding: 24.0 (vertical and horizontal)
/// - Item spacing: 16.0 between major elements
/// - Tight spacing: 8.0 between related elements
///
/// WCAG AA Contrast Compliance:
/// - Primary text on surface: ≥ 4.5:1
/// - Large text: ≥ 3:1
/// - Interactive elements: ≥ 3:1
class AppTheme {
  static const Color warmCoral = Color(0xFFE07A5F);
  static const Color softSand = Color(0xFFF2CC8F);
  static const Color sageMist = Color(0xFF81B29A);
  static const Color warmCream = Color(0xFFF4F1DE);
  static const Color deepCharcoal = Color(0xFF3D405B);
  static const Color peachBlush = Color(0xFFF4A261);

  static const Color lightGradientStart = Color(0xFFF4F1DE);
  static const Color lightGradientEnd = Color(0xFFFDF6E3);
  static const Color darkGradientStart = Color(0xFF3D405B);
  static const Color darkGradientEnd = Color(0xFF2D3040);

  /// Standard border radius values
  static const double radiusCard = 24.0;
  static const double radiusButton = 16.0;
  static const double radiusSmall = 12.0;
  static const double radiusChip = 8.0;

  /// Standard spacing values
  static const double spacingScreen = 16.0;
  static const double spacingCard = 24.0;
  static const double spacingItem = 16.0;
  static const double spacingTight = 8.0;

  static TextTheme get _lightTextTheme => const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

  static TextTheme get _darkTextTheme => const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: warmCoral,
      brightness: Brightness.light,
      primary: warmCoral,
      secondary: softSand,
      tertiary: sageMist,
      surface: warmCream,
      surfaceContainerHighest: warmCream,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _lightTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: _lightTextTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: warmCoral,
      brightness: Brightness.dark,
      primary: warmCoral,
      secondary: softSand,
      tertiary: sageMist,
      surface: deepCharcoal,
      surfaceContainerHighest: deepCharcoal,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _darkTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: _darkTextTheme,
  );
}
