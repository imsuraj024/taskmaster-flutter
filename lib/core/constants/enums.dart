/// Task status enumeration
enum TaskStatus {
  pending,
  inProgress,
  completed,
  archived;

  String toJson() => name;

  static TaskStatus fromJson(String json) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => TaskStatus.pending,
    );
  }

  @override
  String toString() {
    switch (this) {
      case TaskStatus.pending:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.archived:
        return 'Archived';
    }
  }
}

/// Task priority enumeration
enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String toJson() => name;

  static TaskPriority fromJson(String json) {
    return TaskPriority.values.firstWhere(
      (e) => e.name == json,
      orElse: () => TaskPriority.medium,
    );
  }

  @override
  String toString() {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Sync status enumeration
enum SyncStatus {
  synced,
  pending,
  conflict;

  String toJson() => name;

  static SyncStatus fromJson(String json) {
    return SyncStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SyncStatus.pending,
    );
  }

  @override
  String toString() {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.conflict:
        return 'Conflict';
    }
  }
}

/// Sync operation type enumeration
enum SyncOperation {
  create,
  update,
  delete;

  String toJson() => name.toUpperCase();

  static SyncOperation fromJson(String json) {
    return SyncOperation.values.firstWhere(
      (e) => e.name.toUpperCase() == json.toUpperCase(),
      orElse: () => SyncOperation.create,
    );
  }
}
