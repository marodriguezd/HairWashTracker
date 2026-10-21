import '../models/wash_event.dart';
import '../models/prediction_result.dart';
import 'wash_predictive_model.dart';

class StatisticsCalculator {
  static int getTotalWashes(List<WashEvent> events) {
    return events.length;
  }

  static int getWashesForWeek(List<WashEvent> events, DateTime date) {
    // Half-open [start, start + 7d) range on midnight boundaries. Widening the
    // lower bound by a day would count the previous Sunday's noon event.
    final startOfWeek = _getStartOfWeek(date);
    // Calendar arithmetic rather than an absolute 7-day duration: across a DST
    // switch the duration lands on 23:00/01:00 and misplaces the boundary.
    final endOfWeek =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 7);

    return events
        .where((event) =>
            !event.date.isBefore(startOfWeek) &&
            event.date.isBefore(endOfWeek))
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

    var totalDays = 0.0;
    for (int i = 0; i < sortedEvents.length - 1; i++) {
      totalDays += _intervalDays(sortedEvents[i].date, sortedEvents[i + 1].date);
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

    final intervals = <double>[];
    for (int i = 0; i < sortedEvents.length - 1; i++) {
      intervals.add(_intervalDays(sortedEvents[i].date, sortedEvents[i + 1].date));
    }

    intervals.sort();
    final n = intervals.length;

    if (n.isOdd) {
      return intervals[n ~/ 2];
    } else {
      return (intervals[n ~/ 2 - 1] + intervals[n ~/ 2]) / 2.0;
    }
  }

  /// Whole calendar days between two noon-anchored events.
  ///
  /// `Duration.inDays` truncates a 23-hour DST day to zero, which collapsed the
  /// average and median to 0.0 twice a year; comparing the civil dates in UTC,
  /// where no clock shift exists, keeps every calendar day worth one day.
  static double _intervalDays(DateTime earlier, DateTime later) {
    final from = DateTime.utc(earlier.year, earlier.month, earlier.day);
    final to = DateTime.utc(later.year, later.month, later.day);
    return to.difference(from).inDays.toDouble();
  }

  /// Returns the full prediction result from the adaptive model.
  /// Includes confidence level, trend slope, preferred weekday, etc.
  static PredictionResult getPrediction(List<WashEvent> events) {
    return WashPredictiveModel.predict(events);
  }

  static DateTime _getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}
