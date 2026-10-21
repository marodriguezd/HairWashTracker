import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/wash_event.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';

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

  /// Renders one day.
  ///
  /// The today, selected and ordinary builders differ only in fill, border and
  /// emphasis, so a single cell keeps the wash/predicted language identical on
  /// every day of the grid. Per-day semantics cannot be added here:
  /// `table_calendar` wraps every cell in `Semantics(excludeSemantics: true)`
  /// with its own date label, so anything set inside a builder is dropped.
  Widget _dayCell(
    BuildContext context,
    DateTime day, {
    required double size,
    required Color textColor,
    Color? background,
    Color? borderColor,
    double borderWidth = 2,
    double overlaySize = 0,
    double overlayStroke = 1.5,
    bool bold = false,
  }) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          border: borderColor == null
              ? null
              : Border.all(color: borderColor, width: borderWidth),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: textColor,
                    fontWeight: bold ? FontWeight.w700 : null,
                    letterSpacing: 0.25,
                  ),
            ),
            if (overlaySize > 0)
              _buildPredictedOverlay(context, overlaySize, overlayStroke),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final dayCellSize = screenWidth < 360 ? 36.0 : 40.0;
    // A rolling window keeps the calendar usable past a hard-coded year while
    // staying inside the same local-noon frame as stored events.
    final now = DateTime.now();
    final firstDay = DateTime(2015, 1, 1, 12);
    final lastDay = DateTime(now.year + 5, 12, 31, 12);

    return Consumer<AppController>(
      builder: (context, controller, child) {
        return TableCalendar<WashEvent>(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: controller.focusedDay,
          eventLoader: controller.getEventsForDay,
          calendarFormat: CalendarFormat.month,
          // TableCalendar formats its header and weekday labels with intl;
          // without this it stays in English inside a localized UI.
          locale: Localizations.localeOf(context).toLanguageTag(),
          startingDayOfWeek: StartingDayOfWeek.monday,
          // Only the month pages move. The default also installs a vertical
          // swipe recognizer, which swallowed every drag inside the card and
          // left short (landscape) layouts unable to scroll to the counter.
          availableGestures: AvailableGestures.horizontalSwipe,
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
            Haptics.selectionHaptic();
            controller.toggleWashDay(selectedDay);
            controller.setFocusedDay(focusedDay);
          },
          onPageChanged: (focusedDay) {
            Haptics.lightHaptic();
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
              final isPredicted =
                  !isWash && controller.isPredictedWashDay(day);
              return _dayCell(
                context,
                day,
                size: dayCellSize,
                background: isWash
                    ? colorScheme.primary
                    : colorScheme.primary.withValues(alpha: 0.15),
                borderColor:
                    isPredicted ? colorScheme.tertiary : colorScheme.primary,
                borderWidth: isPredicted ? 2.5 : 2,
                textColor: isWash ? colorScheme.onPrimary : colorScheme.primary,
                overlaySize: isPredicted ? dayCellSize - 4 : 0,
                overlayStroke: 1.2,
                bold: true,
              );
            },
            defaultBuilder: (context, day, focusedDay) {
              if (controller.isWashDay(day)) {
                return _dayCell(
                  context,
                  day,
                  size: dayCellSize,
                  background: colorScheme.primary,
                  textColor: colorScheme.onPrimary,
                  bold: true,
                );
              }

              if (controller.isPredictedWashDay(day)) {
                return _dayCell(
                  context,
                  day,
                  size: dayCellSize,
                  textColor: colorScheme.onSurface,
                  overlaySize: dayCellSize,
                );
              }

              return null;
            },
            selectedBuilder: (context, day, focusedDay) {
              final isWash = controller.isWashDay(day);
              final isPredicted =
                  !isWash && controller.isPredictedWashDay(day);
              return _dayCell(
                context,
                day,
                size: dayCellSize + 4,
                background: isWash
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: isDark ? 0.5 : 0.7,
                      ),
                borderColor:
                    isPredicted ? colorScheme.tertiary : colorScheme.primary,
                textColor:
                    isWash ? colorScheme.onPrimary : colorScheme.onSurface,
                overlaySize: isPredicted ? dayCellSize : 0,
                overlayStroke: 1.2,
                bold: true,
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
