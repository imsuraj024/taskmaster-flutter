import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/core/services/auth_service.dart';
import 'package:task_master/routes/app_routes.dart';

/// Login screen controller
class LoginController extends GetxController {
  final AuthService _authService;

  LoginController(this._authService);

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed(AppRoutes.taskList);
    } catch (e) {
      Get.snackbar('Login Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
}

/// Login screen
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController(Get.find<AuthService>()));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                Icon(
                  Icons.task_alt,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Task Master',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 48),

                // Email field
                TextField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Password field
                Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.login(),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
