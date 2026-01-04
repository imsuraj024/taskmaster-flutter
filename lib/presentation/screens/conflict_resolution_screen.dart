import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/data/models/conflict_model.dart';
import 'package:task_master/data/repositories/conflict_repository.dart';
import 'package:task_master/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

/// Controller for managing conflicts
class ConflictController extends GetxController {
  final ConflictRepository _conflictRepository;

  ConflictController(this._conflictRepository);

  final RxList<ConflictModel> conflicts = <ConflictModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadConflicts();
  }

  /// Load all unresolved conflicts
  Future<void> loadConflicts() async {
    try {
      isLoading.value = true;
      error.value = '';
      conflicts.value = await _conflictRepository.getUnresolvedConflicts();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Resolve conflict with local version
  Future<void> resolveWithLocal(ConflictModel conflict) async {
    try {
      isLoading.value = true;
      await _conflictRepository.resolveWithLocal(conflict);
      await loadConflicts();
      Get.back();
      Get.snackbar(
        'Resolved',
        'Conflict resolved with local version',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to resolve conflict: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resolve conflict with server version
  Future<void> resolveWithServer(ConflictModel conflict) async {
    try {
      isLoading.value = true;
      await _conflictRepository.resolveWithServer(conflict);
      await loadConflicts();
      Get.back();
      Get.snackbar(
        'Resolved',
        'Conflict resolved with server version',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to resolve conflict: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get unresolved count
  Future<int> getUnresolvedCount() async {
    return await _conflictRepository.getUnresolvedCount();
  }
}

/// Conflict list screen
class ConflictListScreen extends StatelessWidget {
  const ConflictListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ConflictController controller = Get.find<ConflictController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Conflicts')),
      body: Obx(() {
        if (controller.isLoading.value && controller.conflicts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.conflicts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Conflicts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'All tasks are in sync',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.conflicts.length,
          itemBuilder: (context, index) {
            final conflict = controller.conflicts[index];
            return _ConflictCard(
              conflict: conflict,
              onTap: () =>
                  Get.to(() => ConflictResolutionScreen(conflict: conflict)),
            );
          },
        );
      }),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final ConflictModel conflict;
  final VoidCallback onTap;

  const _ConflictCard({required this.conflict, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      conflict.localVersion.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Detected: ${DateFormat('MMM dd, yyyy HH:mm').format(conflict.detectedAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'This task was modified both locally and on the server',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Conflict resolution screen with side-by-side comparison
class ConflictResolutionScreen extends StatelessWidget {
  final ConflictModel conflict;

  const ConflictResolutionScreen({super.key, required this.conflict});

  @override
  Widget build(BuildContext context) {
    final ConflictController controller = Get.find<ConflictController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Resolve Conflict')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warningColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.warningColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This task was modified in two places. Choose which version to keep.',
                      style: TextStyle(color: AppTheme.warningColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Side-by-side comparison
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Local version
                Expanded(
                  child: _VersionCard(
                    title: 'Your Version',
                    task: conflict.localVersion,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                // Server version
                Expanded(
                  child: _VersionCard(
                    title: 'Server Version',
                    task: conflict.serverVersion,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Resolution actions
            Text(
              'Choose Resolution',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Keep Local button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.resolveWithLocal(conflict),
                icon: const Icon(Icons.phone_android),
                label: const Text('Keep Your Version'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Keep Server button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => controller.resolveWithServer(conflict),
                icon: const Icon(Icons.cloud),
                label: const Text('Keep Server Version'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final String title;
  final dynamic task;
  final Color color;

  const _VersionCard({
    required this.title,
    required this.task,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          _buildField('Title', task.title),
          _buildField('Description', task.description ?? 'None'),
          _buildField('Status', task.status.toString()),
          _buildField('Priority', task.priority.toString()),
          if (task.dueDate != null)
            _buildField(
              'Due Date',
              DateFormat('MMM dd, yyyy').format(task.dueDate!),
            ),
          _buildField(
            'Updated',
            DateFormat('MMM dd, HH:mm').format(task.updatedAt),
          ),
          _buildField('Version', task.version.toString()),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
