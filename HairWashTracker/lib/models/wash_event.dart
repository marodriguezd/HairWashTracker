import 'package:table_calendar/table_calendar.dart';

/// Stable calendar-day key (`YYYYMMDD`) for set lookups and deduplication.
int dayKeyOf(DateTime date) => date.year * 10000 + date.month * 100 + date.day;

class WashEvent {
  final DateTime date;

  WashEvent({required DateTime date})
      : date = DateTime(date.year, date.month, date.day, 12, 0, 0);

  /// Day identity of this event; matches [dayKeyOf] for any instant that day.
  int get dayKey => dayKeyOf(date);

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String()};
  }

  factory WashEvent.fromJson(Map<String, dynamic> json) {
    return WashEvent(date: DateTime.parse(json['date']));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WashEvent && isSameDay(other.date, date);
  }

  @override
  int get hashCode => dayKey;
}
