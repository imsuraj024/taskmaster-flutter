import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/presentation/controllers/task_controller.dart';
import 'package:task_master/core/constants/enums.dart';
import 'package:task_master/core/theme/app_theme.dart';
import 'package:task_master/routes/app_routes.dart';
import 'package:task_master/domain/entities/task.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController controller = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty && controller.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.error.value}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first task',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tasks.length + 1,
            itemBuilder: (context, index) {
              if (index == controller.tasks.length) {
                if (controller.hasMore.value) {
                  controller.loadMore();
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final task = controller.tasks[index];
              return _TaskCard(
                task: task,
                onTap: () => Get.toNamed(AppRoutes.taskDetail, arguments: task),
                onDelete: () => _confirmDelete(context, controller, task.id),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTaskDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, TaskController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tasks'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter search query',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            controller.search(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.search('');
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, TaskController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: controller.selectedStatus.value == null,
                  onSelected: (_) => controller.filterByStatus(null),
                ),
                ...TaskStatus.values.map(
                  (status) => FilterChip(
                    label: Text(status.toString()),
                    selected: controller.selectedStatus.value == status,
                    onSelected: (_) => controller.filterByStatus(status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Priority'),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: controller.selectedPriority.value == null,
                  onSelected: (_) => controller.filterByPriority(null),
                ),
                ...TaskPriority.values.map(
                  (priority) => FilterChip(
                    label: Text(priority.toString()),
                    selected: controller.selectedPriority.value == priority,
                    onSelected: (_) => controller.filterByPriority(priority),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCreateTaskDialog(BuildContext context, TaskController controller) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskStatus selectedStatus = TaskStatus.pending;
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter task title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter task description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TaskStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskPriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedPriority = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  controller.createTask(
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    status: selectedStatus,
                    priority: selectedPriority,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TaskController controller,
    String taskId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteTask(taskId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

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
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: AppTheme.errorColor,
                  ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatusChip(status: task.status),
                  const SizedBox(width: 8),
                  _PriorityChip(priority: task.priority),
                  const Spacer(),
                  if (task.syncStatus == SyncStatus.pending)
                    const Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                  if (task.syncStatus == SyncStatus.synced)
                    const Icon(
                      Icons.cloud_done_outlined,
                      size: 16,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getStatusColor(status.toJson()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString(),
        style: TextStyle(
          color: AppTheme.getStatusColor(status.toJson()),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getPriorityColor(priority.toJson()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toString(),
        style: TextStyle(
          color: AppTheme.getPriorityColor(priority.toJson()),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
