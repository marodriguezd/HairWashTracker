import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

enum AppPresetTheme { warmCoral, lavenderMist, sageMist, oceanBlue }

class ThemePreference {
  static const String _key = 'theme_mode';
  static const String _presetKey = 'theme_preset';
  static const String _dynamicKey = 'use_dynamic_color';

  static Future<AppThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_key);
      if (value == null) return AppThemeMode.system;
      return AppThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppThemeMode.system,
      );
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  static Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  static Future<AppPresetTheme> getThemePreset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_presetKey);
      if (value == null) return AppPresetTheme.warmCoral;
      return AppPresetTheme.values.firstWhere(
        (e) => e.name == value,
        orElse: () => AppPresetTheme.warmCoral,
      );
    } catch (e) {
      return AppPresetTheme.warmCoral;
    }
  }

  static Future<void> setThemePreset(AppPresetTheme preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_presetKey, preset.name);
  }

  /// Whether system dynamic color is used instead of the seed preset.
  /// Defaults to true so fresh installs follow the wallpaper accent.
  static Future<bool> getUseDynamicColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_dynamicKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  static Future<void> setUseDynamicColor(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicKey, value);
  }
}
