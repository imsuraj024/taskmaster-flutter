import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/core/services/auth_service.dart';
import 'package:task_master/routes/app_routes.dart';

/// Settings screen controller
class SettingsController extends GetxController {
  final AuthService _authService;

  SettingsController(this._authService);

  final RxMap<String, dynamic> currentUser = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final user = await _authService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authService.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController(Get.find<AuthService>()));

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        if (controller.isLoading.value && controller.currentUser.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      _getInitials(controller.currentUser['name'] as String?),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.currentUser['name'] as String? ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.currentUser['email'] as String? ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Import/Export Section
            _SectionHeader(title: 'Data Management'),
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Import/Export Tasks'),
              subtitle: const Text('Backup and restore your tasks'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.toNamed(AppRoutes.importExport),
            ),

            const Divider(),

            // Account Section
            _SectionHeader(title: 'Account'),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[700]),
              title: Text('Logout', style: TextStyle(color: Colors.red[700])),
              onTap: () => _showLogoutDialog(context, controller),
            ),

            const Divider(),

            // App Info Section
            _SectionHeader(title: 'About'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Build'),
              subtitle: const Text('January 2026'),
            ),
          ],
        );
      }),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _showLogoutDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
