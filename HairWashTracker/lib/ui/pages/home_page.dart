import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/data_management_sheet.dart';
import '../widgets/monthly_washes_widget.dart';
import '../widgets/neumorphic_container.dart';
import '../../utils/haptics.dart';
import 'settings_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  String _titleForIndex(AppController controller, int index) => switch (index) {
        0 => controller.tr('appTitle'),
        1 => controller.tr('pageStatistics'),
        _ => controller.tr('navSettings'),
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = context.watch<AppController>();
    final appBar = AppBar(
      title: Text(_titleForIndex(controller, _index)),
      actions: [
        IconButton(
          tooltip: controller.tr('tooltipDataMgmt'),
          icon: const Icon(Icons.folder_outlined),
          onPressed: () => DataManagementSheet.show(context),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMedium = constraints.maxWidth >= 600;
        final body = _AdaptiveBody(
          index: _index,
          onSelect: (i) {
            Haptics.selectionHaptic();
            setState(() => _index = i);
          },
        );

        if (isMedium) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) {
                    Haptics.selectionHaptic();
                    setState(() => _index = i);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.calendar_month_outlined),
                      selectedIcon: const Icon(Icons.calendar_month),
                      label: Text(controller.tr('navCalendar')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.bar_chart_outlined),
                      selectedIcon: const Icon(Icons.bar_chart),
                      label: Text(controller.tr('navStats')),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: Text(controller.tr('navSettings')),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: appBar,
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            backgroundColor: scheme.surfaceContainer,
            onDestinationSelected: (i) {
              Haptics.selectionHaptic();
              setState(() => _index = i);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: controller.tr('navCalendar'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: controller.tr('navStats'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: controller.tr('navSettings'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdaptiveBody extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  const _AdaptiveBody({required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (index == 1) return const StatsPage(embed: true);
    if (index == 2) return const SettingsPage(embed: true);
    context.watch<AppController>();
    final scheme = Theme.of(context).colorScheme;
    final gradientColors = [
      scheme.surface,
      scheme.surfaceContainerHighest.withValues(alpha: 0.5),
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _CalendarGestureDetector(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: MonthlyWashesWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarGestureDetector extends StatelessWidget {
  const _CalendarGestureDetector();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        Haptics.lightHaptic();
        if (details.primaryVelocity! > 0) {
          context.read<AppController>().previousMonth();
        } else if (details.primaryVelocity! < 0) {
          context.read<AppController>().nextMonth();
        }
      },
      child: const NeumorphicContainer(
        child: CalendarWidget(),
      ),
    );
  }
}
