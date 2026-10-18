import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/models/theme_preference.dart';
import 'package:hair_wash_tracker/models/wash_event.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import 'package:hair_wash_tracker/services/data_repository.dart';
import 'package:hair_wash_tracker/services/file_operations_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockDataRepository implements IDataRepository {
  List<WashEvent> events = [];
  bool saveCalled = false;
  bool loadCalled = false;
  bool clearCalled = false;

  @override
  Future<List<WashEvent>> loadWashEvents() async {
    loadCalled = true;
    return events;
  }

  @override
  Future<void> saveWashEvents(List<WashEvent> events) async {
    saveCalled = true;
    this.events = List.from(events);
  }

  @override
  Future<void> clearWashEvents() async {
    clearCalled = true;
    events.clear();
  }
}

class MockFileOperations implements IFileOperations {
  String csvContent = "Date\n2026-07-02";
  String jsonContent = "[]";
  List<WashEvent> importedEvents = [WashEvent(date: DateTime(2026, 7, 2))];
  bool exportCSVCalled = false;
  bool importCSVCalled = false;
  bool exportJsonCalled = false;
  bool importJsonCalled = false;
  bool shareCalled = false;

  @override
  Future<String> exportToCSV(List<WashEvent> events) async {
    exportCSVCalled = true;
    return csvContent;
  }

  @override
  Future<List<WashEvent>> importFromCSV(String filePath) async {
    importCSVCalled = true;
    return importedEvents;
  }

  @override
  Future<String> exportToJson(List<WashEvent> events) async {
    exportJsonCalled = true;
    return jsonContent;
  }

  @override
  Future<List<WashEvent>> importFromJson(String filePath) async {
    importJsonCalled = true;
    return importedEvents;
  }

  @override
  Future<void> shareFile(String content, String filename) async {
    shareCalled = true;
  }
}

