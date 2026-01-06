import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/wash_event.dart';
import '../../providers/app_controller.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            leftChevronIcon:
                Icon(Icons.chevron_left, color: colorScheme.primary),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: colorScheme.primary),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            controller.toggleWashDay(selectedDay);
            controller.setFocusedDay(focusedDay);
          },
          onPageChanged: (focusedDay) {
            controller.setFocusedDay(focusedDay);
          },
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 0,
            todayDecoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(color: colorScheme.primary),
            defaultTextStyle: TextStyle(color: colorScheme.onSurface),
            weekendTextStyle:
                TextStyle(color: colorScheme.error.withOpacity(0.7)),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (controller.isWashDay(day)) {
                return Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isWash
                        ? colorScheme.primary
                        : colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isWash
                            ? Colors.white
                            : colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
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
