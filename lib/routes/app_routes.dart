import 'package:get/get.dart';
import 'package:task_master/presentation/screens/task_list_screen.dart';
import 'package:task_master/presentation/screens/task_detail_screen.dart';

/// App routes configuration
class AppRoutes {
  static const String taskList = '/';
  static const String taskDetail = '/task-detail';
  static const String createTask = '/create-task';

  static List<GetPage> routes = [
    GetPage(name: taskList, page: () => const TaskListScreen()),
    GetPage(name: taskDetail, page: () => const TaskDetailScreen()),
  ];
}
