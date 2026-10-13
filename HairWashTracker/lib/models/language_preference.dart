import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI language: `'auto'` follows the system locale, otherwise one
/// of the [AppLocalizations.supportedCodes] codes (`en`, `es`, `de`, `fr`,
/// `it`, `zh`). Mirrors the [ThemePreference] pattern.
class LanguagePreference {
  static const String _key = 'app_language';
  static const String auto = 'auto';

  static Future<String> getLanguageCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key) ?? auto;
    } catch (e) {
      return auto;
    }
  }

  static Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }
}
