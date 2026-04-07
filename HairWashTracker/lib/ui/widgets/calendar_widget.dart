import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/wash_event.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  /// Uses centralized shadow builder for consistency across the app
  List<BoxShadow> _buildCalendarShadows(BuildContext context, bool isPressed) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use refined depth values: 2.0 for raised, 1.5 for pressed
    final depth = isPressed ? 1.5 : 2.0;
    return NeumorphicContainer.buildShadows(isDark,
        depth: depth, isPressed: isPressed);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final dayCellSize = screenWidth < 360 ? 36.0 : 40.0;

    return Consumer<AppController>(
      builder: (context, controller, child) {
        return TableCalendar<WashEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay,
          eventLoader: controller.getEventsForDay,
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
            leftChevronIcon:
                Icon(Icons.chevron_left, color: colorScheme.primary),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: colorScheme.primary),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            HapticFeedback.selectionClick();
            controller.toggleWashDay(selectedDay);
            controller.setFocusedDay(focusedDay);
          },
          onPageChanged: (focusedDay) {
            HapticFeedback.lightImpact();
            controller.setFocusedDay(focusedDay);
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 0,
            todayDecoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: _buildCalendarShadows(context, true),
            ),
            todayTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.25,
                ),
            defaultTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.onSurface,
                  letterSpacing: 0.25,
                ),
            weekendTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: colorScheme.error.withValues(alpha: 0.7),
                  letterSpacing: 0.25,
                ),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (controller.isWashDay(day)) {
                return Center(
                  child: Container(
                    width: dayCellSize,
                    height: dayCellSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusButton),
                      boxShadow: _buildCalendarShadows(context, false),
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                            ),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
            selectedBuilder: (context, day, focusedDay) {
              final isWash = controller.isWashDay(day);
              return Center(
                child: Container(
                  width: dayCellSize + 4,
                  height: dayCellSize + 4,
                  decoration: BoxDecoration(
                    color: isWash
                        ? colorScheme.primary
                        : isDark
                            ? colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5)
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                    boxShadow: _buildCalendarShadows(context, true),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: isWash
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.25,
                          ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
