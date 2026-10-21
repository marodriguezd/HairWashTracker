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

    test('getWashesForWeek excludes the Sunday before the week', () {
      final sunday = WashEvent(date: DateTime(2026, 6, 14));
      final monday = WashEvent(date: DateTime(2026, 6, 15));
      final wednesday = DateTime(2026, 6, 17);

      // The previous Sunday's noon event must not leak into Mon–Sun week 25.
      expect(StatisticsCalculator.getWashesForWeek([sunday, monday], wednesday), 1);
      expect(StatisticsCalculator.getWashesForWeek([sunday], wednesday), 0);
      // It still belongs to its own week.
      expect(
          StatisticsCalculator.getWashesForWeek([sunday], DateTime(2026, 6, 14)), 1);
      // The following Monday is excluded from the previous week.
      expect(
          StatisticsCalculator.getWashesForWeek([monday], DateTime(2026, 6, 14)),
          0);
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

    test('consecutive days stay one day apart when the clock shifts', () {
      // A DST spring-forward makes this pair 23 hours long and a fall-back 25;
      // truncating to whole days turned the interval into 0.0 and 1.0.
      final spring = [
        WashEvent(date: DateTime(2026, 3, 7)),
        WashEvent(date: DateTime(2026, 3, 8)),
      ];
      expect(StatisticsCalculator.getAverageIntervalDays(spring), 1.0);
      expect(StatisticsCalculator.getMedianIntervalDays(spring), 1.0);

      final fall = [
        WashEvent(date: DateTime(2026, 10, 31)),
        WashEvent(date: DateTime(2026, 11, 1)),
      ];
      expect(StatisticsCalculator.getAverageIntervalDays(fall), 1.0);
      expect(StatisticsCalculator.getMedianIntervalDays(fall), 1.0);
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

  });
}
