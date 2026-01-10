import 'package:get/get.dart';
import 'package:task_master/presentation/screens/task_list_screen.dart';
import 'package:task_master/presentation/screens/task_detail_screen.dart';
import 'package:task_master/presentation/screens/conflict_resolution_screen.dart';
import 'package:task_master/presentation/screens/auth/login_screen.dart';
import 'package:task_master/presentation/screens/auth/register_screen.dart';
import 'package:task_master/presentation/screens/settings_screen.dart';
import 'package:task_master/presentation/screens/import_export_screen.dart';
import 'package:task_master/core/middleware/auth_middleware.dart';

/// App routes configuration
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String taskList = '/';
  static const String taskDetail = '/task-detail';
  static const String createTask = '/create-task';
  static const String conflicts = '/conflicts';
  static const String settings = '/settings';
  static const String importExport = '/import-export';
  static const String advancedSearch = '/advanced-search';

  static List<GetPage> routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(
      name: taskList,
      page: () => const TaskListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: taskDetail,
      page: () => const TaskDetailScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: conflicts,
      page: () => const ConflictListScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: importExport,
      page: () => const ImportExportScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
