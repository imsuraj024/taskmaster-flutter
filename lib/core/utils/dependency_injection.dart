import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:task_master/core/database/database_helper.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:task_master/data/datasources/local/conflict_local_data_source.dart';
import 'package:task_master/data/repositories/task_repository_impl.dart';
import 'package:task_master/data/repositories/sync_repository.dart';
import 'package:task_master/data/repositories/conflict_repository.dart';
import 'package:task_master/domain/repositories/task_repository.dart';
import 'package:task_master/presentation/controllers/task_controller.dart';
import 'package:task_master/presentation/screens/conflict_resolution_screen.dart';
import 'package:task_master/core/services/connectivity_service.dart';
import 'package:task_master/core/services/auth_service.dart';
import 'package:task_master/core/services/import_export_service.dart';
import 'package:task_master/core/services/task_api_service.dart';

/// Dependency injection setup using GetX
class DependencyInjection {
  static Future<void> init() async {
    // Core
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper.instance, fenix: true);

    // Dio HTTP client
    // Note: Use 10.0.2.2 for Android emulator (maps to host's localhost)
    // Use localhost for iOS simulator or web
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8080',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 API Request: ${options.method} ${options.uri}');
          print('Headers: ${options.headers}');
          if (options.data != null) {
            print('Data: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ API Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          print('Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          print('Error Message: ${error.message}');
          print('Response Data: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );

    Get.put<Dio>(dio, permanent: true);

    // Services
    final connectivityService = ConnectivityService();
    connectivityService.initialize();
    Get.put<ConnectivityService>(connectivityService, permanent: true);

    final authService = AuthService(dio);
    authService.setupInterceptor();
    Get.put<AuthService>(authService, permanent: true);

    Get.lazyPut<ImportExportService>(
      () => ImportExportService(Get.find<TaskLocalDataSource>()),
      fenix: true,
    );

    // Data sources
    Get.lazyPut<TaskLocalDataSource>(
      () => TaskLocalDataSource(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    Get.lazyPut<SyncQueueLocalDataSource>(
      () => SyncQueueLocalDataSource(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    Get.lazyPut<ConflictLocalDataSource>(
      () => ConflictLocalDataSource(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<ConflictRepository>(
      () => ConflictRepository(
        Get.find<ConflictLocalDataSource>(),
        Get.find<TaskLocalDataSource>(),
      ),
      fenix: true,
    );

    // API Service
    final taskApiService = TaskApiService(dio);
    Get.put<TaskApiService>(taskApiService, permanent: true);

    Get.lazyPut<SyncRepository>(
      () => SyncRepository(
        Get.find<SyncQueueLocalDataSource>(),
        Get.find<TaskLocalDataSource>(),
        Get.find<ConnectivityService>(),
        Get.find<TaskApiService>(),
        conflictRepository: Get.find<ConflictRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(
        Get.find<TaskLocalDataSource>(),
        syncRepository: Get.find<SyncRepository>(),
      ),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<TaskController>(
      () => TaskController(Get.find<TaskRepository>()),
      fenix: true,
    );

    Get.lazyPut<ConflictController>(
      () => ConflictController(Get.find<ConflictRepository>()),
      fenix: true,
    );
  }
}
