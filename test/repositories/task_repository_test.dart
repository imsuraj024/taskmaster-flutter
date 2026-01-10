import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_master/data/repositories/task_repository_impl.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/repositories/sync_repository.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/core/constants/enums.dart';

@GenerateMocks([TaskLocalDataSource, SyncRepository])
import 'task_repository_test.mocks.dart';

void main() {
  late TaskRepositoryImpl repository;
  late MockTaskLocalDataSource mockLocalDataSource;
  late MockSyncRepository mockSyncRepository;

  setUp(() {
    mockLocalDataSource = MockTaskLocalDataSource();
    mockSyncRepository = MockSyncRepository();
    repository = TaskRepositoryImpl(
      mockLocalDataSource,
      syncRepository: mockSyncRepository,
    );
  });

  group('TaskRepository', () {
    final testTask = TaskModel(
      id: 'test-id',
      title: 'Test Task',
      description: 'Test Description',
      status: TaskStatus.pending,
      priority: TaskPriority.medium,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      createdBy: 'test-user',
      assignedTo: [],
      tags: [],
    );

    test('createTask should insert task and queue sync operation', () async {
      // Arrange
      when(
        mockLocalDataSource.insertTask(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockSyncRepository.queueOperation(
          taskId: anyNamed('taskId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        ),
      ).thenAnswer((_) async => Future.value());

      // Act
      await repository.createTask(testTask);

      // Assert
      verify(mockLocalDataSource.insertTask(any)).called(1);
      verify(
        mockSyncRepository.queueOperation(
          taskId: testTask.id,
          operation: SyncOperation.create,
          payload: any,
        ),
      ).called(1);
    });

    test('getTaskById should return task from local data source', () async {
      // Arrange
      when(
        mockLocalDataSource.getTaskById(any),
      ).thenAnswer((_) async => testTask);

      // Act
      final result = await repository.getTaskById('test-id');

      // Assert
      expect(result, equals(testTask));
      verify(mockLocalDataSource.getTaskById('test-id')).called(1);
    });

    test('getTasks should return list of tasks with filters', () async {
      // Arrange
      final tasks = [testTask];
      when(
        mockLocalDataSource.getTasks(
          offset: anyNamed('offset'),
          limit: anyNamed('limit'),
          status: anyNamed('status'),
          priority: anyNamed('priority'),
          tags: anyNamed('tags'),
          searchQuery: anyNamed('searchQuery'),
          sortBy: anyNamed('sortBy'),
          ascending: anyNamed('ascending'),
        ),
      ).thenAnswer((_) async => tasks);

      // Act
      final result = await repository.getTasks(
        offset: 0,
        limit: 20,
        status: TaskStatus.pending,
      );

      // Assert
      expect(result, equals(tasks));
      verify(
        mockLocalDataSource.getTasks(
          offset: 0,
          limit: 20,
          status: TaskStatus.pending,
          priority: null,
          tags: null,
          searchQuery: null,
          sortBy: null,
          ascending: true,
        ),
      ).called(1);
    });

    test('updateTask should update task and queue sync operation', () async {
      // Arrange
      when(
        mockLocalDataSource.updateTask(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockSyncRepository.queueOperation(
          taskId: anyNamed('taskId'),
          operation: anyNamed('operation'),
          payload: anyNamed('payload'),
        ),
      ).thenAnswer((_) async => Future.value());

      // Act
      await repository.updateTask(testTask);

      // Assert
      verify(mockLocalDataSource.updateTask(any)).called(1);
      verify(
        mockSyncRepository.queueOperation(
          taskId: testTask.id,
          operation: SyncOperation.update,
          payload: any,
        ),
      ).called(1);
    });

    test(
      'deleteTask should soft delete task and queue sync operation',
      () async {
        // Arrange
        when(
          mockLocalDataSource.deleteTask(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockSyncRepository.queueOperation(
            taskId: anyNamed('taskId'),
            operation: anyNamed('operation'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.deleteTask('test-id');

        // Assert
        verify(mockLocalDataSource.deleteTask('test-id')).called(1);
        verify(
          mockSyncRepository.queueOperation(
            taskId: 'test-id',
            operation: SyncOperation.delete,
          ),
        ).called(1);
      },
    );

    test(
      'bulkDeleteTasks should delete multiple tasks and queue operations',
      () async {
        // Arrange
        final taskIds = ['id1', 'id2', 'id3'];
        when(
          mockLocalDataSource.bulkDeleteTasks(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockSyncRepository.queueOperation(
            taskId: anyNamed('taskId'),
            operation: anyNamed('operation'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        await repository.bulkDeleteTasks(taskIds);

        // Assert
        verify(mockLocalDataSource.bulkDeleteTasks(taskIds)).called(1);
        verify(
          mockSyncRepository.queueOperation(
            taskId: anyNamed('taskId'),
            operation: SyncOperation.delete,
          ),
        ).called(3);
      },
    );

    test('getTasksCount should return count from local data source', () async {
      // Arrange
      when(
        mockLocalDataSource.getTasksCount(
          status: anyNamed('status'),
          includeDeleted: anyNamed('includeDeleted'),
        ),
      ).thenAnswer((_) async => 42);

      // Act
      final result = await repository.getTasksCount(status: TaskStatus.pending);

      // Assert
      expect(result, equals(42));
      verify(
        mockLocalDataSource.getTasksCount(
          status: TaskStatus.pending,
          includeDeleted: false,
        ),
      ).called(1);
    });
  });
}
