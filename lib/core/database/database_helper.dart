import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// SQLite database helper for Task Master application
/// Manages database creation, migrations, and provides database instance
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance (singleton pattern)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_master.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final Directory dbPath = await getApplicationDocumentsDirectory();
    final String dbFilePath = path.join(dbPath.path, filePath);

    return await openDatabase(
      dbFilePath,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        due_date INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        created_by TEXT NOT NULL,
        assigned_to TEXT,
        tags TEXT,
        is_deleted INTEGER DEFAULT 0,
        version INTEGER DEFAULT 1,
        last_synced_at INTEGER,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Sync queue table
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0,
        payload TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks(id)
      )
    ''');

    // Conflicts table
    await db.execute('''
      CREATE TABLE conflicts (
        id TEXT PRIMARY KEY,
        task_id TEXT NOT NULL,
        local_version TEXT NOT NULL,
        server_version TEXT NOT NULL,
        detected_at INTEGER NOT NULL,
        resolved INTEGER DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks(id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_tasks_status ON tasks(status)');
    await db.execute('CREATE INDEX idx_tasks_priority ON tasks(priority)');
    await db.execute('CREATE INDEX idx_tasks_created_at ON tasks(created_at)');
    await db.execute('CREATE INDEX idx_tasks_due_date ON tasks(due_date)');
    await db.execute(
      'CREATE INDEX idx_tasks_sync_status ON tasks(sync_status)',
    );
    await db.execute(
      'CREATE INDEX idx_sync_queue_timestamp ON sync_queue(timestamp)',
    );
  }

  /// Handle database upgrades
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    if (oldVersion < newVersion) {
      // Add migration logic when schema changes
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Delete database (for testing purposes)
  Future<void> deleteDB() async {
    final Directory dbPath = await getApplicationDocumentsDirectory();
    final String dbFilePath = path.join(dbPath.path, 'task_master.db');
    await deleteDatabase(dbFilePath);
    _database = null;
  }
}
