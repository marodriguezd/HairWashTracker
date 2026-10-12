import 'package:flutter/material.dart';
import '../models/theme_preference.dart';

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

  /// MD3 shape tokens (spec): xs 4, small 8, medium 12, large 16, xl 28, full pill
  static const double radiusCard = 12.0;
  static const double radiusButton = 999.0;
  static const double radiusSmall = 4.0;
  static const double radiusChip = 8.0;
  static const double radiusDialog = 28.0;

  /// MD3 8dp spacing scale
  static const double spacingScreen = 16.0;
  static const double spacingCard = 16.0;
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
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
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
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      );

  static ThemeData lightTheme = getTheme(AppPresetTheme.warmCoral, Brightness.light);

  static ThemeData darkTheme = getTheme(AppPresetTheme.warmCoral, Brightness.dark);

  static Color getSeedColor(AppPresetTheme preset) {
    switch (preset) {
      case AppPresetTheme.warmCoral:
        return const Color(0xFFE07A5F);
      case AppPresetTheme.lavenderMist:
        return const Color(0xFF9B5DE5);
      case AppPresetTheme.sageMist:
        return const Color(0xFF588157);
      case AppPresetTheme.oceanBlue:
        return const Color(0xFF0077B6);
    }
  }

  static Color getSurfaceColor(AppPresetTheme preset, Brightness brightness) {
    if (brightness == Brightness.light) {
      switch (preset) {
        case AppPresetTheme.warmCoral:
          return const Color(0xFFF4F1DE);
        case AppPresetTheme.lavenderMist:
          return const Color(0xFFFAF2E4);
        case AppPresetTheme.sageMist:
          return const Color(0xFFEBF0E9);
        case AppPresetTheme.oceanBlue:
          return const Color(0xFFEAF5FA);
      }
    } else {
      switch (preset) {
        case AppPresetTheme.warmCoral:
          return const Color(0xFF3D405B);
        case AppPresetTheme.lavenderMist:
          return const Color(0xFF1E132D);
        case AppPresetTheme.sageMist:
          return const Color(0xFF1A261D);
        case AppPresetTheme.oceanBlue:
          return const Color(0xFF0B1B2C);
      }
    }
  }

  static List<Color> getGradientColors(AppPresetTheme preset, Brightness brightness) {
    final primary = getSeedColor(preset);
    final surface = getSurfaceColor(preset, brightness);
    if (brightness == Brightness.light) {
      return [
        surface,
        Color.lerp(surface, primary, 0.08) ?? surface,
      ];
    } else {
      return [
        surface,
        Color.lerp(surface, primary, 0.12) ?? surface,
      ];
    }
  }

  static ThemeData getTheme(AppPresetTheme preset, Brightness brightness,
      {ColorScheme? dynamicScheme}) {
    final seed = getSeedColor(preset);
    final isDark = brightness == Brightness.dark;
    // Dynamic color (Android 12+) wins when available; otherwise use the seed-generated tonal scheme.
    final ColorScheme scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final textTheme = isDark ? _darkTextTheme : _lightTextTheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusDialog),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 2,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      textTheme: textTheme,
    );
  }
}
