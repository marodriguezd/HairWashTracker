import 'dart:math';
import '../models/wash_event.dart';
import '../models/prediction_result.dart';

/// Predictive model for estimating future wash dates based on user history.
class WashPredictiveModel {
  WashPredictiveModel._();

  /// Predicts future wash dates based on a history of wash events.
  static PredictionResult predict(List<WashEvent> events) {
    if (events.isEmpty) {
      final now = DateTime.now();
      return PredictionResult(
        nextWashDate: now.add(const Duration(days: 3)),
        predictedDates: [],
        adaptiveIntervalDays: 3.0,
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

    final ewma = _computeEWMA(intervals);
    final trendSlope = _computeTrendSlope(intervals);
    
    var adjustedInterval = ewma + trendSlope * 0.5;
    adjustedInterval = adjustedInterval.clamp(1.0, 90.0);
    
    final preferredWeekday = _computePreferredWeekday(sortedEvents);
    final confidence = _computeConfidence(intervals.length);
    
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

  static double _computeEWMA(List<double> intervals, {double alpha = 0.3, double prior = 3.0}) {
    if (intervals.isEmpty) return prior;
    double ewma = prior;
    for (final interval in intervals) {
      ewma = alpha * interval + (1 - alpha) * ewma;
    }
    return ewma.clamp(1.0, 90.0);
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

  static PredictionConfidence _computeConfidence(int intervalCount) {
    if (intervalCount <= 1) return PredictionConfidence.low;
    if (intervalCount <= 4) return PredictionConfidence.medium;
    return PredictionConfidence.high;
  }
}
