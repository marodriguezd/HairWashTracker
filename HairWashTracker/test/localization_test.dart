import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('exactly six supported languages: en, es, de, fr, it, zh', () {
      expect(AppLocalizations.supportedCodes,
          containsAll(['en', 'es', 'de', 'fr', 'it', 'zh']));
      expect(AppLocalizations.supportedCodes, hasLength(6));
      expect(AppLanguage.supported, hasLength(6));
    });

    test('every language exposes exactly the English key set', () {
      final base = AppLocalizations.keys;
      expect(base, isNotEmpty);
      for (final code in AppLocalizations.supportedCodes) {
        if (code == 'en') continue;
        for (final key in base) {
          expect(AppLocalizations.stringFor(code, key), isNotEmpty,
              reason: 'key $key in $code');
        }
      }
    });

    test('no blank values and no untranslated English copies left blank', () {
      for (final code in AppLocalizations.supportedCodes) {
        for (final key in AppLocalizations.keys) {
          final value = AppLocalizations.stringFor(code, key);
          expect(value.trim(), isNotEmpty, reason: '$code:$key');
          expect(value, isNot(equals(key)), reason: '$code:$key');
        }
      }
    });

    test('{n} placeholders survive in parameterized strings', () {
      for (final code in AppLocalizations.supportedCodes) {
        expect(AppLocalizations.stringFor(code, 'statsDaysActive'),
            contains('{n}'),
            reason: code);
        expect(AppLocalizations.stringFor(code, 'statsWashes'), contains('{n}'),
            reason: code);
      }
      expect(
          AppLocalizations.stringFor('es', 'statsDaysActive', {'n': '3'}),
          '3 días activos');
    });

    test('representative values are genuinely translated', () {
      expect(AppLocalizations.stringFor('es', 'navCalendar'), 'Calendario');
      expect(AppLocalizations.stringFor('de', 'navCalendar'), 'Kalender');
      expect(AppLocalizations.stringFor('fr', 'navCalendar'), 'Calendrier');
      expect(AppLocalizations.stringFor('it', 'navCalendar'), 'Calendario');
      expect(AppLocalizations.stringFor('zh', 'navCalendar'), '日历');
      expect(AppLocalizations.stringFor('fr', 'dlgCancel'), 'Annuler');
      expect(AppLocalizations.stringFor('zh', 'dlgCancel'), '取消');
    });

    test('unknown language falls back to English', () {
      expect(AppLocalizations.stringFor('pt', 'navCalendar'), 'Calendar');
      expect(AppLocalizations.stringFor('xx', 'dlgCancel'), 'Cancel');
    });

    test('resolveStored keeps supported codes and detects first run', () {
      expect(AppLocalizations.resolveStored('de', systemLanguage: 'fr'), 'de');
      expect(AppLocalizations.resolveStored('fr', systemLanguage: 'en'), 'fr');
      expect(AppLocalizations.resolveStored('pt', systemLanguage: 'en'), 'en');
      expect(AppLocalizations.resolveStored('', systemLanguage: 'it'), 'it');
      expect(AppLocalizations.resolveStored('auto', systemLanguage: 'es'), 'es');
      expect(AppLocalizations.resolveStored(null, systemLanguage: 'fr'), 'fr');
    });

    test('systemDefaultCode maps OS locales, Traditional Chinese to English',
        () {
      expect(AppLocalizations.systemDefaultCode('en'), 'en');
      expect(AppLocalizations.systemDefaultCode('es'), 'es');
      expect(AppLocalizations.systemDefaultCode('de'), 'de');
      expect(AppLocalizations.systemDefaultCode('fr'), 'fr');
      expect(AppLocalizations.systemDefaultCode('it'), 'it');
      expect(AppLocalizations.systemDefaultCode('zh'), 'zh');
      expect(AppLocalizations.systemDefaultCode('zh', 'Hant'), 'en');
      expect(AppLocalizations.systemDefaultCode('zh', null, 'TW'), 'en');
      expect(AppLocalizations.systemDefaultCode('pt'), 'en');
      expect(AppLocalizations.systemDefaultCode('ja'), 'en');
      expect(AppLocalizations.systemDefaultCode(null), 'en');
    });
  });
}
