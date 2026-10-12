import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/monthly_washes_widget.dart';
import '../widgets/neumorphic_container.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMedium = constraints.maxWidth >= 600;
        final body = _AdaptiveBody(
          index: _index,
          onSelect: (i) {
            HapticFeedback.selectionClick();
            setState(() => _index = i);
          },
        );
        if (isMedium) {
          return Scaffold(
            appBar: AppBar(title: Text(_index == 0 ? 'Hair Wash Tracker' : 'Statistics')),
            drawer: const AppDrawer(),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _index = i);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.bar_chart_outlined),
                      selectedIcon: Icon(Icons.bar_chart),
                      label: Text('Stats'),
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
          appBar: AppBar(title: Text(_index == 0 ? 'Hair Wash Tracker' : 'Statistics')),
          drawer: const AppDrawer(),
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            backgroundColor: scheme.surfaceContainer,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              setState(() => _index = i);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Stats',
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
