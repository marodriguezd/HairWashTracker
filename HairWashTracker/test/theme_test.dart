import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/models/theme_preference.dart';
import 'package:hair_wash_tracker/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppTheme and M3 Design Tokens Tests', () {
    test('Shape tokens conform to M3 specifications', () {
      expect(AppTheme.radiusCard, 12.0);
      expect(AppTheme.radiusButton, 999.0);
      expect(AppTheme.radiusDialog, 28.0);
      expect(AppTheme.radiusChip, 8.0);
      expect(AppTheme.radiusSmall, 4.0);
    });

    test('8dp spacing system conforms to M3 scale', () {
      expect(AppTheme.spacingScreen, 16.0);
      expect(AppTheme.spacingCard, 16.0);
      expect(AppTheme.spacingItem, 16.0);
      expect(AppTheme.spacingTight, 8.0);
    });

    test('getTheme generates useMaterial3 ThemeData with tonal colorScheme', () {
      final lightTheme = AppTheme.getTheme(AppPresetTheme.warmCoral, Brightness.light);
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.brightness, Brightness.light);
      expect(lightTheme.colorScheme.primary, isNotNull);

      final darkTheme = AppTheme.getTheme(AppPresetTheme.warmCoral, Brightness.dark);
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.brightness, Brightness.dark);
    });

    test('All presets return distinct seed colors', () {
      final seeds = <Color>{};
      for (final preset in AppPresetTheme.values) {
        final seed = AppTheme.getSeedColor(preset);
        // Distinct seeds are what make the four presets visually different.
        expect(seeds.add(seed), isTrue, reason: preset.name);
      }
    });

    test('DynamicScheme override is respected in getTheme', () {
      const customDynamic = ColorScheme.light(
        primary: Color(0xFF123456),
      );

      final theme = AppTheme.getTheme(
        AppPresetTheme.warmCoral,
        Brightness.light,
        dynamicScheme: customDynamic,
      );

      expect(theme.colorScheme.primary, const Color(0xFF123456));
    });
  });

  group('ThemePreference Persistence Tests', () {
    test('getThemeMode defaults to system and persists updates', () async {
      final defaultMode = await ThemePreference.getThemeMode();
      expect(defaultMode, AppThemeMode.system);

      await ThemePreference.setThemeMode(AppThemeMode.dark);
      final updatedMode = await ThemePreference.getThemeMode();
      expect(updatedMode, AppThemeMode.dark);
    });

    test('getThemePreset defaults to warmCoral and persists updates', () async {
      final defaultPreset = await ThemePreference.getThemePreset();
      expect(defaultPreset, AppPresetTheme.warmCoral);

      await ThemePreference.setThemePreset(AppPresetTheme.sageMist);
      final updatedPreset = await ThemePreference.getThemePreset();
      expect(updatedPreset, AppPresetTheme.sageMist);
    });

    test('getUseDynamicColor defaults to true and persists updates', () async {
      final defaultVal = await ThemePreference.getUseDynamicColor();
      expect(defaultVal, isTrue);

      await ThemePreference.setUseDynamicColor(false);
      final updatedVal = await ThemePreference.getUseDynamicColor();
      expect(updatedVal, isFalse);
    });
  });
}
