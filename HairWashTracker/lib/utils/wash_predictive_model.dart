import 'dart:math';
import '../models/wash_event.dart';
import '../models/prediction_result.dart';

/// Predictive model for estimating future wash dates based on user history.
///
/// Cold start: with no history the model falls back to [priorIntervalDays].
/// As washes accumulate, an EWMA over outlier-clipped (winsorized) intervals
/// takes over, so one-off gaps (e.g. vacations) cannot drag the estimate.
class WashPredictiveModel {
  WashPredictiveModel._();

  /// Default interval in days used before enough history exists.
  static const double priorIntervalDays = 3.0;

  /// Hard bounds for any interval estimate.
  static const double minIntervalDays = 1.0;
  static const double maxIntervalDays = 90.0;

  /// Floor for the MAD scale so tight rhythms still clip vacation gaps.
  static const double minScaleDays = 0.5;

  /// Predicts future wash dates based on a history of wash events.
  static PredictionResult predict(List<WashEvent> events) {
    if (events.isEmpty) {
      final now = DateTime.now();
      return PredictionResult(
        nextWashDate: now.add(Duration(days: priorIntervalDays.round())),
        predictedDates: [],
        adaptiveIntervalDays: priorIntervalDays,
        confidence: PredictionConfidence.low,
        trendSlope: 0.0,
      );
    }

    final sortedEvents = List<WashEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));

    final intervals = <double>[];
    for (int i = 1; i < sortedEvents.length; i++) {
      final diff = sortedEvents[i].date.difference(sortedEvents[i - 1].date);
      intervals.add(diff.inHours / 24.0);
    }

    // Outlier control: clip one-off gaps to median +/- 3*MAD before any
    // averaging, so vacations or missed logs skew neither level nor trend.
    final winsorized = _winsorize(intervals);
    final clippedCount = _countClipped(intervals, winsorized);

    final ewma = _computeEWMA(winsorized);
    final trendSlope = _computeTrendSlope(winsorized);

    var adjustedInterval = ewma + trendSlope * 0.5;
    adjustedInterval =
        adjustedInterval.clamp(minIntervalDays, maxIntervalDays);

    final preferredWeekday = _computePreferredWeekday(sortedEvents);
    final confidence = _computeConfidence(intervals.length, clippedCount);
    
    final lastWashDate = sortedEvents.last.date;
    final intervalHours = (adjustedInterval * 24.0).round();
    
    var nextWashDate = lastWashDate.add(Duration(hours: intervalHours));
    nextWashDate = _adjustForWeekday(nextWashDate, preferredWeekday, adjustedInterval);
    
    final predictedDates = <DateTime>[];
    var currentPred = nextWashDate;
    final maxDate = lastWashDate.add(const Duration(days: 90));
    
    for (int i = 0; i < 12; i++) {
      if (currentPred.isAfter(maxDate)) break;
      predictedDates.add(currentPred);
      
      final nextBase = currentPred.add(Duration(hours: intervalHours));
      currentPred = _adjustForWeekday(nextBase, preferredWeekday, adjustedInterval);
    }

    return PredictionResult(
      nextWashDate: nextWashDate,
      predictedDates: predictedDates,
      adaptiveIntervalDays: adjustedInterval,
      confidence: confidence,
      preferredWeekday: preferredWeekday,
      trendSlope: trendSlope,
    );
  }

  static double _computeEWMA(List<double> intervals,
      {double alpha = 0.3, double prior = priorIntervalDays}) {
    if (intervals.isEmpty) return prior;
    double ewma = prior;
    for (final interval in intervals) {
      ewma = alpha * interval + (1 - alpha) * ewma;
    }
    return ewma.clamp(minIntervalDays, maxIntervalDays);
  }

  /// Median of a non-empty sample.
  static double _median(List<double> values) {
    final sorted = List<double>.from(values)..sort();
    final n = sorted.length;
    if (n.isOdd) return sorted[n ~/ 2];
    return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2.0;
  }

  /// Winsorizes intervals to [minIntervalDays, median + 3 * scale] where
  /// scale is MAD floored at [minScaleDays]. Returns a new list; a single
  /// interval can never be an outlier (there is no baseline yet).
  static List<double> _winsorize(List<double> intervals) {
    if (intervals.length < 2) return List<double>.from(intervals);
    final median = _median(intervals);
    final deviations =
        intervals.map((x) => (x - median).abs()).toList(growable: false);
    final scale = max(_median(deviations), minScaleDays);
    final cap = median + 3 * scale;
    return intervals
        .map((x) => x.clamp(minIntervalDays, cap))
        .toList(growable: false);
  }

  /// Counts how many intervals winsorization actually altered.
  static int _countClipped(List<double> raw, List<double> clipped) {
    var count = 0;
    for (int i = 0; i < raw.length; i++) {
      if ((raw[i] - clipped[i]).abs() > 1e-9) count++;
    }
    return count;
  }

  static double _computeTrendSlope(List<double> intervals) {
    if (intervals.length < 3) return 0.0;
    
    final n = min(5, intervals.length);
    final recentIntervals = intervals.sublist(intervals.length - n);
    
    double sumX = 0.0;
    double sumY = 0.0;
    double sumXY = 0.0;
    double sumX2 = 0.0;
    
    for (int i = 0; i < n; i++) {
      final x = i.toDouble();
      final y = recentIntervals[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final denominator = (n * sumX2 - sumX * sumX);
    if (denominator == 0) return 0.0;
    
    final slope = (n * sumXY - sumX * sumY) / denominator;
    return slope.clamp(-2.0, 2.0);
  }

  static int? _computePreferredWeekday(List<WashEvent> events) {
    if (events.length < 5) return null;
    
    final counts = <int, int>{};
    for (final event in events) {
      final wd = event.date.weekday;
      counts[wd] = (counts[wd] ?? 0) + 1;
    }
    
    int maxCount = 0;
    int? maxWeekday;
    
    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        maxWeekday = entry.key;
      }
    }
    
    if (maxCount > events.length * 0.3) {
      return maxWeekday;
    }
    
    return null;
  }

  static DateTime _adjustForWeekday(DateTime baseDate, int? preferredWeekday, double intervalDays) {
    if (preferredWeekday == null) return baseDate;
    
    int diff = preferredWeekday - baseDate.weekday;
    
    if (diff > 3) {
      diff -= 7;
    } else if (diff < -3) {
      diff += 7;
    }
    
    if (diff.abs() <= 2 && diff.abs().toDouble() <= intervalDays * 0.3) {
      return baseDate.add(Duration(days: diff));
    }
    
    return baseDate;
  }

  /// Confidence grows with sample size; each clipped outlier indicates a
  /// noisier history, so it downgrades the level by one step.
  static PredictionConfidence _computeConfidence(
      int intervalCount, int clippedCount) {
    final PredictionConfidence base;
    if (intervalCount <= 1) {
      base = PredictionConfidence.low;
    } else if (intervalCount <= 4) {
      base = PredictionConfidence.medium;
    } else {
      base = PredictionConfidence.high;
    }
    if (clippedCount == 0) return base;
    switch (base) {
      case PredictionConfidence.high:
        return PredictionConfidence.medium;
      case PredictionConfidence.medium:
        return PredictionConfidence.low;
      case PredictionConfidence.low:
        return PredictionConfidence.low;
    }
  }
}
