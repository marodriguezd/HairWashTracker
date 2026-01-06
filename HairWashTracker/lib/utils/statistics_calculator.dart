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

  static DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}
