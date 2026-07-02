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

  static DateTime? getNextRecommendedWashDate(List<WashEvent> events) {
    if (events.isEmpty) return null;

    final sortedEvents = List<WashEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final lastWash = sortedEvents.last.date;
    final avgInterval = getAverageIntervalDays(events);

    final intervalDays = avgInterval > 0 ? avgInterval.round() : 3;
    return lastWash.add(Duration(days: intervalDays));
  }

  static DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}
