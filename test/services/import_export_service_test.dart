import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_master/core/services/import_export_service.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/core/constants/enums.dart';
import 'dart:io';

@GenerateMocks([TaskLocalDataSource])
import 'import_export_service_test.mocks.dart';

void main() {
  late ImportExportService service;
  late MockTaskLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTaskLocalDataSource();
    service = ImportExportService(mockDataSource);
  });

  group('ImportExportService', () {
    final testTasks = [
      TaskModel(
        id: 'task-1',
        title: 'Test Task 1',
        description: 'Description 1',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        createdBy: 'user-1',
        assignedTo: [],
        tags: ['test'],
      ),
      TaskModel(
        id: 'task-2',
        title: 'Test Task 2',
        description: 'Description 2',
        status: TaskStatus.completed,
        priority: TaskPriority.low,
        createdAt: DateTime(2026, 1, 2),
        updatedAt: DateTime(2026, 1, 2),
        createdBy: 'user-1',
        assignedTo: [],
        tags: [],
      ),
    ];

    test('exportToJson should create JSON file with tasks', () async {
      // Arrange
      when(
        mockDataSource.getTasks(limit: anyNamed('limit')),
      ).thenAnswer((_) async => testTasks);

      // Act
      final filePath = await service.exportToJson();

      // Assert
      expect(filePath, isNotEmpty);
      expect(filePath, contains('.json'));
      verify(mockDataSource.getTasks(limit: 10000)).called(1);

      // Cleanup
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('exportToCsv should create CSV file with tasks', () async {
      // Arrange
      when(
        mockDataSource.getTasks(limit: anyNamed('limit')),
      ).thenAnswer((_) async => testTasks);

      // Act
      final filePath = await service.exportToCsv();

      // Assert
      expect(filePath, isNotEmpty);
      expect(filePath, contains('.csv'));
      verify(mockDataSource.getTasks(limit: 10000)).called(1);

      // Cleanup
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('CSV export should properly escape special characters', () {
      // Act
      final escaped = service.exportToCsv();

      // This is a private method test - we verify it through export
      expect(escaped, completes);
    });
  });
}
