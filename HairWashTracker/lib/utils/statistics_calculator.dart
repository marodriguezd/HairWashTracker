import '../models/wash_event.dart';

class StatisticsCalculator {
  static int getTotalWashes(List<WashEvent> events) {
    return events.length;
  }

  static int getWashesForWeek(List<WashEvent> events, DateTime date) {
    final startOfWeek = _getStartOfWeek(date);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return events
        .where((event) =>
            event.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            event.date.isBefore(endOfWeek.add(const Duration(days: 1))))
        .length;
  }

  static int getWashesForMonth(List<WashEvent> events, DateTime date) {
    return events
        .where((event) =>
            event.date.year == date.year && event.date.month == date.month)
        .length;
  }

  static double getAverageIntervalDays(List<WashEvent> events) {
    if (events.length < 2) return 0.0;

    final sortedEvents = List<WashEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    int totalDays = 0;
    for (int i = 0; i < sortedEvents.length - 1; i++) {
      totalDays += sortedEvents[i + 1].date.difference(sortedEvents[i].date).inDays;
    }

    return totalDays / (sortedEvents.length - 1);
  }

  /// Calculates the median interval between washes.
  /// Less sensitive to outliers than the average.
  /// Returns 0.0 if there are fewer than 2 events.
  static double getMedianIntervalDays(List<WashEvent> events) {
    if (events.length < 2) return 0.0;

    final sortedEvents = List<WashEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final intervals = <int>[];
    for (int i = 0; i < sortedEvents.length - 1; i++) {
      intervals
          .add(sortedEvents[i + 1].date.difference(sortedEvents[i].date).inDays);
    }

    intervals.sort();
    final n = intervals.length;

    if (n.isOdd) {
      return intervals[n ~/ 2].toDouble();
    } else {
      return (intervals[n ~/ 2 - 1] + intervals[n ~/ 2]) / 2.0;
    }
  }

  static DateTime? getNextRecommendedWashDate(List<WashEvent> events) {
    if (events.isEmpty) return null;

    final sortedEvents = List<WashEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final lastWash = sortedEvents.last.date;
    // Use median (more robust against outliers)
    final medInterval = getMedianIntervalDays(events);

    final intervalHours = medInterval > 0 ? (medInterval * 24).round() : 72;
    return lastWash.add(Duration(hours: intervalHours.clamp(24, 2160)));
  }

  /// Generates predicted wash dates based on the user's median interval.
  /// Uses median (not average) to be more robust against outlier gaps.
  /// Uses exact hours to preserve precision.
  /// Returns all dates from the last wash + interval forward,
  /// up to 3 months or 12 predictions ahead (past and future).
  static List<DateTime> getPredictedWashDates(List<WashEvent> events) {
    if (events.isEmpty) return [];

    final sortedEvents = List<WashEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final lastWash = sortedEvents.last.date;
    // Use median (more robust against outliers)
    final medInterval = getMedianIntervalDays(events);
    final intervalHours =
        (medInterval > 0 ? (medInterval * 24).round() : 72).clamp(24, 2160);

    final predicted = <DateTime>[];

    // Generate up to 3 months of predictions from the last wash, max 12 dates
    final limit = lastWash.add(const Duration(days: 90));
    int count = 0;
    DateTime nextDate = lastWash.add(Duration(hours: intervalHours));

    while (nextDate.isBefore(limit) && count < 12) {
      predicted.add(nextDate);
      nextDate = nextDate.add(Duration(hours: intervalHours));
      count++;
    }

    return predicted;
  }

  static DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}
