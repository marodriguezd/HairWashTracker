import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/models/wash_event.dart';
import 'package:hair_wash_tracker/services/data_repository.dart';
import 'package:hair_wash_tracker/services/file_operations_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesRepository Tests', () {
    late SharedPreferencesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = SharedPreferencesRepository();
    });

    test('loadWashEvents returns empty list initially', () async {
      final events = await repository.loadWashEvents();
      expect(events, isEmpty);
    });

    test('saveWashEvents persists events and loadWashEvents retrieves them', () async {
      final initialEvents = [
        WashEvent(date: DateTime(2026, 7, 2)),
        WashEvent(date: DateTime(2026, 7, 5)),
      ];

      await repository.saveWashEvents(initialEvents);
      final loadedEvents = await repository.loadWashEvents();

      expect(loadedEvents.length, 2);
      expect(loadedEvents[0].date, DateTime(2026, 7, 2, 12, 0, 0));
      expect(loadedEvents[1].date, DateTime(2026, 7, 5, 12, 0, 0));
    });

    test('clearWashEvents removes stored events', () async {
      final initialEvents = [
        WashEvent(date: DateTime(2026, 7, 2)),
      ];

      await repository.saveWashEvents(initialEvents);
      await repository.clearWashEvents();
      final loadedEvents = await repository.loadWashEvents();

      expect(loadedEvents, isEmpty);
    });

    test('loadWashEvents handles corrupt JSON gracefully', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wash_events', 'invalid_json_format');

      final loadedEvents = await repository.loadWashEvents();
      expect(loadedEvents, isEmpty);
    });

    test('loadWashEvents keeps valid rows when one entry is corrupt', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wash_events',
          '[{"date":"2026-07-02T12:00:00.000"},{"broken":true},{"date":"2026-07-05T12:00:00.000"}]');

      final loadedEvents = await repository.loadWashEvents();
      // Losing one damaged row must not discard the whole history.
      expect(loadedEvents.map((e) => e.date),
          [DateTime(2026, 7, 2, 12), DateTime(2026, 7, 5, 12)]);
    });
  });

  group('FileOperationsService Serialization Tests', () {
    late FileOperationsService fileOps;

    setUp(() {
      fileOps = FileOperationsService();
    });

    test('exportToJson writes a versioned envelope with ISO-8601 dates',
        () async {
      final events = [
        WashEvent(date: DateTime(2026, 7, 2)),
        WashEvent(date: DateTime(2026, 7, 8)),
      ];

      final payload =
          jsonDecode(await fileOps.exportToJson(events)) as Map<String, dynamic>;

      expect(payload['format'], FileOperationsService.formatId);
      expect(payload['version'], FileOperationsService.backupVersion);
      expect(DateTime.tryParse(payload['exportedAt'] as String), isNotNull);
      expect(payload['events'], [
        {'date': '2026-07-02T12:00:00.000'},
        {'date': '2026-07-08T12:00:00.000'},
      ]);
    });

    test('exportToJson output survives a full write and import round-trip',
        () async {
      final events = [
        WashEvent(date: DateTime(2026, 3, 29)),
        WashEvent(date: DateTime(2026, 10, 25)),
        WashEvent(date: DateTime(2026, 12, 31)),
      ];
      final file = File('${Directory.systemTemp.path}/test_roundtrip.json');
      await file.writeAsString(await fileOps.exportToJson(events));

      final imported = await fileOps.importFromBackup(file.path);

      expect(imported.map((e) => e.date), events.map((e) => e.date));
      await file.delete();
    });

    test('importFromBackup accepts the 1.0.x bare JSON list', () async {
      final file = File('${Directory.systemTemp.path}/test_legacy_list.json');
      await file.writeAsString('[{"date": "2026-09-01T12:00:00.000"}]');

      final imported = await fileOps.importFromBackup(file.path);
      expect(imported.single.date, DateTime(2026, 9, 1, 12));

      await file.delete();
    });

    test('importFromBackup accepts the 1.0.x CSV export', () async {
      final file = File('${Directory.systemTemp.path}/test_legacy.csv');
      await file.writeAsString('Date\r\n2026-08-10\r\n2026-08-14\r\n');

      final imported = await fileOps.importFromBackup(file.path);
      expect(imported.map((e) => e.date),
          [DateTime(2026, 8, 10, 12), DateTime(2026, 8, 14, 12)]);

      await file.delete();
    });

    test('importFromBackup keeps the first date of a headerless CSV', () async {
      final file = File('${Directory.systemTemp.path}/test_headerless.csv');
      await file.writeAsString('2026-08-10\r\n2026-08-14\r\n');

      final imported = await fileOps.importFromBackup(file.path);
      expect(imported.map((e) => e.date),
          [DateTime(2026, 8, 10, 12), DateTime(2026, 8, 14, 12)]);

      await file.delete();
    });

    test('importFromBackup skips CSV rows that are not dates', () async {
      final file = File('${Directory.systemTemp.path}/test_malformed.csv');
      await file.writeAsString('Date\nnot-a-date\n2026-08-10\n');

      final imported = await fileOps.importFromBackup(file.path);
      expect(imported.single.date, DateTime(2026, 8, 10, 12));

      await file.delete();
    });

    test('importFromBackup skips invalid rows inside an envelope', () async {
      final file = File('${Directory.systemTemp.path}/test_partial.json');
      await file.writeAsString(jsonEncode({
        'format': FileOperationsService.formatId,
        'version': 1,
        'events': [
          {'date': '2026-09-01T12:00:00.000'},
          {'oops': 1},
        ],
      }));

      final imported = await fileOps.importFromBackup(file.path);
      expect(imported.single.date, DateTime(2026, 9, 1, 12));

      await file.delete();
    });

    test('importFromBackup tolerates a byte-order mark', () async {
      final file = File('${Directory.systemTemp.path}/test_bom.json');
      await file.writeAsString('\uFEFF[{"date": "2026-09-01T12:00:00.000"}]');

      final imported = await fileOps.importFromBackup(file.path);
      expect(imported.single.date, DateTime(2026, 9, 1, 12));

      await file.delete();
    });

    test('importFromBackup rejects a foreign JSON file', () async {
      final file = File('${Directory.systemTemp.path}/test_foreign.json');
      await file.writeAsString('{"version": 1, "events": []}');

      await expectLater(fileOps.importFromBackup(file.path),
          throwsA(isA<FormatException>()));

      await file.delete();
    });

    test('importFromBackup rejects a newer schema version', () async {
      final file = File('${Directory.systemTemp.path}/test_future.json');
      await file.writeAsString(jsonEncode({
        'format': FileOperationsService.formatId,
        'version': FileOperationsService.backupVersion + 1,
        'events': [],
      }));

      await expectLater(fileOps.importFromBackup(file.path),
          throwsA(isA<FormatException>()));

      await file.delete();
    });

    test('importFromBackup rejects an envelope without a version', () async {
      final file = File('${Directory.systemTemp.path}/test_noversion.json');
      await file.writeAsString(
          jsonEncode({'format': FileOperationsService.formatId, 'events': []}));

      await expectLater(fileOps.importFromBackup(file.path),
          throwsA(isA<FormatException>()));

      await file.delete();
    });

    test('importFromBackup rejects an empty file', () async {
      final file = File('${Directory.systemTemp.path}/test_empty.json');
      await file.writeAsString('   \n');

      await expectLater(
          fileOps.importFromBackup(file.path), throwsA(isA<FormatException>()));

      await file.delete();
    });

    test('importFromBackup fails on a missing file', () async {
      await expectLater(
        fileOps.importFromBackup('${Directory.systemTemp.path}/missing.json'),
        throwsA(isA<Exception>()),
      );
    });

    test('shareFile deletes the temp copy after a successful share', () async {
      String? sharedPath;
      final ops = FileOperationsService(share: (files, text) async {
        final file = File(files.single.path);
        // The receiver must be able to read the file while sharing runs.
        expect(file.existsSync(), isTrue);
        sharedPath = file.path;
      });

      await ops.shareFile('{}', 'cleanup_ok.json');

      expect(sharedPath, isNotNull);
      expect(File(sharedPath!).existsSync(), isFalse);
    });

    test('shareFile deletes the temp copy when sharing fails', () async {
      String? attemptedPath;
      final ops = FileOperationsService(share: (files, text) async {
        attemptedPath = files.single.path;
        throw Exception('share failed');
      });

      await expectLater(ops.shareFile('{}', 'cleanup_fail.json'),
          throwsA(isA<Exception>()));

      expect(attemptedPath, isNotNull);
      expect(File(attemptedPath!).existsSync(), isFalse);
    });
  });
}
