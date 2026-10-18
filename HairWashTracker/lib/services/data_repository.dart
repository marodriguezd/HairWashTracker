import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wash_event.dart';

abstract class IDataRepository {
  Future<void> saveWashEvents(List<WashEvent> events);
  Future<List<WashEvent>> loadWashEvents();
  Future<void> clearWashEvents();
}

class SharedPreferencesRepository implements IDataRepository {
  static const String _key = 'wash_events';

  @override
  Future<void> saveWashEvents(List<WashEvent> events) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = events.map((event) => event.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  @override
  Future<List<WashEvent>> loadWashEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) return [];
      return _parseEvents(decoded);
    } catch (e) {
      debugPrint('Error loading wash events: $e');
      return [];
    }
  }

  /// One damaged row must not discard the rest of the history: the loaded list
  /// is what the next save persists, so dropping everything here would erase
  /// the user's record permanently.
  static List<WashEvent> _parseEvents(List<dynamic> rows) {
    final events = <WashEvent>[];
    for (final row in rows) {
      if (row is! Map) continue;
      try {
        events.add(WashEvent.fromJson(Map<String, dynamic>.from(row)));
      } catch (e) {
        debugPrint('Skipping invalid wash event: $e');
      }
    }
    return events;
  }

  @override
  Future<void> clearWashEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
