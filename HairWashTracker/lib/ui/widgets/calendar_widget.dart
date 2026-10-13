import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/wash_event.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  /// Builds a predicted-date indicator: a subtle dotted ring around the day.
  Widget _buildPredictedOverlay(
      BuildContext context, double size, double strokeWidth) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size(size, size),
      painter: _DashedBorderPainter(
        color: colorScheme.tertiary.withValues(alpha: 0.65),
        strokeWidth: strokeWidth,
        cornerRadius: AppTheme.radiusButton - 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final dayCellSize = screenWidth < 360 ? 36.0 : 40.0;

    return Consumer<AppController>(
      builder: (context, controller, child) {
        final predictedDates = controller.predictedWashDates;

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
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
            weekendStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: colorScheme.error.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 0,
            todayDecoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
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
            todayBuilder: (context, day, focusedDay) {
              final isWash = controller.isWashDay(day);
              final isPredicted = !isWash &&
                  predictedDates.any((d) => isSameDay(d, day));
              return Center(
                 child: Container(
                  width: dayCellSize,
                  height: dayCellSize,
                  decoration: BoxDecoration(
                    color: isWash
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusButton),
                    border: Border.all(
                      color: isPredicted
                          ? colorScheme.tertiary
                          : colorScheme.primary,
                      width: isPredicted ? 2.5 : 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                              color: isWash
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                            ),
                      ),
                      if (isPredicted)
                        _buildPredictedOverlay(
                            context, dayCellSize - 4, 1.2),
                    ],
                  ),
                ),
              );
            },
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

              if (predictedDates.any((d) => isSameDay(d, day))) {
                return Center(
                  child: SizedBox(
                    width: dayCellSize,
                    height: dayCellSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: colorScheme.onSurface,
                                    letterSpacing: 0.25,
                                  ),
                        ),
                        _buildPredictedOverlay(
                            context, dayCellSize, 1.5),
                      ],
                    ),
                  ),
                );
              }

              return null;
            },
            selectedBuilder: (context, day, focusedDay) {
              final isWash = controller.isWashDay(day);
              final isPredicted = !isWash &&
                  predictedDates.any((d) => isSameDay(d, day));
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
                      color: isPredicted
                          ? colorScheme.tertiary
                          : colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: isWash
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.25,
                            ),
                      ),
                      if (isPredicted)
                        _buildPredictedOverlay(
                            context, dayCellSize, 1.2),
                    ],
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

/// A custom painter that draws a dashed rounded-rectangle border,
/// used as a subtle visual indicator for predicted wash dates.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerRadius;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.cornerRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(
        rect, Radius.circular(cornerRadius));

    final path = Path()..addRRect(rrect);

    const dashWidth = 3.5;
    const dashGap = 2.5;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        final segmentPath = metric.extractPath(distance, end);
        canvas.drawPath(segmentPath, paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.cornerRadius != cornerRadius;
}