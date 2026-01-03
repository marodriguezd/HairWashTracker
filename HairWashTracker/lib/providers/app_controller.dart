import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/wash_event.dart';
import '../services/data_repository.dart';
import '../services/file_operations_service.dart';
import '../utils/statistics_calculator.dart';

class AppController extends ChangeNotifier {
  final IDataRepository _repository;
  final IFileOperations _fileOperations;

  List<WashEvent> _selectedEvents = [];
  DateTime _focusedDay = DateTime.now();

  AppController({
    required IDataRepository repository,
    required IFileOperations fileOperations,
  })  : _repository = repository,
        _fileOperations = fileOperations {
    _loadEvents();
  }

  // Getters
  List<WashEvent> get selectedEvents => List.unmodifiable(_selectedEvents);
  DateTime get focusedDay => _focusedDay;

  int get totalWashes => StatisticsCalculator.getTotalWashes(_selectedEvents);
  int get currentWeekWashes => StatisticsCalculator.getWashesForWeek(_selectedEvents, DateTime.now());
  int get currentMonthWashes => StatisticsCalculator.getWashesForMonth(_selectedEvents, _focusedDay);

  // Event management
  List<WashEvent> getEventsForDay(DateTime day) {
    return _selectedEvents.where((event) => isSameDay(event.date, day)).toList();
  }

  bool isWashDay(DateTime day) {
    return _selectedEvents.any((event) => isSameDay(event.date, day));
  }

  void toggleWashDay(DateTime day) {
    if (isWashDay(day)) {
      _selectedEvents.removeWhere((event) => isSameDay(event.date, day));
    } else {
      _selectedEvents.add(WashEvent(date: day));
    }
    _saveEvents();
    notifyListeners();
  }

  void setFocusedDay(DateTime day) {
    _focusedDay = day;
    notifyListeners();
  }

  // Data persistence
  Future<void> _loadEvents() async {
    try {
      _selectedEvents = await _repository.loadWashEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading events: $e');
    }
  }

  Future<void> _saveEvents() async {
    try {
      await _repository.saveWashEvents(_selectedEvents);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  // Import/Export operations
  Future<void> exportData() async {
    try {
      final csvContent = await _fileOperations.exportToCSV(_selectedEvents);
      final filename = 'hair_wash_data_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv';
      await _fileOperations.shareFile(csvContent, filename);
    } catch (e) {
      throw Exception('Error exporting data: $e');
    }
  }

  Future<void> importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final events = await _fileOperations.importFromCSV(result.files.single.path!);
        _selectedEvents = events;
        await _saveEvents();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error importing data: $e');
    }
  }

  Future<void> exportDataJson() async {
    try {
      final jsonContent = await _fileOperations.exportToJson(_selectedEvents);
      final filename = 'hair_wash_data_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
      await _fileOperations.shareFile(jsonContent, filename);
    } catch (e) {
      throw Exception('Error exporting JSON data: $e');
    }
  }

  Future<void> importDataJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final events = await _fileOperations.importFromJson(result.files.single.path!);
        _selectedEvents = events;
        await _saveEvents();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error importing JSON data: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      _selectedEvents.clear();
      await _repository.clearWashEvents();
      notifyListeners();
    } catch (e) {
      throw Exception('Error clearing data: $e');
    }
  }
}
