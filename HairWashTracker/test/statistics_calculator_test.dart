import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/models/wash_event.dart';
import 'package:hair_wash_tracker/utils/statistics_calculator.dart';

void main() {
  group('WashEvent Tests', () {
    test('Constructor normalizes date to noon', () {
      final date = DateTime(2026, 7, 2, 8, 30, 45);
      final event = WashEvent(date: date);
      expect(event.date, DateTime(2026, 7, 2, 12, 0, 0));
    });

    test('toJson and fromJson serialization works', () {
      final date = DateTime(2026, 7, 2, 12, 0, 0);
      final event = WashEvent(date: date);
      final json = event.toJson();
      final decoded = WashEvent.fromJson(json);
      expect(decoded, event);
      expect(decoded.date, date);
    });

    test('Equality and hashcode based on isSameDay', () {
      final event1 = WashEvent(date: DateTime(2026, 7, 2, 9, 0, 0));
      final event2 = WashEvent(date: DateTime(2026, 7, 2, 17, 0, 0));
      final event3 = WashEvent(date: DateTime(2026, 7, 3, 12, 0, 0));

      expect(event1, event2);
      expect(event1.hashCode, event2.hashCode);
      expect(event1, isNot(event3));
    });
  });

  group('StatisticsCalculator Tests', () {
    late List<WashEvent> events;

    setUp(() {
      events = [
        WashEvent(date: DateTime(2026, 6, 15)), // Monday, Week 25
        WashEvent(date: DateTime(2026, 6, 16)), // Tuesday, Week 25
        WashEvent(date: DateTime(2026, 6, 22)), // Monday, Week 26
        WashEvent(date: DateTime(2026, 7, 2)),  // Thursday, Week 27
        WashEvent(date: DateTime(2026, 7, 3)),  // Friday, Week 27
      ];
    });

    test('getTotalWashes returns total length', () {
      expect(StatisticsCalculator.getTotalWashes(events), 5);
      expect(StatisticsCalculator.getTotalWashes([]), 0);
    });

    test('getWashesForWeek returns correct count', () {
      // Week of June 15 to June 21 should have 2 washes
      expect(StatisticsCalculator.getWashesForWeek(events, DateTime(2026, 6, 18)), 2);

      // Week of June 22 to June 28 should have 1 wash
      expect(StatisticsCalculator.getWashesForWeek(events, DateTime(2026, 6, 22)), 1);

      // Week of June 29 to July 5 should have 2 washes
      expect(StatisticsCalculator.getWashesForWeek(events, DateTime(2026, 7, 2)), 2);

      // Empty list returns 0
      expect(StatisticsCalculator.getWashesForWeek([], DateTime(2026, 7, 2)), 0);
    });

    test('getWashesForMonth returns correct count', () {
      // June 2026 should have 3 washes
      expect(StatisticsCalculator.getWashesForMonth(events, DateTime(2026, 6, 10)), 3);

      // July 2026 should have 2 washes
      expect(StatisticsCalculator.getWashesForMonth(events, DateTime(2026, 7, 31)), 2);

      // August 2026 should have 0 washes
      expect(StatisticsCalculator.getWashesForMonth(events, DateTime(2026, 8, 1)), 0);
    });

    test('getAverageIntervalDays returns correct average', () {
      // Days between events:
      // Jun 15 to Jun 16 = 1 day
      // Jun 16 to Jun 22 = 6 days
      // Jun 22 to Jul 2 = 10 days
      // Jul 2 to Jul 3 = 1 day
      // Total days = 18. Number of intervals = 4. Average = 18 / 4 = 4.5.
      expect(StatisticsCalculator.getAverageIntervalDays(events), 4.5);
      
      // Less than 2 events returns 0.0
      expect(StatisticsCalculator.getAverageIntervalDays([]), 0.0);
      expect(StatisticsCalculator.getAverageIntervalDays([WashEvent(date: DateTime(2026, 7, 2))]), 0.0);
    });

    test('getMedianIntervalDays returns correct median', () {
      // Intervals: 1, 6, 10, 1 → sorted: [1, 1, 6, 10] → median: (1+6)/2 = 3.5
      expect(StatisticsCalculator.getMedianIntervalDays(events), 3.5);

      // Less than 2 events returns 0.0
      expect(StatisticsCalculator.getMedianIntervalDays([]), 0.0);
      expect(StatisticsCalculator.getMedianIntervalDays(
          [WashEvent(date: DateTime(2026, 7, 2))]), 0.0);
    });

    test('getMedianIntervalDays is robust against outliers', () {
      // Odd number of intervals: [2, 3, 4, 5, 100] → median = 4 (not affected by 100)
      final outlierEvents = [
        WashEvent(date: DateTime(2026, 7, 1)),
        WashEvent(date: DateTime(2026, 7, 3)),  // +2
        WashEvent(date: DateTime(2026, 7, 6)),  // +3
        WashEvent(date: DateTime(2026, 7, 10)), // +4
        WashEvent(date: DateTime(2026, 7, 15)), // +5
        WashEvent(date: DateTime(2026, 10, 23)), // +100 ← outlier
      ];
      expect(StatisticsCalculator.getMedianIntervalDays(outlierEvents), 4.0);

      // Average would be (2+3+4+5+100)/5 = 114/5 = 22.8
      expect(StatisticsCalculator.getAverageIntervalDays(outlierEvents), 22.8);
    });

    test('getNextRecommendedWashDate uses adaptive predictive model', () {
      // Now uses EWMA, not median. With 5 events, intervals [1,6,10,1]:
      // EWMA steps: prior=3.0 -> 3.0*0.7+1*0.3=2.4 -> 2.4*0.7+6*0.3=3.48
      //   -> 3.48*0.7+10*0.3=5.436 -> 5.436*0.7+1*0.3=4.1052
      // The result should be after the last wash date
      final result = StatisticsCalculator.getNextRecommendedWashDate(events);
      expect(result, isNotNull);
      expect(result!.isAfter(DateTime(2026, 7, 3, 12, 0, 0)), isTrue);

      // If empty, returns null
      expect(StatisticsCalculator.getNextRecommendedWashDate([]), isNull);

      // If 1 event, defaults to prior (3.0 days = 72 hours)
      // Jul 2 12:00 + 72h = Jul 5 12:00
      final singleResult = StatisticsCalculator.getNextRecommendedWashDate(
              [WashEvent(date: DateTime(2026, 7, 2))]);
      expect(singleResult, isNotNull);
      expect(singleResult!.isAfter(DateTime(2026, 7, 2, 12, 0, 0)), isTrue);
    });

    test('getPredictedWashDates uses adaptive predictive model', () {
      final predicted = StatisticsCalculator.getPredictedWashDates(events);

      // Should have predictions
      expect(predicted, isNotEmpty);

      // First prediction should be after the last wash
      expect(predicted.first.isAfter(DateTime(2026, 7, 3, 12, 0, 0)), isTrue);

      // Should not exceed 12 predictions
      expect(predicted.length, lessThanOrEqualTo(12));

      // All predictions should be after the last wash
      for (final date in predicted) {
        expect(date.isAfter(DateTime(2026, 7, 3, 12, 0, 0)), isTrue);
      }
    });

    test('getPredictedWashDates returns empty list for empty events', () {
      expect(StatisticsCalculator.getPredictedWashDates([]), isEmpty);
    });

    test('getPredictedWashDates returns predictions for single event', () {
      final predicted = StatisticsCalculator.getPredictedWashDates([
        WashEvent(date: DateTime(2026, 7, 2)),
      ]);

      // Single event uses prior of 3.0 days
      expect(predicted, isNotEmpty);
      expect(predicted.first.isAfter(DateTime(2026, 7, 2, 12, 0, 0)), isTrue);
    });

    test('getPredictedWashDates includes all dates from last wash forward', () {
      final oldEvents = [
        WashEvent(date: DateTime(2022, 1, 1)),
        WashEvent(date: DateTime(2022, 1, 4)), // 3-day interval
      ];

      final predicted = StatisticsCalculator.getPredictedWashDates(oldEvents);

      // Should include predictions even if they are in the past
      expect(predicted, isNotEmpty);

      // All should be after the last wash
      for (final date in predicted) {
        expect(date.isAfter(DateTime(2022, 1, 4, 12, 0, 0)), isTrue);
      }
    });
  });
}
