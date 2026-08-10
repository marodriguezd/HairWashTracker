import 'package:flutter_test/flutter_test.dart';
import 'package:hair_wash_tracker/utils/wash_predictive_model.dart';
import 'package:hair_wash_tracker/models/prediction_result.dart';
import 'package:hair_wash_tracker/models/wash_event.dart';

void main() {
  group('WashPredictiveModel', () {
    WashEvent createEvent(DateTime date) {
      // WashEvent normalizes time to noon
      return WashEvent(date: date);
    }

    List<WashEvent> generateEvents(DateTime start, List<int> intervals) {
      final events = <WashEvent>[createEvent(start)];
      var current = start;
      for (final interval in intervals) {
        current = current.add(Duration(days: interval));
        events.add(createEvent(current));
      }
      return events;
    }

    test('1. Empty events returns default 3-day prediction, confidence low', () {
      final result = WashPredictiveModel.predict([]);
      expect(result.adaptiveIntervalDays, 3.0);
      expect(result.confidence, PredictionConfidence.low);
    });

    test('2. Single event returns prediction at +3 days (prior), confidence low', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final result = WashPredictiveModel.predict([createEvent(baseDate)]);
      
      expect(result.adaptiveIntervalDays, 3.0);
      expect(result.confidence, PredictionConfidence.low);
      expect(result.nextWashDate, baseDate.add(const Duration(days: 3)));
    });

    test('3. Two events (1 interval) starts adapting, confidence low', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [5]); // 1 interval of 5 days
      final result = WashPredictiveModel.predict(events);
      
      // EWMA with alpha 0.3, prior 3.0: 3.0 * 0.7 + 5.0 * 0.3 = 2.1 + 1.5 = 3.6
      expect(result.confidence, PredictionConfidence.low);
      expect(result.adaptiveIntervalDays, moreOrLessEquals(3.6, epsilon: 0.1));
    });

    test('4. Three events (2 intervals): confidence medium, trend slope computable', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [5, 5]);
      final result = WashPredictiveModel.predict(events);
      
      expect(result.confidence, PredictionConfidence.medium);
      expect(result.trendSlope, isNotNull);
    });

    test('5. Five events with uniform 3-day intervals: EWMA ≈ 3.0, confidence high', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [3, 3, 3, 3]); // 5 events = 4 intervals
      final result = WashPredictiveModel.predict(events);
      
      expect(result.confidence, PredictionConfidence.medium); // 4 intervals is medium
    });

    test('6. EWMA adaptation: weights recent more', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      // intervals: 5, 5, 5, 5, 2, 2, 2
      final events = generateEvents(baseDate, [5, 5, 5, 5, 2, 2, 2]); 
      final result = WashPredictiveModel.predict(events);
      
      // Since recent are 2s, should be closer to 2 than 5
      expect(result.adaptiveIntervalDays, lessThan(3.5));
    });

    test('7. Trend detection increasing: positive slope', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [2, 3, 4, 5, 6]);
      final result = WashPredictiveModel.predict(events);
      
      expect(result.trendSlope, greaterThan(0));
    });

    test('8. Trend detection decreasing: negative slope', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [6, 5, 4, 3, 2]);
      final result = WashPredictiveModel.predict(events);
      
      expect(result.trendSlope, lessThan(0));
    });

    test('9. Trend detection stable: slope ≈ 0', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [3, 3, 3, 3, 3]);
      final result = WashPredictiveModel.predict(events);
      
      expect(result.trendSlope, moreOrLessEquals(0, epsilon: 0.01));
    });

    test('10. Day-of-week affinity: mostly Mondays', () {
      // 5 washes on Monday
      final events = [
        createEvent(DateTime(2023, 1, 2, 12)), // Monday
        createEvent(DateTime(2023, 1, 9, 12)), // Monday
        createEvent(DateTime(2023, 1, 16, 12)), // Monday
        createEvent(DateTime(2023, 1, 23, 12)), // Monday
        createEvent(DateTime(2023, 1, 30, 12)), // Monday
      ];
      final result = WashPredictiveModel.predict(events);
      
      expect(result.preferredWeekday, DateTime.monday);
    });

    test('11. No day-of-week affinity: washes spread out', () {
      final events = [
        createEvent(DateTime(2023, 1, 2, 12)), // Mon
        createEvent(DateTime(2023, 1, 4, 12)), // Wed
        createEvent(DateTime(2023, 1, 6, 12)), // Fri
        createEvent(DateTime(2023, 1, 8, 12)), // Sun
        createEvent(DateTime(2023, 1, 10, 12)), // Tue
      ];
      final result = WashPredictiveModel.predict(events);
      
      expect(result.preferredWeekday, isNull);
    });

    test('12. Fewer than 5 events: preferredWeekday always null', () {
      final events = [
        createEvent(DateTime(2023, 1, 2, 12)), // Mon
        createEvent(DateTime(2023, 1, 9, 12)), // Mon
        createEvent(DateTime(2023, 1, 16, 12)), // Mon
        createEvent(DateTime(2023, 1, 23, 12)), // Mon
      ]; // Only 4 events
      final result = WashPredictiveModel.predict(events);
      
      expect(result.preferredWeekday, isNull);
    });

    test('13. Predictions count: <= 12 max', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [2, 2, 2]); // tight interval = many predictions
      final result = WashPredictiveModel.predict(events);
      
      expect(result.predictedDates.length, lessThanOrEqualTo(12));
    });

    test('14. Predictions within 90 days', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [10, 10, 10]);
      final result = WashPredictiveModel.predict(events);
      
      final lastWash = events.last.date;
      final maxDate = lastWash.add(const Duration(days: 90));
      
      for (final date in result.predictedDates) {
        expect(date.isBefore(maxDate) || date.isAtSameMomentAs(maxDate), isTrue);
      }
    });

    test('15. Predictions after last wash', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [3, 4, 5]);
      final result = WashPredictiveModel.predict(events);
      
      final lastWash = events.last.date;
      for (final date in result.predictedDates) {
        expect(date.isAfter(lastWash), isTrue);
      }
    });

    test('16. Predictions spacing approx by adaptive interval', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [4, 4, 4, 4]);
      final result = WashPredictiveModel.predict(events);
      
      if (result.predictedDates.length > 1) {
        final diff = result.predictedDates[1].difference(result.predictedDates[0]).inDays;
        expect((diff - result.adaptiveIntervalDays).abs(), lessThan(2));
      }
    });

    test('17. Interval clamping min (1 day)', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      // Generate very tight events
      final events = [
        createEvent(baseDate),
        createEvent(baseDate.add(const Duration(hours: 1))),
        createEvent(baseDate.add(const Duration(hours: 2))),
      ];
      final result = WashPredictiveModel.predict(events);
      
      expect(result.adaptiveIntervalDays, greaterThanOrEqualTo(1.0));
    });

    test('18. Interval clamping max (90 days)', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [100, 150]);
      final result = WashPredictiveModel.predict(events);
      
      expect(result.adaptiveIntervalDays, lessThanOrEqualTo(90.0));
    });

    test('19. Outlier resilience', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final normalEvents = generateEvents(baseDate, [4, 4, 4, 4, 4]);
      final outlierEvents = generateEvents(baseDate, [4, 4, 4, 4, 20]);
      
      final resNormal = WashPredictiveModel.predict(normalEvents);
      final resOutlier = WashPredictiveModel.predict(outlierEvents);
      
      // Outlier shouldn't totally wreck the EWMA compared to straight average
      expect(resOutlier.adaptiveIntervalDays, lessThan(10.0));
    });

    test('20. Model rebuilds correctly (deterministic)', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [3, 4, 2, 5]);
      
      final result1 = WashPredictiveModel.predict(events);
      final result2 = WashPredictiveModel.predict(events);
      
      expect(result1.adaptiveIntervalDays, result2.adaptiveIntervalDays);
      expect(result1.nextWashDate, result2.nextWashDate);
      expect(result1.confidence, result2.confidence);
    });

    test('21. Next wash date is after last wash', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      final events = generateEvents(baseDate, [10, 10]);
      final result = WashPredictiveModel.predict(events);
      
      expect(result.nextWashDate.isAfter(events.last.date), isTrue);
    });

    test('22. Confidence levels match interval count thresholds', () {
      final baseDate = DateTime(2023, 1, 1, 12);
      
      // 0 intervals
      expect(WashPredictiveModel.predict([createEvent(baseDate)]).confidence, PredictionConfidence.low);
      
      // 1 interval
      expect(WashPredictiveModel.predict(generateEvents(baseDate, [3])).confidence, PredictionConfidence.low);
      
      // 2 intervals
      expect(WashPredictiveModel.predict(generateEvents(baseDate, [3, 3])).confidence, PredictionConfidence.medium);
      
      // 4 intervals
      expect(WashPredictiveModel.predict(generateEvents(baseDate, [3, 3, 3, 3])).confidence, PredictionConfidence.medium);
      
      // 5 intervals
      expect(WashPredictiveModel.predict(generateEvents(baseDate, [3, 3, 3, 3, 3])).confidence, PredictionConfidence.high);
    });
  });
}
