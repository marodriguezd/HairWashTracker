import 'package:shared_preferences/shared_preferences.dart';

class ThemePreference {
  static const String _key = 'theme_mode';

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
}

enum AppThemeMode { system, light, dark }
