import 'package:task_master/data/models/conflict_model.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/data/datasources/local/conflict_local_data_source.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';

/// Repository for managing sync conflicts
class ConflictRepository {
  final ConflictLocalDataSource _conflictDataSource;
  final TaskLocalDataSource _taskDataSource;

  ConflictRepository(this._conflictDataSource, this._taskDataSource);

  /// Store a detected conflict
  Future<void> storeConflict({
    required String taskId,
    required TaskModel localVersion,
    required TaskModel serverVersion,
  }) async {
    final conflict = ConflictModel(
      taskId: taskId,
      localVersion: localVersion,
      serverVersion: serverVersion,
      detectedAt: DateTime.now(),
    );

    await _conflictDataSource.storeConflict(conflict);
  }

  /// Get all unresolved conflicts
  Future<List<ConflictModel>> getUnresolvedConflicts() async {
    return await _conflictDataSource.getUnresolvedConflicts();
  }

  /// Get conflict for specific task
  Future<ConflictModel?> getConflictForTask(String taskId) async {
    return await _conflictDataSource.getConflictByTaskId(taskId);
  }

  /// Resolve conflict by keeping local version
  Future<void> resolveWithLocal(ConflictModel conflict) async {
    // Update task with local version
    await _taskDataSource.updateTask(conflict.localVersion);

    // Mark conflict as resolved
    if (conflict.id != null) {
      await _conflictDataSource.markAsResolved(
        conflictId: conflict.id!,
        resolutionType: 'local',
      );
    }
  }

  /// Resolve conflict by keeping server version
  Future<void> resolveWithServer(ConflictModel conflict) async {
    // Update task with server version
    await _taskDataSource.updateTask(conflict.serverVersion);

    // Mark conflict as resolved
    if (conflict.id != null) {
      await _conflictDataSource.markAsResolved(
        conflictId: conflict.id!,
        resolutionType: 'server',
      );
    }
  }

  /// Resolve conflict with merged version
  Future<void> resolveWithMerge({
    required ConflictModel conflict,
    required TaskModel mergedVersion,
  }) async {
    // Update task with merged version
    await _taskDataSource.updateTask(mergedVersion);

    // Mark conflict as resolved
    if (conflict.id != null) {
      await _conflictDataSource.markAsResolved(
        conflictId: conflict.id!,
        resolutionType: 'merge',
      );
    }
  }

  /// Get count of unresolved conflicts
  Future<int> getUnresolvedCount() async {
    return await _conflictDataSource.getUnresolvedCount();
  }

  /// Check if task has unresolved conflict
  Future<bool> hasUnresolvedConflict(String taskId) async {
    final conflict = await _conflictDataSource.getConflictByTaskId(taskId);
    return conflict != null;
  }

  /// Clean up old resolved conflicts
  Future<void> cleanupOldConflicts({int daysOld = 30}) async {
    await _conflictDataSource.cleanupOldConflicts(daysOld: daysOld);
  }

  /// Delete all conflicts for a task
  Future<void> deleteConflictsForTask(String taskId) async {
    await _conflictDataSource.deleteConflictsForTask(taskId);
  }
}
