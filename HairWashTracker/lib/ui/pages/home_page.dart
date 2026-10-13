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

  String _titleForIndex(int index) => switch (index) {
        0 => 'Hair Wash Tracker',
        1 => 'Statistics',
        _ => 'Settings',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final appBar = AppBar(
      title: Text(_titleForIndex(_index)),
      actions: [
        IconButton(
          tooltip: 'Data management',
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
            Haptics.selectionClick();
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
                    Haptics.selectionClick();
                    setState(() => _index = i);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Calendar'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: Text('Stats'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Settings'),
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
              Haptics.selectionClick();
              setState(() => _index = i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Calendar',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
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
            child: const Column(
              children: [
                SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: _CalendarGestureDetector(),
                  ),
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
    );
  }
}

class _CalendarGestureDetector extends StatelessWidget {
  const _CalendarGestureDetector();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        HapticFeedback.lightImpact();
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
