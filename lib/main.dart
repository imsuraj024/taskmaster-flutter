import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/core/theme/app_theme.dart';
import 'package:task_master/core/utils/dependency_injection.dart';
import 'package:task_master/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await DependencyInjection.init();

  runApp(const TaskMasterApp());
}

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Task Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.taskList,
      getPages: AppRoutes.routes,
    );
  }
}
