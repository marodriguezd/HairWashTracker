import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/wash_event.dart';

abstract class IFileOperations {
  Future<String> exportToCSV(List<WashEvent> events);
  Future<List<WashEvent>> importFromCSV(String filePath);
  Future<void> shareFile(String content, String filename);
}

class FileOperationsService implements IFileOperations {
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
      final lines = content.split('\n');

      final events = <WashEvent>[];

      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        try {
          final date = DateTime.parse(line);
          events.add(WashEvent(date: date));
        } catch (e) {
          debugPrint('Error parsing date: $line - $e');
        }
      }

      return events;
    } catch (e) {
      debugPrint('Error reading CSV file: $e');
      throw Exception('Error importing CSV: $e');
    }
  }

  @override
  Future<void> shareFile(String content, String filename) async {
    final directory = Directory.systemTemp;
    final file = File('${directory.path}/$filename');
    await file.writeAsString(content);
    await Share.shareXFiles([XFile(file.path)], text: 'Hair Wash Data');
  }
}
