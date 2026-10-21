import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/wash_event.dart';

/// Backup file handling.
///
/// JSON is the canonical backup format. Import additionally accepts the two
/// formats written by 1.0.x (a bare JSON list and a single-column CSV) so a
/// user upgrading from that version can still restore an existing copy.
abstract class IFileOperations {
  Future<String> exportToJson(List<WashEvent> events);
  Future<List<WashEvent>> importFromBackup(String filePath);
  Future<void> shareFile(String content, String filename);
}

/// Hands generated files to the platform share sheet. Injectable so the
/// temp-file cleanup can be tested without the share plugin's platform channel.
typedef FileShareCallback = Future<void> Function(
    List<XFile> files, String text);

class FileOperationsService implements IFileOperations {
  /// Current backup schema. Import accepts every version up to this one.
  static const int backupVersion = 1;

  /// Marker that lets import reject unrelated JSON without guessing.
  static const String formatId = 'hair-wash-tracker';

  final FileShareCallback? _share;

  FileOperationsService({FileShareCallback? share}) : _share = share;

  @override
  Future<String> exportToJson(List<WashEvent> events) async {
    final payload = <String, dynamic>{
      'format': formatId,
      'version': backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'events': events.map((event) => event.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Reads a backup in any supported shape.
  ///
  /// Dispatch is by content, not by extension, because renamed files are
  /// common once a backup travels through chat apps or storage providers.
  @override
  Future<List<WashEvent>> importFromBackup(String filePath) async {
    final String content;
    try {
      content = await File(filePath).readAsString();
    } catch (e) {
      debugPrint('Error reading backup file: $e');
      throw Exception('Error importing backup: $e');
    }

    // A byte-order mark survives some editors and would otherwise hide the
    // first character from the format sniffing below.
    final trimmed = content.replaceFirst('\uFEFF', '').trim();
    if (trimmed.isEmpty) {
      throw const FormatException('The backup file is empty');
    }
    if (trimmed.startsWith('{')) return _importEnvelope(trimmed);
    if (trimmed.startsWith('[')) return _importEvents(jsonDecode(trimmed));
    return _importCsv(content);
  }

  /// Versioned envelope: `{format, version, exportedAt, events}`.
  List<WashEvent> _importEnvelope(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Backup envelope must be a JSON object');
    }

    // The marker is mandatory: a JSON object with a plausible shape is not
    // proof that it came from this app, and replacing the history from an
    // unrelated file is not recoverable.
    if (decoded['format'] != formatId) {
      throw const FormatException('File is not a Hair Wash Tracker backup');
    }

    final version = decoded['version'];
    if (version is! int) {
      throw const FormatException('Backup envelope has no version');
    }
    // A newer schema may carry fields this build would silently drop; refusing
    // it is safer than restoring a partial history.
    if (version > backupVersion) {
      throw FormatException(
          'Backup version $version is newer than the supported $backupVersion');
    }

    final events = decoded['events'];
    if (events is! List) {
      throw const FormatException('Backup envelope has no events list');
    }
    return _importEvents(events);
  }

  /// One unreadable entry must not block restoring the rest.
  List<WashEvent> _importEvents(List<dynamic> rows) {
    final events = <WashEvent>[];
    for (final row in rows) {
      if (row is! Map) continue;
      try {
        events.add(WashEvent.fromJson(Map<String, dynamic>.from(row)));
      } catch (e) {
        debugPrint('Skipping invalid backup row: $e');
      }
    }
    return events;
  }

  /// 1.0.x CSV: a `Date` header followed by `yyyy-MM-dd` rows.
  List<WashEvent> _importCsv(String content) {
    final events = <WashEvent>[];
    for (final rawLine in content.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // A header or malformed row is skipped by content rather than by
      // position, so headerless exports do not lose their first date.
      final parsed = DateTime.tryParse(line);
      if (parsed == null) {
        debugPrint('Skipping non-date CSV row: $line');
        continue;
      }
      // Noon anchor keeps the calendar day stable across DST boundaries.
      events.add(WashEvent(
        date: DateTime(parsed.year, parsed.month, parsed.day, 12, 0, 0),
      ));
    }
    return events;
  }

  @override
  Future<void> shareFile(String content, String filename) async {
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    try {
      final files = [XFile(file.path)];
      final share = _share;
      if (share != null) {
        await share(files, 'Hair Wash Data');
      } else {
        await SharePlus.instance.share(
          ShareParams(files: files, text: 'Hair Wash Data'),
        );
      }
    } finally {
      // Export copies are single-use; leaving them in temp leaks storage on
      // every share, and the receiving app has already consumed the file.
      if (await file.exists()) await file.delete();
    }
  }
}
