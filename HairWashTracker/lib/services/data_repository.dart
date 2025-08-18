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
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => WashEvent.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading wash events: $e');
      return [];
    }
  }

  @override
  Future<void> clearWashEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
