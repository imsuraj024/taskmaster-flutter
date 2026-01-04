import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

// In-memory data storage
final Map<String, dynamic> users = {};
final Map<String, dynamic> tasks = {};
const String jwtSecret = 'task_master_secret_key_2024';
const uuid = Uuid();

void main() async {
  final router = Router();

  // CORS middleware
  final handler = Pipeline()
      .addMiddleware(_corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  // Auth endpoints
  router.post('/api/auth/register', _registerHandler);
  router.post('/api/auth/login', _loginHandler);
  router.post('/api/auth/refresh', _refreshTokenHandler);

  // Task endpoints
  router.get('/api/tasks', _getTasksHandler);
  router.get('/api/tasks/<id>', _getTaskHandler);
  router.post('/api/tasks', _createTaskHandler);
  router.put('/api/tasks/<id>', _updateTaskHandler);
  router.delete('/api/tasks/<id>', _deleteTaskHandler);

  // Sync endpoint
  router.post('/api/sync/delta', _deltaSyncHandler);
  router.get('/api/sync/since/<timestamp>', _getSinceHandler);

  // Health check
  router.get('/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  });

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  print(
    'Mock API Server running on http://${server.address.host}:${server.port}',
  );
}

// CORS middleware
Middleware _corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _getCorsHeaders());
      }

      final response = await handler(request);
      return response.change(headers: _getCorsHeaders());
    };
  };
}

Map<String, String> _getCorsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };
}

