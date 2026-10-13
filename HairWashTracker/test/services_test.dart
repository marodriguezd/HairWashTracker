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
  });

  group('FileOperationsService Serialization Tests', () {
    late FileOperationsService fileOps;

    setUp(() {
      fileOps = FileOperationsService();
    });

    test('exportToCSV formats dates with Date header and yyyy-MM-dd rows', () async {
      final events = [
        WashEvent(date: DateTime(2026, 7, 2)),
        WashEvent(date: DateTime(2026, 7, 8)),
      ];

      final csv = await fileOps.exportToCSV(events);
      final lines = csv.trim().split('\n');

      expect(lines.first.trim(), 'Date');
      expect(lines[1].trim(), '2026-07-02');
      expect(lines[2].trim(), '2026-07-08');
    });

    test('exportToJson serializes list of WashEvents correctly', () async {
      final events = [
        WashEvent(date: DateTime(2026, 7, 2)),
      ];

      final jsonString = await fileOps.exportToJson(events);
      expect(jsonString, contains('2026-07-02T12:00:00.000'));
    });

    test('importFromCSV parses valid CSV file content normalized to noon', () async {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/test_import.csv');
      await file.writeAsString('Date\n2026-08-10\n2026-08-14\n');

      final imported = await fileOps.importFromCSV(file.path);
      expect(imported.length, 2);
      expect(imported[0].date, DateTime(2026, 8, 10, 12, 0, 0));
      expect(imported[1].date, DateTime(2026, 8, 14, 12, 0, 0));

      await file.delete();
    });

    test('importFromJson parses valid JSON file content', () async {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/test_import.json');
      await file.writeAsString('[{"date": "2026-09-01T12:00:00.000"}]');

      final imported = await fileOps.importFromJson(file.path);
      expect(imported.length, 1);
      expect(imported.first.date, DateTime(2026, 9, 1, 12, 0, 0));

      await file.delete();
    });
  });
}
