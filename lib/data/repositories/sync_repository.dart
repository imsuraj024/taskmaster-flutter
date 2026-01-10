import 'package:task_master/data/models/sync_operation_model.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/repositories/conflict_repository.dart';
import 'package:task_master/core/services/connectivity_service.dart';
import 'package:task_master/core/services/task_api_service.dart';
import 'package:task_master/core/constants/enums.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Response from delta sync operation
class SyncResponse {
  final List<String> syncedTaskIds;
  final List<TaskModel> conflicts;
  final List<TaskModel> serverUpdates;
  final bool success;
  final String? error;

  SyncResponse({
    required this.syncedTaskIds,
    required this.conflicts,
    required this.serverUpdates,
    required this.success,
    this.error,
  });
}

/// Repository for managing synchronization operations
class SyncRepository {
  final SyncQueueLocalDataSource _syncQueueDataSource;
  final TaskLocalDataSource _taskDataSource;
  final ConnectivityService _connectivityService;
  final ConflictRepository? _conflictRepository;
  final TaskApiService _taskApiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  SyncRepository(
    this._syncQueueDataSource,
    this._taskDataSource,
    this._connectivityService,
    this._taskApiService, {
    ConflictRepository? conflictRepository,
  }) : _conflictRepository = conflictRepository;

  /// Get last sync timestamp
  Future<String?> _getLastSyncTime() async {
    return await _storage.read(key: 'last_sync_time');
  }

  /// Save last sync timestamp
  Future<void> _saveLastSyncTime(String timestamp) async {
    await _storage.write(key: 'last_sync_time', value: timestamp);
  }

  /// Add task operation to sync queue
  Future<void> queueOperation({
    required String taskId,
    required SyncOperation operation,
    TaskModel? payload,
  }) async {
    final syncOp = SyncOperationModel(
      taskId: taskId,
      operation: operation,
      timestamp: DateTime.now(),
      payload: payload,
    );

    await _syncQueueDataSource.addToQueue(syncOp);
  }

  /// Get pending operations count
  Future<int> getPendingCount() async {
    return await _syncQueueDataSource.getPendingCount();
  }

  /// Perform delta sync
  Future<SyncResponse> performSync() async {
    // Check connectivity
    final isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      return SyncResponse(
        syncedTaskIds: [],
        conflicts: [],
        serverUpdates: [],
        success: false,
        error: 'No internet connection',
      );
    }

    try {
      // Get pending operations (batch of 50)
      final operations = await _syncQueueDataSource.getPendingOperations(
        limit: 50,
      );

      if (operations.isEmpty) {
        return SyncResponse(
          syncedTaskIds: [],
          conflicts: [],
          serverUpdates: [],
          success: true,
        );
      }

      // Group operations by type
      final creates = operations
          .where((op) => op.operation == SyncOperation.create)
          .toList();
      final updates = operations
          .where((op) => op.operation == SyncOperation.update)
          .toList();
      final deletes = operations
          .where((op) => op.operation == SyncOperation.delete)
          .toList();

      final syncedIds = <String>[];
      final conflicts = <TaskModel>[];

      // TODO: Send operations to server via API
      // For now, simulate successful sync

      // Process creates
      for (final op in creates) {
        if (op.id != null) {
          await _syncQueueDataSource.removeFromQueue(op.id!);
          syncedIds.add(op.taskId);

          // Update task sync status
          final task = await _taskDataSource.getTaskById(op.taskId);
          if (task != null) {
            final updatedTask = task.copyWith(
              syncStatus: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            );
            await _taskDataSource.updateTask(updatedTask);
          }
        }
      }

      // Process updates
      for (final op in updates) {
        if (op.id != null) {
          await _syncQueueDataSource.removeFromQueue(op.id!);
          syncedIds.add(op.taskId);

          // Update task sync status
          final task = await _taskDataSource.getTaskById(op.taskId);
          if (task != null) {
            final updatedTask = task.copyWith(
              syncStatus: SyncStatus.synced,
              lastSyncedAt: DateTime.now(),
            );
            await _taskDataSource.updateTask(updatedTask);
          }
        }
      }

      // Process deletes
      for (final op in deletes) {
        if (op.id != null) {
          await _syncQueueDataSource.removeFromQueue(op.id!);
          syncedIds.add(op.taskId);
        }
      }

      return SyncResponse(
        syncedTaskIds: syncedIds,
        conflicts: conflicts,
        serverUpdates: [],
        success: true,
      );
    } catch (e) {
      return SyncResponse(
        syncedTaskIds: [],
        conflicts: [],
        serverUpdates: [],
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Retry failed operations with exponential backoff
  Future<void> retryFailedOperations() async {
    final failedOps = await _syncQueueDataSource.getFailedOperations();

    for (final op in failedOps) {
      // Calculate backoff delay (exponential: 30s, 60s, 120s, etc.)
      final backoffSeconds = 30 * (1 << op.retryCount.clamp(0, 5));
      final timeSinceLastTry = DateTime.now().difference(op.timestamp);

      if (timeSinceLastTry.inSeconds >= backoffSeconds) {
        // Increment retry count
        if (op.id != null) {
          await _syncQueueDataSource.incrementRetryCount(op.id!);
        }
      }
    }
  }

  /// Clear sync queue (for testing or reset)
  Future<void> clearQueue() async {
    await _syncQueueDataSource.clearQueue();
  }

  /// Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    final pending = await _syncQueueDataSource.getPendingCount();
    final failed = await _syncQueueDataSource.getFailedOperations();
    final creates = await _syncQueueDataSource.getOperationsByType(
      SyncOperation.create,
    );
    final updates = await _syncQueueDataSource.getOperationsByType(
      SyncOperation.update,
    );
    final deletes = await _syncQueueDataSource.getOperationsByType(
      SyncOperation.delete,
    );

    return {
      'pending': pending,
      'failed': failed.length,
      'creates': creates.length,
      'updates': updates.length,
      'deletes': deletes.length,
    };
  }
}
