import 'package:task_master/core/constants/enums.dart';

/// Task domain entity
class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final List<String> assignedTo;
  final List<String> tags;
  final bool isDeleted;
  final int version;
  final DateTime? lastSyncedAt;
  final SyncStatus syncStatus;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.assignedTo = const [],
    this.tags = const [],
    this.isDeleted = false,
    this.version = 1,
    this.lastSyncedAt,
    this.syncStatus = SyncStatus.pending,
  });

  /// Create a copy of Task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    List<String>? assignedTo,
    List<String>? tags,
    bool? isDeleted,
    int? version,
    DateTime? lastSyncedAt,
    SyncStatus? syncStatus,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task && other.id == id && other.version == version;
  }

  @override
  int get hashCode => id.hashCode ^ version.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status, priority: $priority)';
  }
}
