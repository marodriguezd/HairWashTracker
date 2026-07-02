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
    return [WashEvent(date: DateTime(2026, 7, 2))];
  }

  @override
  Future<String> exportToJson(List<WashEvent> events) async {
    exportJsonCalled = true;
    return jsonContent;
  }

  @override
  Future<List<WashEvent>> importFromJson(String filePath) async {
    importJsonCalled = true;
    return [WashEvent(date: DateTime(2026, 7, 2))];
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

    test('Theme setting and animation config updates state', () {
      controller.setThemeMode(AppThemeMode.dark);
      expect(controller.themeMode, AppThemeMode.dark);

      controller.setUseComplexAnimations(false);
      expect(controller.useComplexAnimations, isFalse);
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

    test('averageInterval and nextRecommendedWashDate expose correct values', () async {
      await Future.delayed(Duration.zero);
      expect(controller.averageInterval, 0.0);
      expect(controller.nextRecommendedWashDate, isNull);

      controller.toggleWashDay(DateTime(2026, 7, 2));
      expect(controller.averageInterval, 0.0);
      expect(controller.nextRecommendedWashDate, DateTime(2026, 7, 5, 12, 0, 0));

      controller.toggleWashDay(DateTime(2026, 7, 6)); // 4 days later
      expect(controller.averageInterval, 4.0);
      expect(controller.nextRecommendedWashDate, DateTime(2026, 7, 10, 12, 0, 0));
    });

    test('themePreset loading and updating works', () async {
      await Future.delayed(Duration.zero);
      expect(controller.themePreset, AppPresetTheme.warmCoral);

      controller.setThemePreset(AppPresetTheme.lavenderMist);
      expect(controller.themePreset, AppPresetTheme.lavenderMist);
    });
  });
}
