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
import 'package:hair_wash_tracker/ui/widgets/calendar_widget.dart';
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
  Future<String> exportToJson(List<WashEvent> events) async {
    exportCalled = true;
    return '{"format":"hair-wash-tracker","version":1,"events":[]}';
  }

  @override
  Future<List<WashEvent>> importFromBackup(String filePath) async => [];

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
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
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
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
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
      expect(find.text('Export backup (JSON)'), findsOneWidget);
      expect(find.text('Import backup (JSON or CSV)'), findsOneWidget);
      expect(find.text('Clear all data'), findsOneWidget);
    });

    testWidgets('Clearing data from the sheet shows the confirmation snackbar',
        (tester) async {
      controller.toggleWashDay(DateTime(2026, 7, 2));

      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear all data'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear data'));
      await tester.pumpAndSettle();

      expect(find.text('All data has been cleared'), findsOneWidget);
      expect(controller.selectedEvents, isEmpty);
      // The shared helper leaves the surface to the theme instead of
      // repainting it per call site.
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, isNull);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('Cancelled import shows no success message', (tester) async {
      final cancelled = AppController(
        repository: repository,
        fileOperations: fileOps,
        pickFile: () async => null,
      );

      await tester.pumpWidget(createTestApp(controller: cancelled));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Import backup (JSON or CSV)'));
      await tester.pumpAndSettle();

      expect(find.text('Data imported successfully'), findsNothing);
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
      // Average and median are part of the documented statistics contract.
      expect(find.text('Average'), findsOneWidget);
      expect(find.text('Median'), findsOneWidget);
      expect(find.text('3.0 d'), findsWidgets);
    });

    testWidgets('Add First Wash in the stats empty state opens the calendar',
        (tester) async {
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Add First Wash'), findsOneWidget);

      await tester.tap(find.text('Add First Wash'));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarWidget), findsOneWidget);
      expect(find.text('Washes This Month'), findsOneWidget);
    });

    testWidgets('Calendar swipe advances exactly one month', (tester) async {
      controller.setFocusedDay(DateTime(2026, 6, 15));
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      // The calendar owns the horizontal gesture; a wrapper used to swallow it.
      await tester.drag(find.byType(CalendarWidget), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(controller.focusedDay.month, 7);
      expect(controller.focusedDay.isUtc, isFalse);
      expect(controller.focusedDay.hour, 12);
    });

    testWidgets('Calendar fling advances one month and keeps a local focused day',
        (tester) async {
      controller.setFocusedDay(DateTime(2026, 6, 15));
      await tester.pumpWidget(createTestApp(controller: controller));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(CalendarWidget), const Offset(-300, 0), 900);
      await tester.pumpAndSettle();

      expect(controller.focusedDay.month, 7);
      expect(controller.focusedDay.isUtc, isFalse);
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
