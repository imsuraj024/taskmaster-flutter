import 'package:dio/dio.dart';
import 'package:task_master/data/models/task_model.dart';
import 'package:task_master/core/constants/enums.dart';

/// API service for task operations
class TaskApiService {
  final Dio _dio;

  TaskApiService(this._dio);

  /// Get all tasks from server
  Future<List<TaskModel>> getTasks({
    int offset = 0,
    int limit = 20,
    TaskStatus? status,
    TaskPriority? priority,
    String? searchQuery,
  }) async {
    try {
      final queryParams = <String, dynamic>{'offset': offset, 'limit': limit};

      if (status != null) {
        queryParams['status'] = status.name;
      }
      if (priority != null) {
        queryParams['priority'] = priority.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await _dio.get(
        '/api/tasks',
        queryParameters: queryParams,
      );

      final data = response.data as Map<String, dynamic>;
      final tasksJson = data['tasks'] as List;

      return tasksJson
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ API Error - Get Tasks Failed:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
      }
      throw Exception('Failed to get tasks: ${e.toString()}');
    }
  }

  /// Get single task by ID
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await _dio.get('/api/tasks/$id');
      final data = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } catch (e) {
      print('❌ API Error - Get Task By ID Failed:');
      print('Task ID: $id');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Failed to get task: ${e.toString()}');
    }
  }

  /// Create task on server
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _dio.post('/api/tasks', data: task.toJson());

      final data = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } catch (e) {
      print('❌ API Error - Create Task Failed:');
      print('Task: ${task.toJson()}');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  /// Update task on server
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await _dio.put(
        '/api/tasks/${task.id}',
        data: task.toJson(),
      );

      final data = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(data['task'] as Map<String, dynamic>);
    } catch (e) {
      print('❌ API Error - Update Task Failed:');
      print('Task ID: ${task.id}');
      print('Task Version: ${task.version}');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        if (e.response?.statusCode == 409) {
          print('⚠️ Version Conflict Detected');
          throw Exception('Version conflict: Task has been modified');
        }
      }
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  /// Delete task on server
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('/api/tasks/$id');
    } catch (e) {
      print('❌ API Error - Delete Task Failed:');
      print('Task ID: $id');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  /// Perform delta sync
  Future<Map<String, dynamic>> deltaSync({
    required List<Map<String, dynamic>> operations,
    String? lastSyncTime,
  }) async {
    try {
      final response = await _dio.post(
        '/api/sync/delta',
        data: {'operations': operations, 'lastSyncTime': lastSyncTime},
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ API Error - Delta Sync Failed:');
      print('Operations Count: ${operations.length}');
      print('Last Sync Time: $lastSyncTime');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request Data: ${e.requestOptions.data}');
      }
      throw Exception('Failed to sync: ${e.toString()}');
    }
  }

  /// Get updates since timestamp
  Future<List<TaskModel>> getUpdatesSince(String timestamp) async {
    try {
      final response = await _dio.get('/api/sync/since/$timestamp');
      final data = response.data as Map<String, dynamic>;
      final tasksJson = data['tasks'] as List;

      return tasksJson
          .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ API Error - Get Updates Since Failed:');
      print('Timestamp: $timestamp');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Failed to get updates: ${e.toString()}');
    }
  }
}
