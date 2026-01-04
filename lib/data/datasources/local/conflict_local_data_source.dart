import 'package:sqflite/sqflite.dart';
import 'package:task_master/core/database/database_helper.dart';
import 'package:task_master/data/models/conflict_model.dart';

/// Local data source for conflict operations
class ConflictLocalDataSource {
  final DatabaseHelper _dbHelper;

  ConflictLocalDataSource(this._dbHelper);

  /// Store a new conflict
  Future<int> storeConflict(ConflictModel conflict) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'conflicts',
      conflict.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all unresolved conflicts
  Future<List<ConflictModel>> getUnresolvedConflicts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conflicts',
      where: 'resolved = ?',
      whereArgs: [0],
      orderBy: 'detected_at DESC',
    );

    return maps.map((map) => ConflictModel.fromMap(map)).toList();
  }

  /// Get conflict by task ID
  Future<ConflictModel?> getConflictByTaskId(String taskId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conflicts',
      where: 'task_id = ? AND resolved = ?',
      whereArgs: [taskId, 0],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ConflictModel.fromMap(maps.first);
  }

  /// Mark conflict as resolved
  Future<void> markAsResolved({
    required int conflictId,
    required String resolutionType,
  }) async {
    final db = await _dbHelper.database;
    await db.update(
      'conflicts',
      {
        'resolved': 1,
        'resolved_at': DateTime.now().millisecondsSinceEpoch,
        'resolution_type': resolutionType,
      },
      where: 'id = ?',
      whereArgs: [conflictId],
    );
  }

  /// Get count of unresolved conflicts
  Future<int> getUnresolvedCount() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'conflicts',
      columns: ['COUNT(*) as count'],
      where: 'resolved = ?',
      whereArgs: [0],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Delete resolved conflicts older than specified days
  Future<void> cleanupOldConflicts({int daysOld = 30}) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now()
        .subtract(Duration(days: daysOld))
        .millisecondsSinceEpoch;

    await db.delete(
      'conflicts',
      where: 'resolved = ? AND resolved_at < ?',
      whereArgs: [1, cutoffDate],
    );
  }

  /// Delete all conflicts for a task
  Future<void> deleteConflictsForTask(String taskId) async {
    final db = await _dbHelper.database;
    await db.delete('conflicts', where: 'task_id = ?', whereArgs: [taskId]);
  }

  /// Get all conflicts (resolved and unresolved)
  Future<List<ConflictModel>> getAllConflicts() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conflicts',
      orderBy: 'detected_at DESC',
    );

    return maps.map((map) => ConflictModel.fromMap(map)).toList();
  }
}
