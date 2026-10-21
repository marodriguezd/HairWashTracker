import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/data_management_sheet.dart';
import '../widgets/monthly_washes_widget.dart';
import '../widgets/tonal_card.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
import 'settings_page.dart';
import 'stats_page.dart';

typedef _NavTab = ({IconData icon, IconData selectedIcon, String label});

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

  /// Single source for the bottom bar and the rail, so a new destination cannot
  /// drift between the two layouts.
  List<_NavTab> _tabs(AppController controller) => [
        (
          icon: Icons.calendar_month_outlined,
          selectedIcon: Icons.calendar_month,
          label: controller.tr('navCalendar'),
        ),
        (
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
          label: controller.tr('navStats'),
        ),
        (
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: controller.tr('navSettings'),
        ),
      ];

  void _select(int index) {
    Haptics.selectionHaptic();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final tabs = _tabs(controller);
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
        final body = _AdaptiveBody(index: _index, onSelect: _select);

        if (isMedium) {
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final tab in tabs)
                      NavigationRailDestination(
                        icon: Icon(tab.icon),
                        selectedIcon: Icon(tab.selectedIcon),
                        label: Text(tab.label),
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
            onDestinationSelected: _select,
            destinations: [
              for (final tab in tabs)
                NavigationDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: tab.label,
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
    if (index == 1) {
      return StatsPage(embed: true, onAddWash: () => onSelect(0));
    }
    if (index == 2) return const SettingsPage(embed: true);
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
            constraints:
                const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
            child: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    // Swiping is owned by the calendar's own page view; an
                    // outer drag detector steals the gesture and silently
                    // drops slow drags.
                    child: TonalCard(child: CalendarWidget()),
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
