import 'package:get/get.dart';
import 'package:task_master/core/database/database_helper.dart';
import 'package:task_master/data/datasources/local/task_local_data_source.dart';
import 'package:task_master/data/repositories/task_repository_impl.dart';
import 'package:task_master/domain/repositories/task_repository.dart';
import 'package:task_master/presentation/controllers/task_controller.dart';

/// Dependency injection setup using GetX
class DependencyInjection {
  static Future<void> init() async {
    // Core
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper.instance, fenix: true);

    // Data sources
    Get.lazyPut<TaskLocalDataSource>(
      () => TaskLocalDataSource(Get.find<DatabaseHelper>()),
      fenix: true,
    );

    // Repositories
    Get.lazyPut<TaskRepository>(
      () => TaskRepositoryImpl(Get.find<TaskLocalDataSource>()),
      fenix: true,
    );

    // Controllers
    Get.lazyPut<TaskController>(
      () => TaskController(Get.find<TaskRepository>()),
      fenix: true,
    );
  }
}
