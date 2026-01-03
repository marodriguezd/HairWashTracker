import 'package:table_calendar/table_calendar.dart';

class WashEvent {
  final DateTime date;

  WashEvent({required DateTime date})
      : date = DateTime(date.year, date.month, date.day, 12, 0, 0);

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
  int get hashCode => date.hashCode;
}
