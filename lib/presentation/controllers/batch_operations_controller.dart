import 'package:get/get.dart';
import 'package:task_master/domain/entities/task.dart';
import 'package:task_master/presentation/controllers/task_controller.dart';
import 'package:task_master/core/constants/enums.dart';

/// Controller for batch operations on tasks
class BatchOperationsController extends GetxController {
  final TaskController _taskController;

  BatchOperationsController(this._taskController);

  final RxBool isSelectionMode = false.obs;
  final RxSet<String> selectedTaskIds = <String>{}.obs;
  final RxBool isProcessing = false.obs;

  /// Toggle selection mode
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedTaskIds.clear();
    }
  }

  /// Toggle task selection
  void toggleTaskSelection(String taskId) {
    if (selectedTaskIds.contains(taskId)) {
      selectedTaskIds.remove(taskId);
    } else {
      selectedTaskIds.add(taskId);
    }
  }

  /// Select all tasks
  void selectAll() {
    selectedTaskIds.clear();
    selectedTaskIds.addAll(_taskController.tasks.map((task) => task.id));
  }

  /// Deselect all tasks
  void deselectAll() {
    selectedTaskIds.clear();
  }

  /// Check if task is selected
  bool isTaskSelected(String taskId) {
    return selectedTaskIds.contains(taskId);
  }

  /// Get selected tasks
  List<Task> getSelectedTasks() {
    return _taskController.tasks
        .where((task) => selectedTaskIds.contains(task.id))
        .toList();
  }

  /// Bulk delete selected tasks
  Future<void> bulkDelete() async {
    if (selectedTaskIds.isEmpty) return;

    try {
      isProcessing.value = true;
      await _taskController.bulkDelete(selectedTaskIds.toList());
      selectedTaskIds.clear();
      isSelectionMode.value = false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Bulk update status
  Future<void> bulkUpdateStatus(TaskStatus status) async {
    if (selectedTaskIds.isEmpty) return;

    try {
      isProcessing.value = true;
      final selectedTasks = getSelectedTasks();
      final updatedTasks = selectedTasks
          .map(
            (task) => task.copyWith(
              status: status,
              updatedAt: DateTime.now(),
              version: task.version + 1,
            ),
          )
          .toList();

      await _taskController.bulkUpdate(updatedTasks);
      selectedTaskIds.clear();
      isSelectionMode.value = false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Bulk update priority
  Future<void> bulkUpdatePriority(TaskPriority priority) async {
    if (selectedTaskIds.isEmpty) return;

    try {
      isProcessing.value = true;
      final selectedTasks = getSelectedTasks();
      final updatedTasks = selectedTasks
          .map(
            (task) => task.copyWith(
              priority: priority,
              updatedAt: DateTime.now(),
              version: task.version + 1,
            ),
          )
          .toList();

      await _taskController.bulkUpdate(updatedTasks);
      selectedTaskIds.clear();
      isSelectionMode.value = false;
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    selectedTaskIds.clear();
    super.onClose();
  }
}
