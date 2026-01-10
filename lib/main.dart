import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/core/theme/app_theme.dart';
import 'package:task_master/core/utils/dependency_injection.dart';
import 'package:task_master/core/services/auth_service.dart';
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
    return FutureBuilder<bool>(
      future: Get.find<AuthService>().isAuthenticated(),
      builder: (context, snapshot) {
        // Show loading while checking auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
            ),
          );
        }

        // Determine initial route based on auth status
        final isAuthenticated = snapshot.data ?? false;
        final initialRoute = isAuthenticated
            ? AppRoutes.taskList
            : AppRoutes.login;

        return GetMaterialApp(
          title: 'Task Master',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          initialRoute: initialRoute,
          getPages: AppRoutes.routes,
        );
      },
    );
  }
}