// Auth handlers
Future<Response> _registerHandler(Request request) async {
  try {
    final body = jsonDecode(await request.readAsString());
    final email = body['email'] as String;
    final password = body['password'] as String;
    final name = body['name'] as String?;

    if (users.containsKey(email)) {
      return Response(409, body: jsonEncode({'error': 'User already exists'}));
    }

    final userId = uuid.v4();
    users[email] = {
      'id': userId,
      'email': email,
      'password': password, // In production, hash this!
      'name': name ?? email.split('@')[0],
      'createdAt': DateTime.now().toIso8601String(),
    };

    final token = _generateToken(userId, email);
    return Response.ok(
      jsonEncode({
        'user': {'id': userId, 'email': email, 'name': users[email]!['name']},
        'token': token,
      }),
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _loginHandler(Request request) async {
  try {
    final body = jsonDecode(await request.readAsString());
    final email = body['email'] as String;
    final password = body['password'] as String;

    if (!users.containsKey(email) || users[email]!['password'] != password) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    final user = users[email]!;
    final token = _generateToken(user['id'], email);

    return Response.ok(
      jsonEncode({
        'user': {'id': user['id'], 'email': email, 'name': user['name']},
        'token': token,
      }),
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _refreshTokenHandler(Request request) async {
  try {
    final authHeader = request.headers['authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response(401, body: jsonEncode({'error': 'No token provided'}));
    }

    final token = authHeader.substring(7);
    final jwt = JWT.verify(token, SecretKey(jwtSecret));
    final payload = jwt.payload as Map<String, dynamic>;

    final newToken = _generateToken(payload['userId'], payload['email']);
    return Response.ok(jsonEncode({'token': newToken}));
  } catch (e) {
    return Response(401, body: jsonEncode({'error': 'Invalid token'}));
  }
}

// Task handlers
Future<Response> _getTasksHandler(Request request) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    final userTasks = tasks.values
        .where((task) => task['createdBy'] == userId)
        .toList();
    return Response.ok(jsonEncode({'tasks': userTasks}));
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _getTaskHandler(Request request, String id) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    if (!tasks.containsKey(id)) {
      return Response.notFound(jsonEncode({'error': 'Task not found'}));
    }

    final task = tasks[id]!;
    if (task['createdBy'] != userId) {
      return Response(403, body: jsonEncode({'error': 'Forbidden'}));
    }

    return Response.ok(jsonEncode({'task': task}));
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _createTaskHandler(Request request) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    final body = jsonDecode(await request.readAsString());
    final taskId = body['id'] ?? uuid.v4();
    final now = DateTime.now().toIso8601String();

    tasks[taskId] = {
      ...body,
      'id': taskId,
      'createdBy': userId,
      'createdAt': body['createdAt'] ?? now,
      'updatedAt': now,
      'version': 1,
      'syncStatus': 'synced',
      'lastSyncedAt': now,
    };

    return Response.ok(jsonEncode({'task': tasks[taskId]}));
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _updateTaskHandler(Request request, String id) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    if (!tasks.containsKey(id)) {
      return Response.notFound(jsonEncode({'error': 'Task not found'}));
    }

    final task = tasks[id]!;
    if (task['createdBy'] != userId) {
      return Response(403, body: jsonEncode({'error': 'Forbidden'}));
    }

    final body = jsonDecode(await request.readAsString());
    final now = DateTime.now().toIso8601String();

    tasks[id] = {
      ...task,
      ...body,
      'id': id,
      'updatedAt': now,
      'version': (task['version'] ?? 1) + 1,
      'lastSyncedAt': now,
    };

    return Response.ok(jsonEncode({'task': tasks[id]}));
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _deleteTaskHandler(Request request, String id) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    if (!tasks.containsKey(id)) {
      return Response.notFound(jsonEncode({'error': 'Task not found'}));
    }

    final task = tasks[id]!;
    if (task['createdBy'] != userId) {
      return Response(403, body: jsonEncode({'error': 'Forbidden'}));
    }

    tasks.remove(id);
    return Response.ok(jsonEncode({'message': 'Task deleted successfully'}));
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

// Sync handlers
Future<Response> _deltaSyncHandler(Request request) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    final body = jsonDecode(await request.readAsString());
    final operations = body['operations'] as List;
    final lastSyncTime = body['lastSyncTime'] as String?;

    final syncedIds = <String>[];
    final conflicts = <Map<String, dynamic>>[];

    // Process operations
    for (final op in operations) {
      final taskId = op['taskId'] as String;
      final operation = op['operation'] as String;
      final data = op['data'] as Map<String, dynamic>?;

      if (operation == 'CREATE' && data != null) {
        tasks[taskId] = {
          ...data,
          'id': taskId,
          'createdBy': userId,
          'version': 1,
          'syncStatus': 'synced',
          'lastSyncedAt': DateTime.now().toIso8601String(),
        };
        syncedIds.add(taskId);
      } else if (operation == 'UPDATE' && data != null) {
        if (tasks.containsKey(taskId)) {
          final serverTask = tasks[taskId]!;
          final clientVersion = data['version'] ?? 1;
          final serverVersion = serverTask['version'] ?? 1;

          // Detect conflict
          if (clientVersion < serverVersion) {
            conflicts.add({
              'taskId': taskId,
              'localVersion': data,
              'serverVersion': serverTask,
            });
          } else {
            tasks[taskId] = {
              ...serverTask,
              ...data,
              'version': serverVersion + 1,
              'lastSyncedAt': DateTime.now().toIso8601String(),
            };
            syncedIds.add(taskId);
          }
        } else {
          // Task doesn't exist on server, treat as create
          tasks[taskId] = {
            ...data,
            'createdBy': userId,
            'version': 1,
            'lastSyncedAt': DateTime.now().toIso8601String(),
          };
          syncedIds.add(taskId);
        }
      } else if (operation == 'DELETE') {
        tasks.remove(taskId);
        syncedIds.add(taskId);
      }
    }

    // Get server updates since last sync
    final serverUpdates = <Map<String, dynamic>>[];
    if (lastSyncTime != null) {
      final lastSync = DateTime.parse(lastSyncTime);
      for (final task in tasks.values) {
        if (task['createdBy'] == userId) {
          final updatedAt = DateTime.parse(task['updatedAt'] as String);
          if (updatedAt.isAfter(lastSync)) {
            serverUpdates.add(task);
          }
        }
      }
    }

    return Response.ok(
      jsonEncode({
        'syncedTaskIds': syncedIds,
        'conflicts': conflicts,
        'serverUpdates': serverUpdates,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

Future<Response> _getSinceHandler(Request request, String timestamp) async {
  try {
    final userId = await _getUserIdFromRequest(request);
    if (userId == null) {
      return Response(401, body: jsonEncode({'error': 'Unauthorized'}));
    }

    final since = DateTime.parse(timestamp);
    final updates = tasks.values.where((task) {
      if (task['createdBy'] != userId) return false;
      final updatedAt = DateTime.parse(task['updatedAt'] as String);
      return updatedAt.isAfter(since);
    }).toList();

    return Response.ok(jsonEncode({'tasks': updates}));
  } catch (e) {
    return Response.internalServerError(
      body: jsonEncode({'error': e.toString()}),
    );
  }
}

// Helper functions
String _generateToken(String userId, String email) {
  final jwt = JWT({
    'userId': userId,
    'email': email,
    'iat': DateTime.now().millisecondsSinceEpoch,
    'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch,
  });

  return jwt.sign(SecretKey(jwtSecret));
}

Future<String?> _getUserIdFromRequest(Request request) async {
  try {
    final authHeader = request.headers['authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    final token = authHeader.substring(7);
    final jwt = JWT.verify(token, SecretKey(jwtSecret));
    final payload = jwt.payload as Map<String, dynamic>;

    return payload['userId'] as String?;
  } catch (e) {
    return null;
  }
}
