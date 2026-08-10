/// Represents the output of the adaptive predictive model.
class PredictionResult {
  /// The next recommended wash date.
  final DateTime nextWashDate;

  /// List of predicted future wash dates (up to 12, within 90 days).
  final List<DateTime> predictedDates;

  /// The current adaptive interval in days (EWMA-based).
  final double adaptiveIntervalDays;

  /// Confidence level of the prediction.
  final PredictionConfidence confidence;

  /// Day-of-week affinity: the weekday (1=Mon..7=Sun) the user washes most, or null.
  final int? preferredWeekday;

  /// Trend slope: positive = intervals increasing, negative = decreasing, ~0 = stable.
  final double trendSlope;

  const PredictionResult({
    required this.nextWashDate,
    required this.predictedDates,
    required this.adaptiveIntervalDays,
    required this.confidence,
    this.preferredWeekday,
    required this.trendSlope,
  });
}

enum PredictionConfidence { low, medium, high }
