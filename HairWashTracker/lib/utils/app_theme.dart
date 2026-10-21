import 'package:flutter/material.dart';
import '../models/theme_preference.dart';

/// Design tokens for Hair Wash Tracker.
///
/// Colors are always resolved through the Material 3 [ColorScheme]; widgets
/// never hardcode a brand color, so dynamic color and contrast modes apply.
/// Only the seed colors live here, because each preset needs a stable,
/// theme-independent swatch for the settings picker.
class AppTheme {
  /// MD3 shape tokens (spec): medium 12, large 16, xl 28, full pill
  static const double radiusCard = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusButton = 999.0;
  static const double radiusDialog = 28.0;

  /// MD3 8dp spacing scale
  static const double spacingScreen = 16.0;
  static const double spacingCard = 16.0;

  /// Content width cap on large screens: one column never exceeds this.
  static const double contentMaxWidth = 840.0;

  /// The M3 type scale is brightness-independent: on-surface colors come from
  /// the [ColorScheme], so one definition serves both themes.
  static const TextTheme _textTheme = TextTheme(
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

  static const Color _warmCoralSeed = Color(0xFFE07A5F);
  static const Color _lavenderSeed = Color(0xFF9B5DE5);
  static const Color _sageSeed = Color(0xFF588157);
  static const Color _oceanSeed = Color(0xFF0077B6);

  static Color getSeedColor(AppPresetTheme preset) {
    switch (preset) {
      case AppPresetTheme.warmCoral:
        return _warmCoralSeed;
      case AppPresetTheme.lavenderMist:
        return _lavenderSeed;
      case AppPresetTheme.sageMist:
        return _sageSeed;
      case AppPresetTheme.oceanBlue:
        return _oceanSeed;
    }
  }

  static ThemeData getTheme(AppPresetTheme preset, Brightness brightness,
      {ColorScheme? dynamicScheme}) {
    final seed = getSeedColor(preset);
    // Dynamic color (Android 12+) wins when available; otherwise use the seed-generated tonal scheme.
    final ColorScheme scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(radiusDialog)),
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
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 2,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
        titleTextStyle: _textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      textTheme: _textTheme,
    );
  }
}
