import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:task_master/core/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@GenerateMocks([Dio, FlutterSecureStorage])
import 'auth_service_test.mocks.dart';

void main() {
  late AuthService authService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(mockDio);
  });

  group('AuthService', () {
    test('login should save token and user data on success', () async {
      // Arrange
      final responseData = {
        'token': 'test-token',
        'user': {'id': '1', 'email': 'test@example.com', 'name': 'Test User'},
      };

      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/auth/login'),
        ),
      );

      // Act
      final result = await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );

      // Assert
      expect(result, equals(responseData['user']));
      verify(
        mockDio.post(
          '/api/auth/login',
          data: {'email': 'test@example.com', 'password': 'password123'},
        ),
      ).called(1);
    });

    test('register should save token and user data on success', () async {
      // Arrange
      final responseData = {
        'token': 'test-token',
        'user': {'id': '1', 'email': 'new@example.com', 'name': 'New User'},
      };

      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/auth/register'),
        ),
      );

      // Act
      final result = await authService.register(
        email: 'new@example.com',
        password: 'password123',
        name: 'New User',
      );

      // Assert
      expect(result, equals(responseData['user']));
      verify(
        mockDio.post(
          '/api/auth/register',
          data: {
            'email': 'new@example.com',
            'password': 'password123',
            'name': 'New User',
          },
        ),
      ).called(1);
    });

    test('login should throw exception on failure', () async {
      // Arrange
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          error: 'Network error',
        ),
      );

      // Act & Assert
      expect(
        () => authService.login(
          email: 'test@example.com',
          password: 'wrong-password',
        ),
        throwsException,
      );
    });

    test('isAuthenticatedSync should return false when no token cached', () {
      // Act
      final result = authService.isAuthenticatedSync();

      // Assert
      expect(result, equals(false));
    });
  });
}
