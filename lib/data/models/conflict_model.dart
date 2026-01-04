import 'dart:convert';
import 'package:task_master/data/models/task_model.dart';

/// Conflict model for storing sync conflicts
class ConflictModel {
  final int? id;
  final String taskId;
  final TaskModel localVersion;
  final TaskModel serverVersion;
  final DateTime detectedAt;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? resolutionType; // 'local', 'server', 'merge'

  ConflictModel({
    this.id,
    required this.taskId,
    required this.localVersion,
    required this.serverVersion,
    required this.detectedAt,
    this.resolved = false,
    this.resolvedAt,
    this.resolutionType,
  });

  /// Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'local_version': jsonEncode(localVersion.toJson()),
      'server_version': jsonEncode(serverVersion.toJson()),
      'detected_at': detectedAt.millisecondsSinceEpoch,
      'resolved': resolved ? 1 : 0,
      'resolved_at': resolvedAt?.millisecondsSinceEpoch,
      'resolution_type': resolutionType,
    };
  }

  /// Create from SQLite Map
  factory ConflictModel.fromMap(Map<String, dynamic> map) {
    return ConflictModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as String,
      localVersion: TaskModel.fromJson(
        jsonDecode(map['local_version'] as String) as Map<String, dynamic>,
      ),
      serverVersion: TaskModel.fromJson(
        jsonDecode(map['server_version'] as String) as Map<String, dynamic>,
      ),
      detectedAt: DateTime.fromMillisecondsSinceEpoch(
        map['detected_at'] as int,
      ),
      resolved: (map['resolved'] as int) == 1,
      resolvedAt: map['resolved_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['resolved_at'] as int)
          : null,
      resolutionType: map['resolution_type'] as String?,
    );
  }

  /// Create a copy with updated fields
  ConflictModel copyWith({
    int? id,
    String? taskId,
    TaskModel? localVersion,
    TaskModel? serverVersion,
    DateTime? detectedAt,
    bool? resolved,
    DateTime? resolvedAt,
    String? resolutionType,
  }) {
    return ConflictModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      localVersion: localVersion ?? this.localVersion,
      serverVersion: serverVersion ?? this.serverVersion,
      detectedAt: detectedAt ?? this.detectedAt,
      resolved: resolved ?? this.resolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionType: resolutionType ?? this.resolutionType,
    );
  }

  @override
  String toString() {
    return 'Conflict(id: $id, taskId: $taskId, resolved: $resolved)';
  }
}
