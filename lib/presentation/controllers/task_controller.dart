import 'package:get/get.dart';
import 'package:task_master/domain/entities/task.dart';
import 'package:task_master/domain/repositories/task_repository.dart';
import 'package:task_master/core/constants/enums.dart';
import 'package:uuid/uuid.dart';

/// GetX controller for task management
class TaskController extends GetxController {
  final TaskRepository _taskRepository;

  TaskController(this._taskRepository);

  // Observable state
  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString error = ''.obs;
  final RxInt totalTasks = 0.obs;
  final RxBool hasMore = true.obs;

  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;

  // Filters
  final Rx<TaskStatus?> selectedStatus = Rx<TaskStatus?>(null);
  final Rx<TaskPriority?> selectedPriority = Rx<TaskPriority?>(null);
  final RxList<String> selectedTags = <String>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'createdAt'.obs;
  final RxBool ascending = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  /// Load tasks with current filters
  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      tasks.clear();
      hasMore.value = true;
    }

    if (isLoading.value || !hasMore.value) return;

    try {
      isLoading.value = true;
      error.value = '';

      final loadedTasks = await _taskRepository.getTasks(
        offset: _currentPage * _pageSize,
        limit: _pageSize,
        status: selectedStatus.value,
        priority: selectedPriority.value,
        tags: selectedTags.isNotEmpty ? selectedTags : null,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        sortBy: sortBy.value,
        ascending: ascending.value,
      );

      if (loadedTasks.length < _pageSize) {
        hasMore.value = false;
      }

      if (refresh) {
        tasks.value = loadedTasks;
      } else {
        tasks.addAll(loadedTasks);
      }

      _currentPage++;

      // Update total count
      totalTasks.value = await _taskRepository.getTasksCount(
        status: selectedStatus.value,
      );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more tasks (pagination)
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      await loadTasks();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Create new task
  Future<void> createTask({
    required String title,
    String? description,
    required TaskStatus status,
    required TaskPriority priority,
    DateTime? dueDate,
    List<String>? assignedTo,
    List<String>? tags,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final now = DateTime.now();
      final task = Task(
        id: const Uuid().v4(),
        title: title,
        description: description,
        status: status,
        priority: priority,
        dueDate: dueDate,
        createdAt: now,
        updatedAt: now,
        createdBy: 'current_user', // TODO: Get from auth service
        assignedTo: assignedTo ?? [],
        tags: tags ?? [],
      );

      await _taskRepository.createTask(task);
      await loadTasks(refresh: true);

      Get.snackbar(
        'Success',
        'Task created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Update existing task
  Future<void> updateTask(Task task) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedTask = task.copyWith(
        updatedAt: DateTime.now(),
        version: task.version + 1,
      );

      await _taskRepository.updateTask(updatedTask);
      await loadTasks(refresh: true);

      Get.snackbar(
        'Success',
        'Task updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete task (soft delete)
  Future<void> deleteTask(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _taskRepository.deleteTask(id);
      tasks.removeWhere((task) => task.id == id);
      totalTasks.value--;

      Get.snackbar(
        'Success',
        'Task deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore deleted task
  Future<void> restoreTask(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _taskRepository.restoreTask(id);
      await loadTasks(refresh: true);

      Get.snackbar(
        'Success',
        'Task restored successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to restore task: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Search tasks
  Future<void> search(String query) async {
    searchQuery.value = query;
    await loadTasks(refresh: true);
  }

  /// Filter by status
  void filterByStatus(TaskStatus? status) {
    selectedStatus.value = status;
    loadTasks(refresh: true);
  }

  /// Filter by priority
  void filterByPriority(TaskPriority? priority) {
    selectedPriority.value = priority;
    loadTasks(refresh: true);
  }

  /// Filter by tags
  void filterByTags(List<String> tags) {
    selectedTags.value = tags;
    loadTasks(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    selectedStatus.value = null;
    selectedPriority.value = null;
    selectedTags.clear();
    searchQuery.value = '';
    loadTasks(refresh: true);
  }

  /// Change sort order
  void changeSortOrder(String field, bool asc) {
    sortBy.value = field;
    ascending.value = asc;
    loadTasks(refresh: true);
  }

  /// Bulk delete tasks
  Future<void> bulkDelete(List<String> taskIds) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _taskRepository.bulkDeleteTasks(taskIds);
      await loadTasks(refresh: true);

      Get.snackbar(
        'Success',
        '${taskIds.length} tasks deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to delete tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Bulk update tasks
  Future<void> bulkUpdate(List<Task> updatedTasks) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _taskRepository.bulkUpdateTasks(updatedTasks);
      await loadTasks(refresh: true);

      Get.snackbar(
        'Success',
        '${updatedTasks.length} tasks updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to update tasks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh tasks
  @override
  Future<void> refresh() async {
    await loadTasks(refresh: true);
  }
}
