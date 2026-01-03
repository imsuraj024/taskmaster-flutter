import 'dart:convert';
import 'package:task_master/core/constants/enums.dart';
import 'package:task_master/domain/entities/task.dart';

/// Task data model for database and API serialization
class TaskModel extends Task {
  TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.status,
    required super.priority,
    super.dueDate,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    super.assignedTo,
    super.tags,
    super.isDeleted,
    super.version,
    super.lastSyncedAt,
    super.syncStatus,
  });

  /// Convert TaskModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toJson(),
      'priority': priority.toJson(),
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'tags': tags,
      'isDeleted': isDeleted,
      'version': version,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'syncStatus': syncStatus.toJson(),
    };
  }

  /// Create TaskModel from JSON
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.fromJson(json['status'] as String),
      priority: TaskPriority.fromJson(json['priority'] as String),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      assignedTo:
          (json['assignedTo'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      isDeleted: json['isDeleted'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      syncStatus: json['syncStatus'] != null
          ? SyncStatus.fromJson(json['syncStatus'] as String)
          : SyncStatus.pending,
    );
  }

  /// Convert TaskModel to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toJson(),
      'priority': priority.toJson(),
      'due_date': dueDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'created_by': createdBy,
      'assigned_to': jsonEncode(assignedTo),
      'tags': jsonEncode(tags),
      'is_deleted': isDeleted ? 1 : 0,
      'version': version,
      'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
      'sync_status': syncStatus.toJson(),
    };
  }

  /// Create TaskModel from SQLite Map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatus.fromJson(map['status'] as String),
      priority: TaskPriority.fromJson(map['priority'] as String),
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      createdBy: map['created_by'] as String,
      assignedTo: map['assigned_to'] != null
          ? List<String>.from(jsonDecode(map['assigned_to'] as String))
          : [],
      tags: map['tags'] != null
          ? List<String>.from(jsonDecode(map['tags'] as String))
          : [],
      isDeleted: (map['is_deleted'] as int) == 1,
      version: map['version'] as int? ?? 1,
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_synced_at'] as int)
          : null,
      syncStatus: SyncStatus.fromJson(map['sync_status'] as String),
    );
  }

  /// Convert Task entity to TaskModel
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      createdBy: task.createdBy,
      assignedTo: task.assignedTo,
      tags: task.tags,
      isDeleted: task.isDeleted,
      version: task.version,
      lastSyncedAt: task.lastSyncedAt,
      syncStatus: task.syncStatus,
    );
  }

  @override
  TaskModel copyWith({
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
    return TaskModel(
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
}
