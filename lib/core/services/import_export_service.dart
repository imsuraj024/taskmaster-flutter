import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/core/constants/enums.dart';

/// Service for importing and exporting tasks
class ImportExportService {
  final TaskLocalDataSource _taskDataSource;

  ImportExportService(this._taskDataSource);

  /// Export tasks to JSON file
  Future<String> exportToJson() async {
    try {
      final tasks = await _taskDataSource.getTasks(limit: 10000);
      final jsonData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(jsonEncode(jsonData));

      return file.path;
    } catch (e) {
      throw Exception('Export failed: ${e.toString()}');
    }
  }

  /// Export tasks to CSV file
  Future<String> exportToCsv() async {
    try {
      final tasks = await _taskDataSource.getTasks(limit: 10000);
      final csvLines = <String>[];

      // Header
      csvLines.add(
        'ID,Title,Description,Status,Priority,DueDate,CreatedAt,UpdatedAt',
      );

      // Data rows
      for (final task in tasks) {
        csvLines.add(
          [
            task.id,
            _escapeCsv(task.title),
            _escapeCsv(task.description ?? ''),
            task.status.toJson(),
            task.priority.toJson(),
            task.dueDate?.toIso8601String() ?? '',
            task.createdAt.toIso8601String(),
            task.updatedAt.toIso8601String(),
          ].join(','),
        );
      }

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/tasks_export_${DateTime.now().millisecondsSinceEpoch}.csv',
      );
      await file.writeAsString(csvLines.join('\n'));

      return file.path;
    } catch (e) {
      throw Exception('CSV export failed: ${e.toString()}');
    }
  }

  /// Import tasks from JSON file
  Future<int> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      final jsonData = jsonDecode(contents) as Map<String, dynamic>;

      final tasksJson = jsonData['tasks'] as List;
      final tasks = tasksJson
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Insert tasks one by one
      for (final task in tasks) {
        await _taskDataSource.insertTask(task);
      }

      return tasks.length;
    } catch (e) {
      throw Exception('Import failed: ${e.toString()}');
    }
  }

  /// Import tasks from CSV file
  Future<int> importFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final contents = await file.readAsString();
      final lines = contents.split('\n');

      if (lines.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Skip header row
      final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty);
      int importedCount = 0;

      for (final line in dataLines) {
        final parts = _parseCsvLine(line);
        if (parts.length < 8) continue;

        try {
          final task = TaskModel(
            id: parts[0],
            title: parts[1],
            description: parts[2].isEmpty ? null : parts[2],
            status: TaskStatus.values.firstWhere(
              (s) => s.toJson() == parts[3],
              orElse: () => TaskStatus.pending,
            ),
            priority: TaskPriority.values.firstWhere(
              (p) => p.toJson() == parts[4],
              orElse: () => TaskPriority.medium,
            ),
            dueDate: parts[5].isEmpty ? null : DateTime.parse(parts[5]),
            createdAt: DateTime.parse(parts[6]),
            updatedAt: DateTime.parse(parts[7]),
            createdBy: 'imported',
            assignedTo: [],
            tags: [],
          );

          await _taskDataSource.insertTask(task);
          importedCount++;
        } catch (e) {
          // Skip invalid rows
          continue;
        }
      }

      return importedCount;
    } catch (e) {
      throw Exception('CSV import failed: ${e.toString()}');
    }
  }

  /// Parse CSV line handling quoted values
  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString());
    return result;
  }

  /// Escape CSV special characters
  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
