import 'package:task_master/domain/entities/task.dart';
import 'package:task_master/domain/repositories/task_repository.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/core/constants/enums.dart';

/// Implementation of TaskRepository using local data source
class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource _localDataSource;

  TaskRepositoryImpl(this._localDataSource);

  @override
  Future<Task> createTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _localDataSource.insertTask(taskModel);
    return taskModel;
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return await _localDataSource.getTaskById(id);
  }

  @override
  Future<List<Task>> getTasks({
    int offset = 0,
    int limit = 20,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  }) async {
    return await _localDataSource.getTasks(
      offset: offset,
      limit: limit,
      status: status,
      priority: priority,
      tags: tags,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  @override
  Future<Task> updateTask(Task task) async {
    final taskModel = TaskModel.fromEntity(task);
    await _localDataSource.updateTask(taskModel);
    return taskModel;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }

  @override
  Future<void> restoreTask(String id) async {
    await _localDataSource.restoreTask(id);
  }

  @override
  Future<void> permanentlyDeleteTask(String id) async {
    await _localDataSource.permanentlyDeleteTask(id);
  }

  @override
  Future<int> getTasksCount({
    TaskStatus? status,
    bool includeDeleted = false,
  }) async {
    return await _localDataSource.getTasksCount(
      status: status,
      includeDeleted: includeDeleted,
    );
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    return await _localDataSource.searchTasks(query);
  }

  @override
  Future<List<Task>> getTasksByStatus(TaskStatus status) async {
    return await _localDataSource.getTasks(status: status);
  }

  @override
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    return await _localDataSource.getTasks(priority: priority);
  }

  @override
  Future<List<Task>> getTasksByTags(List<String> tags) async {
    return await _localDataSource.getTasksByTags(tags);
  }

  @override
  Future<void> bulkDeleteTasks(List<String> taskIds) async {
    await _localDataSource.bulkDeleteTasks(taskIds);
  }

  @override
  Future<void> bulkUpdateTasks(List<Task> tasks) async {
    final taskModels = tasks.map((task) => TaskModel.fromEntity(task)).toList();
    await _localDataSource.bulkUpdateTasks(taskModels);
  }
}
