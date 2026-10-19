import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/l10n/app_localizations.dart';
import 'package:hair_wash_tracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLocalizations', () {
    test('exactly six supported languages: en, es, de, fr, it, zh', () {
      expect(AppLocalizations.supportedCodes,
          containsAll(['en', 'es', 'de', 'fr', 'it', 'zh']));
      expect(AppLocalizations.supportedCodes, hasLength(6));
      expect(AppLanguage.supported, hasLength(6));
    });

    test('every language defines exactly the English key set', () {
      final base = AppLocalizations.keys;
      expect(base, isNotEmpty);
      // stringFor() falls back to English, so only a raw key comparison can
      // detect a translation that was never added.
      for (final code in AppLocalizations.supportedCodes) {
        expect(AppLocalizations.keysFor(code), equals(base), reason: code);
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

    test('navigation labels are translated in every language', () {
      // A short English label can hide behind stringFor() fallbacks: assert
      // each tab explicitly so "Stats" cannot leak back into a localised UI.
      expect(AppLocalizations.stringFor('es', 'navStats'), 'Estadísticas');
      expect(AppLocalizations.stringFor('de', 'navStats'), 'Statistiken');
      expect(AppLocalizations.stringFor('fr', 'navStats'), 'Statistiques');
      expect(AppLocalizations.stringFor('it', 'navStats'), 'Statistiche');
      expect(AppLocalizations.stringFor('zh', 'navStats'), '统计');
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

    testWidgets('non-English locale has Material localizations', (tester) async {
      SharedPreferences.setMockInitialValues({'app_language': 'es'});

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // MaterialApp must ship global delegates: without them AppBar and the
      // navigation shell throw "No MaterialLocalizations found" once the
      // locale is anything but English.
      expect(tester.takeException(), isNull);
      expect(find.text('Calendario'), findsOneWidget);
      // The calendar formats dates with intl, so it must follow the locale too.
      expect(find.text('lun'), findsOneWidget);
    });
  });
}