void main() {
  // Ensure SharedPreferences is mocked since ThemePreference uses SharedPreferences.getInstance()
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppController Tests', () {
    late MockDataRepository mockRepository;
    late MockFileOperations mockFileOps;
    late AppController controller;

    setUp(() {
      mockRepository = MockDataRepository();
      mockFileOps = MockFileOperations();
      controller = AppController(
        repository: mockRepository,
        fileOperations: mockFileOps,
      );
    });

    test('Initial state loads correctly', () async {
      // Allow async initial loads to finish
      await Future.delayed(Duration.zero);
      expect(mockRepository.loadCalled, isTrue);
      expect(controller.selectedEvents, isEmpty);
      expect(controller.themeMode, AppThemeMode.system);
    });

    test('toggleWashDay adds and removes wash events', () async {
      await Future.delayed(Duration.zero);
      final day = DateTime(2026, 7, 2);

      // Verify toggle wash day on
      controller.toggleWashDay(day);
      expect(controller.isWashDay(day), isTrue);
      expect(controller.selectedEvents.length, 1);
      expect(mockRepository.saveCalled, isTrue);

      // Verify toggle wash day off
      mockRepository.saveCalled = false;
      controller.toggleWashDay(day);
      expect(controller.isWashDay(day), isFalse);
      expect(controller.selectedEvents, isEmpty);
      expect(mockRepository.saveCalled, isTrue);
    });

    test('Month navigation works', () {
      final initialDate = controller.focusedDay;
      controller.nextMonth();
      expect(controller.focusedDay.month, (initialDate.month % 12) + 1);

      controller.previousMonth();
      expect(controller.focusedDay.month, initialDate.month);
    });

    test('Theme setting updates state', () {
      controller.setThemeMode(AppThemeMode.dark);
      expect(controller.themeMode, AppThemeMode.dark);
    });

    test('clearAllData clears state and repository', () async {
      await Future.delayed(Duration.zero);
      controller.toggleWashDay(DateTime(2026, 7, 2));

      await controller.clearAllData();
      expect(controller.selectedEvents, isEmpty);
      expect(mockRepository.clearCalled, isTrue);
    });

    test('exportData and exportDataJson delegate to operations', () async {
      await controller.exportData();
      expect(mockFileOps.exportCSVCalled, isTrue);
      expect(mockFileOps.shareCalled, isTrue);

      await controller.exportDataJson();
      expect(mockFileOps.exportJsonCalled, isTrue);
    });

    test('averageInterval, medianInterval and nextRecommendedWashDate expose correct values', () async {
      await Future.delayed(Duration.zero);
      expect(controller.averageInterval, 0.0);
      expect(controller.medianInterval, 0.0);
      expect(controller.nextRecommendedWashDate, isNull);

      controller.toggleWashDay(DateTime(2026, 7, 2));
      expect(controller.averageInterval, 0.0);
      expect(controller.medianInterval, 0.0);
      // Single event: uses prior of 3 days
      expect(controller.nextRecommendedWashDate, isNotNull);
      expect(controller.nextRecommendedWashDate!.isAfter(DateTime(2026, 7, 2, 12, 0, 0)), isTrue);

      controller.toggleWashDay(DateTime(2026, 7, 6)); // 4 days later
      expect(controller.averageInterval, 4.0);
      expect(controller.medianInterval, 4.0); // same as avg for 1 interval
      // With EWMA, next wash should be after the last wash
      expect(controller.nextRecommendedWashDate, isNotNull);
      expect(controller.nextRecommendedWashDate!.isAfter(DateTime(2026, 7, 6, 12, 0, 0)), isTrue);
    });

    test('predictedWashDates returns predictions from last wash forward', () async {
      await Future.delayed(Duration.zero);
      expect(controller.predictedWashDates, isEmpty);

      controller.toggleWashDay(DateTime(2026, 7, 2));
      controller.toggleWashDay(DateTime(2026, 7, 5)); // 3-day interval

      final predicted = controller.predictedWashDates;
      expect(predicted, isNotEmpty);

      // All predictions should be after the last wash
      for (final date in predicted) {
        expect(date.isAfter(DateTime(2026, 7, 5, 12, 0, 0)), isTrue);
      }
    });

    test('isPredictedWashDay returns true for predicted dates', () async {
      await Future.delayed(Duration.zero);
      controller.toggleWashDay(DateTime(2026, 7, 2));
      controller.toggleWashDay(DateTime(2026, 7, 5)); // 3-day interval

      // predictedWashDates only includes future dates
      // So check that the first predicted date returns true
      final predicted = controller.predictedWashDates;
      if (predicted.isNotEmpty) {
        expect(controller.isPredictedWashDay(predicted.first), isTrue);
      }

      // A non-predicted day should return false
      expect(controller.isPredictedWashDay(DateTime(2020, 1, 1)), isFalse);

      // Past wash days should not be marked as predicted
      expect(controller.isPredictedWashDay(DateTime(2026, 7, 2)), isFalse);
      expect(controller.isPredictedWashDay(DateTime(2026, 7, 5)), isFalse);
    });

    test('themePreset loading and updating works', () async {
      await Future.delayed(Duration.zero);
      expect(controller.themePreset, AppPresetTheme.warmCoral);

      controller.setThemePreset(AppPresetTheme.lavenderMist);
      expect(controller.themePreset, AppPresetTheme.lavenderMist);
    });

    test('dynamic color defaults to system and preset opts out', () async {
      await Future.delayed(Duration.zero);
      expect(controller.useDynamicColor, isTrue);

      controller.setThemePreset(AppPresetTheme.oceanBlue);
      expect(controller.useDynamicColor, isFalse);
      expect(controller.themePreset, AppPresetTheme.oceanBlue);

      controller.setUseDynamicColor(true);
      expect(controller.useDynamicColor, isTrue);
    });

    test('importData reports a cancelled picker without importing', () async {
      final repository = MockDataRepository();
      final ops = MockFileOperations();
      final cancelled = AppController(
        repository: repository,
        fileOperations: ops,
        pickFile: (_) async => null,
      );
      await Future.delayed(Duration.zero);

      expect(await cancelled.importData(), isFalse);
      expect(ops.importCSVCalled, isFalse);
      expect(cancelled.selectedEvents, isEmpty);
    });

    test('importData imports the picked file and returns true', () async {
      final repository = MockDataRepository();
      final ops = MockFileOperations();
      final importing = AppController(
        repository: repository,
        fileOperations: ops,
        pickFile: (_) async => '/tmp/backup.csv',
      );
      await Future.delayed(Duration.zero);

      expect(await importing.importData(), isTrue);
      expect(ops.importCSVCalled, isTrue);
      expect(importing.selectedEvents, hasLength(1));
      expect(importing.totalWashes, 1);
    });

    test('month navigation clamps the day instead of overflowing', () {
      controller.setFocusedDay(DateTime(2026, 1, 31));
      controller.nextMonth();
      expect(controller.focusedDay, DateTime(2026, 2, 28));

      controller.nextMonth();
      expect(controller.focusedDay, DateTime(2026, 3, 28));

      controller.setFocusedDay(DateTime(2026, 3, 31));
      controller.previousMonth();
      expect(controller.focusedDay, DateTime(2026, 2, 28));
    });

    test('importData rejects a backup with no usable dates', () async {
      final repository = MockDataRepository();
      final ops = MockFileOperations()..importedEvents = [];
      final importing = AppController(
        repository: repository,
        fileOperations: ops,
        pickFile: (_) async => '/tmp/empty.csv',
      );
      await Future.delayed(Duration.zero);
      importing.toggleWashDay(DateTime(2026, 7, 2));

      await expectLater(importing.importData(), throwsA(isA<Exception>()));
      // A failed restore must leave the existing history untouched.
      expect(importing.isWashDay(DateTime(2026, 7, 2)), isTrue);
    });

    test('predictedWashDates cannot mutate the cached prediction', () async {
      await Future.delayed(Duration.zero);
      controller.toggleWashDay(DateTime(2026, 7, 2));

      final dates = controller.predictedWashDates;
      expect(dates, isNotEmpty);
      expect(() => dates.add(DateTime(2030)), throwsUnsupportedError);
    });

    test('duplicate days from storage collapse into one event', () async {
      final repository = MockDataRepository()
        ..events = [
          WashEvent(date: DateTime(2026, 7, 2, 8)),
          WashEvent(date: DateTime(2026, 7, 2, 20)),
          WashEvent(date: DateTime(2026, 7, 5)),
        ];
      final deduped = AppController(
        repository: repository,
        fileOperations: mockFileOps,
      );

      await Future.delayed(Duration.zero);

      expect(deduped.selectedEvents, hasLength(2));
      expect(deduped.isWashDay(DateTime(2026, 7, 2)), isTrue);
      expect(deduped.totalWashes, 2);
    });

    test('cached prediction is invalidated when a wash day changes', () async {
      await Future.delayed(Duration.zero);

      controller.toggleWashDay(DateTime(2026, 7, 2));
      final before = controller.predictedWashDates;

      controller.toggleWashDay(DateTime(2026, 7, 5));
      final after = controller.predictedWashDates;

      expect(identical(before, after), isFalse);
      expect(after, isNotEmpty);
      for (final date in after) {
        expect(date.isAfter(DateTime(2026, 7, 5, 12)), isTrue);
      }
      expect(controller.isPredictedWashDay(after.first), isTrue);
    });
  });
}
