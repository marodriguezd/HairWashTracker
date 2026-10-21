import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../models/wash_event.dart';
import '../models/theme_preference.dart';
import '../models/language_preference.dart';
import '../l10n/app_localizations.dart';
import '../services/data_repository.dart';
import '../services/file_operations_service.dart';
import '../utils/statistics_calculator.dart';
import '../models/prediction_result.dart';

/// Resolves the user's picked backup file, or `null` when the picker was
/// dismissed. Injectable so the cancelled-import path stays testable without
/// driving the native picker.
typedef FilePickerCallback = Future<String?> Function();

class AppController extends ChangeNotifier {
  final IDataRepository _repository;
  final IFileOperations _fileOperations;
  final FilePickerCallback? _pickFile;

  List<WashEvent> _selectedEvents = [];
  DateTime _focusedDay = DateTime.now();
  AppThemeMode _themeMode = AppThemeMode.system;
  AppPresetTheme _themePreset = AppPresetTheme.warmCoral;
  String _languageCode = LanguagePreference.auto;
  bool _useDynamicColor = true;
  bool _disposed = false;

  // The calendar renders ~42 cells per frame and the stats page reads the
  // prediction through several getters. Both are pure functions of the event
  // list, so they are cached and invalidated only when that list changes.
  PredictionResult? _prediction;
  Set<int>? _washDayKeys;
  Set<int>? _predictedDayKeys;
  List<DateTime>? _predictedDates;

  AppController({
    required IDataRepository repository,
    required IFileOperations fileOperations,
    FilePickerCallback? pickFile,
  })  : _repository = repository,
        _fileOperations = fileOperations,
        _pickFile = pickFile {
    _initialize();
  }

  List<WashEvent> get selectedEvents => List.unmodifiable(_selectedEvents);
  DateTime get focusedDay => _focusedDay;
  AppThemeMode get themeMode => _themeMode;
  AppPresetTheme get themePreset => _themePreset;

  /// Stored language value: `'auto'` or a supported language code.
  String get languageCode => _languageCode;

