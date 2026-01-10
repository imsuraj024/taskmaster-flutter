import 'package:get/get.dart';
import 'package:task_master/core/services/import_export_service.dart';
import 'package:task_master/data/models/task_model.dart';

/// Controller for import/export functionality
class ImportExportController extends GetxController {
  final ImportExportService _importExportService;

  ImportExportController(this._importExportService);

  final RxBool isExporting = false.obs;
  final RxBool isImporting = false.obs;
  final RxString lastExportPath = ''.obs;
  final RxList<TaskModel> importPreview = <TaskModel>[].obs;
  final RxString importError = ''.obs;

  /// Export tasks to JSON
  Future<String?> exportToJson() async {
    try {
      isExporting.value = true;
      final filePath = await _importExportService.exportToJson();
      lastExportPath.value = filePath;

      Get.snackbar(
        'Success',
        'Tasks exported to JSON successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return filePath;
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isExporting.value = false;
    }
  }

  /// Export tasks to CSV
  Future<String?> exportToCsv() async {
    try {
      isExporting.value = true;
      final filePath = await _importExportService.exportToCsv();
      lastExportPath.value = filePath;

      Get.snackbar(
        'Success',
        'Tasks exported to CSV successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return filePath;
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isExporting.value = false;
    }
  }

  /// Import tasks from JSON file
  Future<void> importFromJson(String filePath) async {
    try {
      isImporting.value = true;
      importError.value = '';

      final count = await _importExportService.importFromJson(filePath);

      Get.snackbar(
        'Success',
        'Imported $count tasks successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      importPreview.clear();
    } catch (e) {
      importError.value = e.toString();
      Get.snackbar(
        'Import Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isImporting.value = false;
    }
  }

  /// Import tasks from CSV file
  Future<void> importFromCsv(String filePath) async {
    try {
      isImporting.value = true;
      importError.value = '';

      final count = await _importExportService.importFromCsv(filePath);

      Get.snackbar(
        'Success',
        'Imported $count tasks successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      importPreview.clear();
    } catch (e) {
      importError.value = e.toString();
      Get.snackbar(
        'Import Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isImporting.value = false;
    }
  }

  /// Clear import preview
  void clearImportPreview() {
    importPreview.clear();
    importError.value = '';
  }
}
