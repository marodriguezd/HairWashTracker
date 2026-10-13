import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/wash_event.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

const _weekdayKeys = ['wdMon', 'wdTue', 'wdWed', 'wdThu', 'wdFri', 'wdSat', 'wdSun'];
const _weekdayFallback = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Localized weekday abbreviations, English when no controller is available.
List<String> _weekdayLabels(BuildContext context) {
  try {
    final controller = Provider.of<AppController>(context, listen: false);
    return [for (final k in _weekdayKeys) controller.tr(k)];
  } catch (_) {
    return _weekdayFallback;
  }
}

/// Localized string with an English [fallback] when no controller exists.
String _trs(BuildContext context, String key, String fallback,
    [Map<String, String>? params]) {
  var value = fallback;
  try {
    value = Provider.of<AppController>(context, listen: false).tr(key);
  } catch (_) {
    value = fallback;
  }
  if (params != null) {
    params.forEach((name, v) {
      value = value.replaceAll('{$name}', v);
    });
  }
  return value;
}

/// WeekChart - Horizontal bar chart showing washes per day
///
/// Features:
/// - Animated bar growth on load
/// - Soft, rounded bars with gradient
/// - Day abbreviations below bars
/// - Highlight for today
/// - Staggered animations
class WeekChart extends StatelessWidget {
  final List<WashEvent> events;
  final DateTime currentDate;
  final Duration delay;

  const WeekChart({
    super.key,
    required this.events,
    required this.currentDate,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekData = _getWeekData(_weekdayLabels(context));
    final maxWashes = weekData
        .map((d) => d.count)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, 10);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      depth: 3.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _trs(context, 'statsWeekTitle', 'This Week'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          )
              .animate(delay: delay)
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weekData.asMap().entries.map((entry) {
              final index = entry.key;
              final dayData = entry.value;
              final isToday = dayData.isToday;
              final barHeight = dayData.count > 0
                  ? 40 + (100 * (dayData.count / maxWashes))
                  : 20.0;

              return _buildDayColumn(
                context,
                dayData: dayData,
                barHeight: barHeight,
                isToday: isToday,
                delay: delay + Duration(milliseconds: 100 * index),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(
    BuildContext context, {
    required _DayData dayData,
    required double barHeight,
    required bool isToday,
    required Duration delay,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final barColor = isToday
        ? Theme.of(context).colorScheme.primary
        : dayData.count > 0
            ? Theme.of(context).colorScheme.secondary
            : colorScheme.surfaceContainerHighest;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Count badge (visible when count > 0)
        if (dayData.count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            ),
            child: Text(
              '${dayData.count}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          )
              .animate(delay: delay + 300.ms)
              .fadeIn(duration: 300.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
        Container(
          width: 32,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                barColor.withValues(alpha: 0.8),
                barColor,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: [
              if (dayData.count > 0)
                BoxShadow(
                  color: barColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
        )
            .animate(delay: delay)
            .slideY(
              begin: 1,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeOutQuart,
            )
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            dayData.dayLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                ),
          ),
        ).animate(delay: delay + 200.ms).fadeIn(duration: 400.ms),
      ],
    );
  }

  List<_DayData> _getWeekData(List<String> days) {
    final now = currentDate;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final count = events
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .length;
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return _DayData(
        dayLabel: days[index],
        count: count,
        isToday: isToday,
        date: date,
      );
    });
  }
}

class _DayData {
  final String dayLabel;
  final int count;
  final bool isToday;
  final DateTime date;

  _DayData({
    required this.dayLabel,
    required this.count,
    required this.isToday,
    required this.date,
  });
}

/// WeekChartCard - Enhanced week chart with additional info
///
/// Includes summary stats and the bar chart in a cohesive card layout.
class WeekChartCard extends StatelessWidget {
  final List<WashEvent> events;
  final DateTime currentDate;
  final Duration delay;

  const WeekChartCard({
    super.key,
    required this.events,
    required this.currentDate,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekData = _getWeekData(_weekdayLabels(context));
    final totalWeekWashes = weekData.fold(0, (sum, d) => sum + d.count);
    final daysWithWashes = weekData.where((d) => d.count > 0).length;

    return NeumorphicContainer(
      padding: const EdgeInsets.all(24),
      depth: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusButton),
                    ),
                    child: Icon(
                      Icons.calendar_view_week_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _trs(context, 'statsWeeklyOverview', 'Weekly Overview'),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _trs(context, 'statsDaysActive', '{n} days active',
                            {'n': '$daysWithWashes'}),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  _trs(context, 'statsWashes', '{n} washes',
                      {'n': '$totalWeekWashes'}),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ).animate(delay: delay + 100.ms).fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            ],
          )
              .animate(delay: delay)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1, end: 0, duration: 500.ms),
          const SizedBox(height: 28),
          _buildChart(context, weekData, delay: delay + 200.ms),
        ],
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<_DayData> weekData, {
    required Duration delay,
  }) {
    final maxWashes = weekData
        .map((d) => d.count)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, 10);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: weekData.asMap().entries.map((entry) {
        final index = entry.key;
        final dayData = entry.value;
        final isToday = dayData.isToday;
        final barHeight =
            dayData.count > 0 ? 60 + (80 * (dayData.count / maxWashes)) : 30.0;

        return _buildDayBar(
          context,
          dayData: dayData,
          barHeight: barHeight,
          isToday: isToday,
          maxWashes: maxWashes,
          delay: delay + Duration(milliseconds: 80 * index),
        );
      }).toList(),
    );
  }

  Widget _buildDayBar(
    BuildContext context, {
    required _DayData dayData,
    required double barHeight,
    required bool isToday,
    required int maxWashes,
    required Duration delay,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasWashes = dayData.count > 0;
    final barColor = isToday
        ? Theme.of(context).colorScheme.primary
        : hasWashes
            ? Theme.of(context).colorScheme.secondary
            : colorScheme.surfaceContainerHighest;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: hasWashes
                ? barColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton - 2),
          ),
          child: Text(
            hasWashes ? '${dayData.count}' : '-',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: hasWashes ? barColor : colorScheme.outline,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
          ),
        )
            .animate(delay: delay + 400.ms)
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0, 0), end: const Offset(1, 1)),
        Container(
          width: 36,
          height: 140,
          alignment: Alignment.bottomCenter,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 36,
                height: 140,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
              ),
              Container(
                width: 36,
                height: barHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      barColor.withValues(alpha: 0.9),
                      barColor,
                      if (hasWashes) barColor.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  boxShadow: hasWashes
                      ? [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: -2,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        )
            .animate(delay: delay)
            .slideY(
              begin: 0.5,
              end: 0,
              duration: 700.ms,
              curve: Curves.easeOutQuart,
            )
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton - 2),
            border: isToday
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Text(
            dayData.dayLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
          ),
        ).animate(delay: delay + 200.ms).fadeIn(duration: 400.ms).scale(
              begin: isToday ? const Offset(0.9, 0.9) : const Offset(1, 1),
              end: const Offset(1, 1),
            ),
      ],
    );
  }

  List<_DayData> _getWeekData(List<String> days) {
    final now = currentDate;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      final count = events
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .length;
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      return _DayData(
        dayLabel: days[index],
        count: count,
        isToday: isToday,
        date: date,
      );
    });
  }
}
