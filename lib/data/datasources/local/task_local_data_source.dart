import 'package:sqflite/sqflite.dart';
import 'package:task_master/core/database/database_helper.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/core/constants/enums.dart';

/// Local data source for task operations using SQLite
class TaskLocalDataSource {
  final DatabaseHelper _dbHelper;

  TaskLocalDataSource(this._dbHelper);

  /// Insert task into database
  Future<void> insertTask(TaskModel task) async {
    final db = await _dbHelper.database;
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return TaskModel.fromMap(maps.first);
  }

  /// Get all tasks with filters and pagination
  Future<List<TaskModel>> getTasks({
    int offset = 0,
    int limit = 20,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
    bool includeDeleted = false,
  }) async {
    final db = await _dbHelper.database;

    // Build WHERE clause
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (!includeDeleted) {
      whereConditions.add('is_deleted = ?');
      whereArgs.add(0);
    }

    if (status != null) {
      whereConditions.add('status = ?');
      whereArgs.add(status.toJson());
    }

    if (priority != null) {
      whereConditions.add('priority = ?');
      whereArgs.add(priority.toJson());
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereConditions.add('(title LIKE ? OR description LIKE ?)');
      whereArgs.add('%$searchQuery%');
      whereArgs.add('%$searchQuery%');
    }

    // Build ORDER BY clause
    String orderBy = 'created_at DESC';
    if (sortBy != null) {
      final direction = ascending ? 'ASC' : 'DESC';
      switch (sortBy) {
        case 'title':
          orderBy = 'title $direction';
          break;
        case 'dueDate':
          orderBy = 'due_date $direction';
          break;
        case 'priority':
          orderBy = 'priority $direction';
          break;
        case 'createdAt':
          orderBy = 'created_at $direction';
          break;
        case 'updatedAt':
          orderBy = 'updated_at $direction';
          break;
      }
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  /// Update task
  Future<void> updateTask(TaskModel task) async {
    final db = await _dbHelper.database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Soft delete task
  Future<void> deleteTask(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'tasks',
      {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Restore deleted task
  Future<void> restoreTask(String id) async {
    final db = await _dbHelper.database;
    await db.update(
      'tasks',
      {'is_deleted': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Permanently delete task
  Future<void> permanentlyDeleteTask(String id) async {
    final db = await _dbHelper.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Get tasks count
  Future<int> getTasksCount({
    TaskStatus? status,
    bool includeDeleted = false,
  }) async {
    final db = await _dbHelper.database;

    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (!includeDeleted) {
      whereConditions.add('is_deleted = ?');
      whereArgs.add(0);
    }

    if (status != null) {
      whereConditions.add('status = ?');
      whereArgs.add(status.toJson());
    }

    final result = await db.query(
      'tasks',
      columns: ['COUNT(*) as count'],
      where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Search tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: '(title LIKE ? OR description LIKE ?) AND is_deleted = ?',
      whereArgs: ['%$query%', '%$query%', 0],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TaskModel.fromMap(map)).toList();
  }

  /// Bulk delete tasks
  Future<void> bulkDeleteTasks(List<String> taskIds) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final id in taskIds) {
      batch.update(
        'tasks',
        {'is_deleted': 1, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Bulk update tasks
  Future<void> bulkUpdateTasks(List<TaskModel> tasks) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (final task in tasks) {
      batch.update(
        'tasks',
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get tasks by tags (contains any of the provided tags)
  Future<List<TaskModel>> getTasksByTags(List<String> tags) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'is_deleted = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );

    // Filter tasks that contain any of the specified tags
    final tasks = maps.map((map) => TaskModel.fromMap(map)).toList();
    return tasks.where((task) {
      return task.tags.any((tag) => tags.contains(tag));
    }).toList();
  }
}
