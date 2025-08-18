import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/wash_event.dart';
import '../../providers/app_controller.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, child) {
        return TableCalendar<WashEvent>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: controller.focusedDay,
          eventLoader: controller.getEventsForDay,
          calendarFormat: CalendarFormat.month,
          onDaySelected: (selectedDay, focusedDay) {
            controller.toggleWashDay(selectedDay);
            controller.setFocusedDay(focusedDay);
          },
          onPageChanged: (focusedDay) {
            controller.setFocusedDay(focusedDay);
          },
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 1,
          ),
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                margin: const EdgeInsets.all(4.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.isWashDay(day) ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: controller.isWashDay(day) ? Colors.white : Colors.black87,
                  ),
                ),
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              if (controller.isWashDay(day)) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
