import 'dart:convert';
import 'package:task_master/core/constants/enums.dart';
import 'package:task_master/data/models/task_model.dart';

/// Sync operation model for tracking pending sync operations
class SyncOperationModel {
  final int? id;
  final String taskId;
  final SyncOperation operation;
  final DateTime timestamp;
  final int retryCount;
  final TaskModel? payload;

  SyncOperationModel({
    this.id,
    required this.taskId,
    required this.operation,
    required this.timestamp,
    this.retryCount = 0,
    this.payload,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'operation': operation.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'data': payload?.toJson(),
    };
  }

  /// Create from JSON
  factory SyncOperationModel.fromJson(Map<String, dynamic> json) {
    return SyncOperationModel(
      taskId: json['taskId'] as String,
      operation: SyncOperation.fromJson(json['operation'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      payload: json['data'] != null
          ? TaskModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'operation': operation.toJson(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'retry_count': retryCount,
      'payload': payload != null ? jsonEncode(payload!.toJson()) : null,
    };
  }

  /// Create from SQLite Map
  factory SyncOperationModel.fromMap(Map<String, dynamic> map) {
    return SyncOperationModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as String,
      operation: SyncOperation.fromJson(map['operation'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      retryCount: map['retry_count'] as int? ?? 0,
      payload: map['payload'] != null
          ? TaskModel.fromJson(
              jsonDecode(map['payload'] as String) as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Create a copy with updated fields
  SyncOperationModel copyWith({
    int? id,
    String? taskId,
    SyncOperation? operation,
    DateTime? timestamp,
    int? retryCount,
    TaskModel? payload,
  }) {
    return SyncOperationModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      operation: operation ?? this.operation,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      payload: payload ?? this.payload,
    );
  }

  @override
  String toString() {
    return 'SyncOperation(id: $id, taskId: $taskId, operation: $operation, retryCount: $retryCount)';
  }
}
