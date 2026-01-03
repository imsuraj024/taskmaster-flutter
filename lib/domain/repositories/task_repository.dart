import 'package:task_master/domain/entities/task.dart';
import 'package:task_master/core/constants/enums.dart';

/// Repository interface for task operations
abstract class TaskRepository {
  /// Create a new task
  Future<Task> createTask(Task task);

  /// Get task by ID
  Future<Task?> getTaskById(String id);

  /// Get all tasks with pagination
  Future<List<Task>> getTasks({
    int offset = 0,
    int limit = 20,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  });

  /// Update existing task
  Future<Task> updateTask(Task task);

  /// Delete task (soft delete)
  Future<void> deleteTask(String id);

  /// Restore deleted task
  Future<void> restoreTask(String id);

  /// Permanently delete task
  Future<void> permanentlyDeleteTask(String id);

  /// Get tasks count
  Future<int> getTasksCount({TaskStatus? status, bool includeDeleted = false});

  /// Search tasks
  Future<List<Task>> searchTasks(String query);

  /// Get tasks by status
  Future<List<Task>> getTasksByStatus(TaskStatus status);

  /// Get tasks by priority
  Future<List<Task>> getTasksByPriority(TaskPriority priority);

  /// Get tasks by tags
  Future<List<Task>> getTasksByTags(List<String> tags);

  /// Bulk delete tasks
  Future<void> bulkDeleteTasks(List<String> taskIds);

  /// Bulk update tasks
  Future<void> bulkUpdateTasks(List<Task> tasks);
}
