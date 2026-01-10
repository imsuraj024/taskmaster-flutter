import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/domain/entities/task.dart';
import 'package:task_master/presentation/controllers/task_controller.dart';
import 'package:task_master/core/constants/enums.dart';
import 'package:task_master/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Task task = Get.arguments as Task;
    final TaskController controller = Get.find<TaskController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, controller, task),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              task.title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Status and Priority
            Row(
              children: [
                _StatusChip(status: task.status),
                const SizedBox(width: 8),
                _PriorityChip(priority: task.priority),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            if (task.description != null && task.description!.isNotEmpty) ...[
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],

            // Due Date
            if (task.dueDate != null) ...[
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Due Date',
                value: DateFormat('MMM dd, yyyy').format(task.dueDate!),
              ),
              const SizedBox(height: 12),
            ],

            // Created At
            _InfoRow(
              icon: Icons.access_time,
              label: 'Created',
              value: DateFormat('MMM dd, yyyy HH:mm').format(task.createdAt),
            ),
            const SizedBox(height: 12),

            // Updated At
            _InfoRow(
              icon: Icons.update,
              label: 'Updated',
              value: DateFormat('MMM dd, yyyy HH:mm').format(task.updatedAt),
            ),
            const SizedBox(height: 12),

            // Sync Status
            _InfoRow(
              icon: task.syncStatus == SyncStatus.synced
                  ? Icons.cloud_done
                  : Icons.cloud_upload,
              label: 'Sync Status',
              value: task.syncStatus.toString(),
              valueColor: task.syncStatus == SyncStatus.synced
                  ? Colors.green
                  : Colors.orange,
            ),
            const SizedBox(height: 12),

            // Version
            _InfoRow(
              icon: Icons.history,
              label: 'Version',
              value: task.version.toString(),
            ),

            // Tags
            if (task.tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Tags',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: task.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      ),
                    )
                    .toList(),
              ),
            ],

            // Assigned To
            if (task.assignedTo.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Assigned To',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...task.assignedTo.map(
                (userId) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(userId),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    TaskController controller,
    Task task,
  ) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(
      text: task.description ?? '',
    );
    TaskStatus selectedStatus = task.status;
    TaskPriority selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskStatus>(
                  initialValue: selectedStatus,
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
                  initialValue: selectedPriority,
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
                  final updatedTask = task.copyWith(
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    status: selectedStatus,
                    priority: selectedPriority,
                  );
                  controller.updateTask(updatedTask);
                  Navigator.pop(context);
                  Get.back();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getStatusColor(status.toJson()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toString(),
        style: TextStyle(
          color: AppTheme.getStatusColor(status.toJson()),
          fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getPriorityColor(priority.toJson()).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority.toString(),
        style: TextStyle(
          color: AppTheme.getPriorityColor(priority.toJson()),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
