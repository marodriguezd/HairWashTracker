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

    test('getNextRecommendedWashDate returns correct recommendation', () {
      // Last wash is Jul 3. Avg interval is 4.5, rounded to 5 days.
      // Jul 3 + 5 days = Jul 8.
      expect(StatisticsCalculator.getNextRecommendedWashDate(events), DateTime(2026, 7, 8, 12, 0, 0));

      // If empty, returns null
      expect(StatisticsCalculator.getNextRecommendedWashDate([]), isNull);

      // If 1 event, defaults to 3 days
      // Jul 2 + 3 days = Jul 5
      expect(StatisticsCalculator.getNextRecommendedWashDate([WashEvent(date: DateTime(2026, 7, 2))]), DateTime(2026, 7, 5, 12, 0, 0));
    });
  });
}
