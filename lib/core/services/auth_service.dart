import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

/// Authentication service for managing user authentication
class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _lastActivityKey = 'last_activity';

  String? _currentToken;
  Map<String, dynamic>? _currentUser;

  AuthService(this._dio);

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    // Check for auto-logout (30 days inactivity)
    final lastActivity = await _secureStorage.read(key: _lastActivityKey);
    if (lastActivity != null) {
      final lastDate = DateTime.parse(lastActivity);
      final daysSinceActivity = DateTime.now().difference(lastDate).inDays;
      if (daysSinceActivity > 30) {
        await logout();
        return false;
      }
    }

    return true;
  }

  /// Check if user is authenticated (synchronous using cached token)
  /// Used by middleware for route protection
  bool isAuthenticatedSync() {
    return _currentToken != null;
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    _currentToken = await _secureStorage.read(key: _tokenKey);
    return _currentToken;
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final userData = await _secureStorage.read(key: _userKey);
    if (userData != null) {
      _currentUser = jsonDecode(userData) as Map<String, dynamic>;
    }
    return _currentUser;
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      // Handle both Map and String responses
      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      await _saveAuthData(
        data['token'] as String,
        data['user'] as Map<String, dynamic>,
      );

      return data['user'] as Map<String, dynamic>;
    } catch (e) {
      print('❌ API Error - Registration Failed:');
      print('Email: $email');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      // Handle both Map and String responses
      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      await _saveAuthData(
        data['token'] as String,
        data['user'] as Map<String, dynamic>,
      );

      return data['user'] as Map<String, dynamic>;
    } catch (e) {
      print('❌ API Error - Login Failed:');
      print('Email: $email');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Refresh JWT token
  Future<String> refreshToken() async {
    try {
      final currentToken = await getToken();
      if (currentToken == null) {
        throw Exception('No token to refresh');
      }

      final response = await _dio.post(
        '/api/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $currentToken'}),
      );

      final newToken = response.data['token'] as String;
      await _secureStorage.write(key: _tokenKey, value: newToken);
      _currentToken = newToken;

      return newToken;
    } catch (e) {
      print('❌ API Error - Token Refresh Failed:');
      print('Error: $e');
      if (e is DioException) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    await _secureStorage.delete(key: _lastActivityKey);
    _currentToken = null;
    _currentUser = null;
  }

  /// Update last activity timestamp
  Future<void> updateActivity() async {
    await _secureStorage.write(
      key: _lastActivityKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Save authentication data
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userKey, value: jsonEncode(user));
    await updateActivity();

    _currentToken = token;
    _currentUser = user;
  }

  /// Configure Dio interceptor for automatic token injection
  void setupInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          await updateActivity();
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Auto-refresh token on 401
          if (error.response?.statusCode == 401) {
            try {
              await refreshToken();
              // Retry the request
              final opts = Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              );
              final response = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(response);
            } catch (e) {
              await logout();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
