import 'package:sqflite/sqflite.dart';
import 'package:task_master/core/database/database_helper.dart';
import 'package:task_master/data/models/sync_operation_model.dart';
import 'package:task_master/core/constants/enums.dart';

/// Local data source for sync queue operations
class SyncQueueLocalDataSource {
  final DatabaseHelper _dbHelper;

  SyncQueueLocalDataSource(this._dbHelper);

  /// Add operation to sync queue
  Future<int> addToQueue(SyncOperationModel operation) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'sync_queue',
      operation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all pending operations
  Future<List<SyncOperationModel>> getPendingOperations({int? limit}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      orderBy: 'timestamp ASC',
      limit: limit,
    );

    return maps.map((map) => SyncOperationModel.fromMap(map)).toList();
  }

  /// Get operations for a specific task
  Future<List<SyncOperationModel>> getOperationsForTask(String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => SyncOperationModel.fromMap(map)).toList();
  }

  /// Get count of pending operations
  Future<int> getPendingCount() async {
    final db = await _dbHelper.database;
    final result = await db.query('sync_queue', columns: ['COUNT(*) as count']);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Remove operation from queue
  Future<void> removeFromQueue(int operationId) async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [operationId]);
  }

  /// Remove multiple operations from queue
  Future<void> removeMultipleFromQueue(List<int> operationIds) async {
    if (operationIds.isEmpty) return;

    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final id in operationIds) {
      batch.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
    }

    await batch.commit(noResult: true);
  }

  /// Update operation (increment retry count)
  Future<void> updateOperation(SyncOperationModel operation) async {
    if (operation.id == null) return;

    final db = await _dbHelper.database;
    await db.update(
      'sync_queue',
      operation.toMap(),
      where: 'id = ?',
      whereArgs: [operation.id],
    );
  }

  /// Increment retry count for operation
  Future<void> incrementRetryCount(int operationId) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE sync_queue SET retry_count = retry_count + 1 WHERE id = ?',
      [operationId],
    );
  }

  /// Get operations with high retry count (for error handling)
  Future<List<SyncOperationModel>> getFailedOperations({
    int minRetryCount = 3,
  }) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      where: 'retry_count >= ?',
      whereArgs: [minRetryCount],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => SyncOperationModel.fromMap(map)).toList();
  }

  /// Clear all operations from queue (use with caution)
  Future<void> clearQueue() async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue');
  }

  /// Get operations by type
  Future<List<SyncOperationModel>> getOperationsByType(
    SyncOperation type,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      where: 'operation = ?',
      whereArgs: [type.toJson()],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => SyncOperationModel.fromMap(map)).toList();
  }

  /// Get oldest operation
  Future<SyncOperationModel?> getOldestOperation() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_queue',
      orderBy: 'timestamp ASC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return SyncOperationModel.fromMap(maps.first);
  }
}