  /// Effective UI language code after resolving `'auto'` from the OS locale.
  String get effectiveLanguageCode {
    if (_languageCode != LanguagePreference.auto) return _languageCode;
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      return AppLocalizations.systemDefaultCode(
        locale.languageCode,
        locale.scriptCode,
        locale.countryCode,
      );
    } catch (e) {
      return 'en';
    }
  }

  Locale get flutterLocale => Locale(effectiveLanguageCode);

  /// Localized string lookup for the effective UI language.
  String tr(String key) => AppLocalizations.stringFor(effectiveLanguageCode, key);

  Future<void> setLanguageCode(String code) async {
    _languageCode = _normalizeLanguage(code);
    try {
      await LanguagePreference.setLanguageCode(_languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
    }
    // The await opened a window in which the controller may have been
    // disposed; notifying then would throw.
    if (!_disposed) notifyListeners();
  }

  bool get useDynamicColor => _useDynamicColor;

  int get totalWashes => StatisticsCalculator.getTotalWashes(_selectedEvents);
  int get currentWeekWashes =>
      StatisticsCalculator.getWashesForWeek(_selectedEvents, DateTime.now());
  int get currentMonthWashes =>
      StatisticsCalculator.getWashesForMonth(_selectedEvents, _focusedDay);
  double get averageInterval =>
      StatisticsCalculator.getAverageIntervalDays(_selectedEvents);
  double get medianInterval =>
      StatisticsCalculator.getMedianIntervalDays(_selectedEvents);

  PredictionResult get prediction =>
      _prediction ??= StatisticsCalculator.getPrediction(_selectedEvents);

  DateTime? get nextRecommendedWashDate =>
      _selectedEvents.isEmpty ? null : prediction.nextWashDate;
  /// Defensive unmodifiable copy: the underlying list belongs to the cached
  /// [PredictionResult] and mutating it would corrupt every later read.
  List<DateTime> get predictedWashDates =>
      _predictedDates ??= List.unmodifiable(prediction.predictedDates);
  PredictionConfidence get predictionConfidence => prediction.confidence;
  double get adaptiveInterval => prediction.adaptiveIntervalDays;
  double get trendSlope => prediction.trendSlope;
  int? get preferredWeekday => prediction.preferredWeekday;

  Set<int> get _washDays => _washDayKeys ??=
      _selectedEvents.map((event) => event.dayKey).toSet();

  Set<int> get _predictedDays => _predictedDayKeys ??=
      prediction.predictedDates.map(dayKeyOf).toSet();

  List<WashEvent> getEventsForDay(DateTime day) {
    final key = dayKeyOf(day);
    if (!_washDays.contains(key)) return const [];
    return List.unmodifiable(
        _selectedEvents.where((event) => event.dayKey == key));
  }

  bool isWashDay(DateTime day) => _washDays.contains(dayKeyOf(day));

  bool isPredictedWashDay(DateTime day) =>
      _predictedDays.contains(dayKeyOf(day));

  void toggleWashDay(DateTime day) {
    final key = dayKeyOf(day);
    if (_washDays.contains(key)) {
      _selectedEvents.removeWhere((event) => event.dayKey == key);
    } else {
      _selectedEvents.add(WashEvent(date: day));
    }
    _invalidateDerived();
    _saveEvents();
    notifyListeners();
  }

  /// Keeps the focused day in the same local-noon frame as every stored event:
  /// the calendar's page callback hands back UTC instants, which would leak a
  /// midnight instant into month counts and later date arithmetic.
  void setFocusedDay(DateTime day) {
    _focusedDay = DateTime(day.year, day.month, day.day, 12);
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    try {
      await ThemePreference.setThemeMode(mode);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> setThemePreset(AppPresetTheme preset) async {
    _themePreset = preset;
    // Picking a seed accent opts out of system dynamic color.
    if (_useDynamicColor) {
      _useDynamicColor = false;
      try {
        await ThemePreference.setUseDynamicColor(false);
      } catch (e) {
        debugPrint('Error saving dynamic color: $e');
      }
    }
    try {
      await ThemePreference.setThemePreset(preset);
    } catch (e) {
      debugPrint('Error saving theme preset: $e');
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> setUseDynamicColor(bool value) async {
    _useDynamicColor = value;
    try {
      await ThemePreference.setUseDynamicColor(value);
    } catch (e) {
      debugPrint('Error saving dynamic color: $e');
    }
    if (!_disposed) notifyListeners();
  }

  void previousMonth() => _shiftFocusedMonth(-1);

  void nextMonth() => _shiftFocusedMonth(1);

  /// Shifts the focused month while clamping the day to the target month's
  /// length, so Jan 31 → Feb 28 instead of overflowing into March.
  void _shiftFocusedMonth(int delta) {
    final firstOfTarget =
        DateTime(_focusedDay.year, _focusedDay.month + delta, 1);
    final daysInTarget =
        DateTime(firstOfTarget.year, firstOfTarget.month + 1, 0).day;
    final day =
        _focusedDay.day > daysInTarget ? daysInTarget : _focusedDay.day;
    _focusedDay = DateTime(firstOfTarget.year, firstOfTarget.month, day, 12);
    notifyListeners();
  }

  /// Loads events and preferences concurrently and publishes them in a single
  /// notification, avoiding a rebuild per persisted field at startup.
  Future<void> _initialize() async {
    try {
      final results = await Future.wait<Object?>([
        _repository.loadWashEvents(),
        ThemePreference.getThemeMode(),
        ThemePreference.getThemePreset(),
        ThemePreference.getUseDynamicColor(),
        LanguagePreference.getLanguageCode(),
      ]);
      if (_disposed) return;
      _setEvents(results[0] as List<WashEvent>);
      _themeMode = results[1] as AppThemeMode;
      _themePreset = results[2] as AppPresetTheme;
      _useDynamicColor = results[3] as bool;
      _languageCode = _normalizeLanguage(results[4] as String);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading persisted state: $e');
    }
  }

  static String _normalizeLanguage(String code) {
    final trimmed = code.trim();
    final supported = trimmed == LanguagePreference.auto ||
        AppLocalizations.isSupported(trimmed);
    return supported ? trimmed : 'en';
  }

  /// Replaces the event list while preserving the one-event-per-day invariant;
  /// imported or restored duplicates would otherwise double-count statistics.
  void _setEvents(Iterable<WashEvent> events) {
    final seen = <int>{};
    _selectedEvents = [
      for (final event in events)
        if (seen.add(event.dayKey)) event,
    ];
    _invalidateDerived();
  }

  void _invalidateDerived() {
    _prediction = null;
    _washDayKeys = null;
    _predictedDayKeys = null;
    _predictedDates = null;
  }

  Future<void> _saveEvents() async {
    try {
      await _repository.saveWashEvents(_selectedEvents);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  /// Writes the versioned JSON backup and hands it to the share sheet.
  ///
  /// The caller renders any failure, so it is not wrapped again here.
  Future<void> exportData() async {
    final content = await _fileOperations.exportToJson(_selectedEvents);
    final filename =
        'hair_wash_tracker_backup_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.json';
    await _fileOperations.shareFile(content, filename);
  }

  /// Restores a backup and returns `false` when the picker was dismissed, so
  /// callers can avoid reporting a successful import that never happened.
  ///
  /// Every file type is selectable on purpose. Android providers report CSV as
  /// `text/csv`, `text/comma-separated-values` or plain `text/plain` depending
  /// on how the file arrived, so an extension filter would hide a 1.0.x backup
  /// from the very users who need it; the content sniffing in the service is
  /// what actually decides whether a file is a backup.
  Future<bool> importData() async {
    if (_disposed) return false;
    final path = await _pickBackupFile();
    if (path == null || _disposed) return false;

    final events = await _fileOperations.importFromBackup(path);
    if (_disposed) return false;
    _rejectEmptyImport(events);
    _setEvents(events);
    await _saveEvents();
    if (_disposed) return false;
    notifyListeners();
    return true;
  }

  /// A backup with no usable dates is a failed restore, not an instruction to
  /// erase the current history.
  static void _rejectEmptyImport(List<WashEvent> events) {
    if (events.isEmpty) {
      throw const FormatException('No wash dates found in the selected file');
    }
  }

  Future<String?> _pickBackupFile() async {
    final picker = _pickFile;
    if (picker != null) return picker();
    final file = await FilePicker.pickFile(type: FileType.any);
    return file?.path;
  }

  /// Wipes the store before the in-memory list: if the wipe fails the user keeps
  /// a calendar that still matches the data on disk instead of an empty shell.
  Future<void> clearAllData() async {
    await _repository.clearWashEvents();
    _setEvents(const []);
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
