import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/wash_event.dart';

abstract class IFileOperations {
  Future<String> exportToCSV(List<WashEvent> events);
  Future<List<WashEvent>> importFromCSV(String filePath);
  Future<String> exportToJson(List<WashEvent> events);
  Future<List<WashEvent>> importFromJson(String filePath);
  Future<void> shareFile(String content, String filename);
}

/// Hands generated files to the platform share sheet. Injectable so the
/// temp-file cleanup can be tested without the share plugin's platform channel.
typedef FileShareCallback = Future<void> Function(
    List<XFile> files, String text);

class FileOperationsService implements IFileOperations {
  final FileShareCallback? _share;

  FileOperationsService({FileShareCallback? share}) : _share = share;

  @override
  Future<String> exportToCSV(List<WashEvent> events) async {
    final buffer = StringBuffer();
    buffer.writeln('Date');

    for (final event in events) {
      buffer.writeln(DateFormat('yyyy-MM-dd').format(event.date));
    }

    return buffer.toString();
  }

  @override
  Future<List<WashEvent>> importFromCSV(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final lines = content.split(RegExp(r'\r?\n'));

      final events = <WashEvent>[];
      for (final rawLine in lines) {
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
    } catch (e) {
      debugPrint('Error reading CSV file: $e');
      throw Exception('Error importing CSV: $e');
    }
  }

  @override
  Future<String> exportToJson(List<WashEvent> events) async {
    final jsonList = events.map((e) => e.toJson()).toList();
    return jsonEncode(jsonList);
  }

  @override
  Future<List<WashEvent>> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! List) {
        throw const FormatException('JSON backup must contain a list');
      }
      // A single unreadable entry should not block restoring the rest.
      final events = <WashEvent>[];
      for (final row in decoded) {
        if (row is! Map) continue;
        try {
          events.add(WashEvent.fromJson(Map<String, dynamic>.from(row)));
        } catch (e) {
          debugPrint('Skipping invalid JSON row: $e');
        }
      }
      return events;
    } catch (e) {
      debugPrint('Error reading JSON file: $e');
      throw Exception('Error importing JSON: $e');
    }
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
