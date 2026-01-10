import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/core/services/auth_service.dart';
import 'package:task_master/routes/app_routes.dart';

/// Middleware to protect routes that require authentication
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Check if user is authenticated synchronously using cached token
    final isAuthenticated = authService.isAuthenticatedSync();

    // If not authenticated and trying to access protected route, redirect to login
    if (!isAuthenticated &&
        route != AppRoutes.login &&
        route != AppRoutes.register) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // If authenticated and trying to access login/register, redirect to task list
    if (isAuthenticated &&
        (route == AppRoutes.login || route == AppRoutes.register)) {
      return const RouteSettings(name: AppRoutes.taskList);
    }

    return null;
  }
}
