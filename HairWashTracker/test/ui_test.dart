import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/models/wash_event.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import 'package:hair_wash_tracker/services/data_repository.dart';
import 'package:hair_wash_tracker/services/file_operations_service.dart';
import 'package:hair_wash_tracker/ui/pages/home_page.dart';
import 'package:hair_wash_tracker/ui/pages/stats_page.dart';
import 'package:hair_wash_tracker/ui/widgets/confirmation_dialog.dart';
import 'package:hair_wash_tracker/ui/widgets/data_management_sheet.dart';
import 'package:hair_wash_tracker/ui/widgets/empty_state.dart';
import 'package:hair_wash_tracker/ui/widgets/monthly_washes_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeDataRepository implements IDataRepository {
  List<WashEvent> events = [];
  bool clearCalled = false;

  @override
  Future<List<WashEvent>> loadWashEvents() async => events;

  @override
  Future<void> saveWashEvents(List<WashEvent> newEvents) async {
    events = List.from(newEvents);
  }

  @override
  Future<void> clearWashEvents() async {
    clearCalled = true;
    events.clear();
  }
}

class FakeFileOperations implements IFileOperations {
  bool exportCalled = false;
  bool shareCalled = false;

  @override
  Future<String> exportToCSV(List<WashEvent> events) async {
    exportCalled = true;
    return "Date\n2026-10-13";
  }

  @override
  Future<List<WashEvent>> importFromCSV(String filePath) async => [];

  @override
  Future<String> exportToJson(List<WashEvent> events) async => "[]";

  @override
  Future<List<WashEvent>> importFromJson(String filePath) async => [];

  @override
  Future<void> shareFile(String content, String filename) async {
    shareCalled = true;
  }
}

Widget createTestApp({
  required AppController controller,
  Widget? child,
}) {
  return ChangeNotifierProvider<AppController>.value(
    value: controller,
    child: MaterialApp(
      home: child ?? const HomePage(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Widget and UI Tests', () {
    late FakeDataRepository repository;
    late FakeFileOperations fileOps;
    late AppController controller;

    setUp(() {
      repository = FakeDataRepository();
      fileOps = FakeFileOperations();
      controller = AppController(
        repository: repository,
        fileOperations: fileOps,
      );
    });

    testWidgets('HomePage displays AppBar, Calendar, and adaptive navigation with 3 items', (tester) async {
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Hair Wash Tracker'), findsOneWidget);
      final hasNavBar = find.byType(NavigationBar).evaluate().isNotEmpty;
      final hasNavRail = find.byType(NavigationRail).evaluate().isNotEmpty;
      expect(hasNavBar || hasNavRail, isTrue);
      expect(find.byIcon(Icons.calendar_month_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byType(MonthlyWashesWidget), findsOneWidget);
    });

    testWidgets('Tapping Stats destination switches to Statistics page', (tester) async {
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      // Tap on Stats tab
      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      // Empty state shown because totalWashes == 0
      expect(find.byType(EmptyState), findsOneWidget);
      expect(find.text('No Washes Yet'), findsOneWidget);
    });

    testWidgets('Tapping Settings destination switches to Settings screen', (tester) async {
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      // Tap on Settings tab in NavigationBar
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Accent color'), findsOneWidget);
    });

    testWidgets('Data management icon in AppBar opens DataManagementSheet', (tester) async {
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      final folderIcon = find.byIcon(Icons.folder_outlined);
      expect(folderIcon, findsOneWidget);

      await tester.tap(folderIcon);
      await tester.pumpAndSettle();

      expect(find.byType(DataManagementSheet), findsOneWidget);
      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('Export Data (CSV)'), findsOneWidget);
      expect(find.text('Import Data (CSV)'), findsOneWidget);
      expect(find.text('Clear all data'), findsOneWidget);
    });

    testWidgets('StatsPage displays Hero card and routine metrics when washes exist', (tester) async {
      // Add wash events
      controller.toggleWashDay(DateTime(2026, 7, 2));
      controller.toggleWashDay(DateTime(2026, 7, 5));

      await tester.pumpWidget(createTestApp(
        controller: controller,
        child: const StatsPage(),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Next Recommended Wash'), findsOneWidget);
      expect(find.text('Routine cadence'), findsOneWidget);
      expect(find.text('Volume overview'), findsOneWidget);
      expect(find.text('All time'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
    });

    testWidgets('ConfirmationDialog calls onConfirm when confirmed', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ConfirmationDialog(
                    title: 'Delete routine?',
                    content: 'This cannot be undone.',
                    onConfirm: () => confirmed = true,
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Delete routine?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(confirmed, isTrue);
    });
  });
}
