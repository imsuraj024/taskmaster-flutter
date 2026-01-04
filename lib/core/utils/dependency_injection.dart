import 'package:get/get.dart';
import 'package:task_master/core/database/database_helper.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/datasources/local/sync_queue_local_data_source.dart';
import 'package:task_master/data/repositories/task_repository_impl.dart';
import 'package:task_master/data/repositories/sync_repository.dart';
import 'package:task_master/domain/repositories/task_repository.dart';
import 'package:task_master/presentation/controllers/task_controller.dart';
import 'package:task_master/core/services/connectivity_service.dart';

/// Dependency injection setup using GetX
class DependencyInjection {
  static Future<void> init() async {
    // Core
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper.instance, fenix: true);

    // Services
    final connectivityService = ConnectivityService();
    connectivityService.initialize();
    Get.put<ConnectivityService>(connectivityService, permanent: true);

    // Data sources
    Get.lazyPut<TaskLocalDataSource>(
      () => TaskLocalDataSource(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    Get.lazyPut<SyncQueueLocalDataSource>(
      () => SyncQueueLocalDataSource(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<SyncRepository>(
      () => SyncRepository(
        Get.find<SyncQueueLocalDataSource>(),
        Get.find<TaskLocalDataSource>(),
        Get.find<ConnectivityService>(),
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
  }
}
