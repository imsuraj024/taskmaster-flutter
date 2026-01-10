import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/core/services/auth_service.dart';
import 'package:task_master/routes/app_routes.dart';

/// Register screen controller
class RegisterController extends GetxController {
  final AuthService _authService;

  RegisterController(this._authService);

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    // Validation
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;
      await _authService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        name: nameController.text.trim(),
      );
      Get.offAllNamed(AppRoutes.taskList);
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }
}

/// Register screen
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController(Get.find<AuthService>()));

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name field
                TextField(
                  controller: controller.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

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
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm password field
                Obx(
                  () => TextField(
                    controller: controller.confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscureConfirmPassword.value
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: controller.toggleConfirmPasswordVisibility,
                      ),
                    ),
                    obscureText: controller.obscureConfirmPassword.value,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => controller.register(),
                  ),
                ),
                const SizedBox(height: 24),

                // Register button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Sign In'),
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
