import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_master/presentation/controllers/import_export_controller.dart';
import 'package:task_master/core/services/import_export_service.dart';

/// Import/Export screen
class ImportExportScreen extends StatelessWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      ImportExportController(Get.find<ImportExportService>()),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Import/Export')),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Export Section
            _SectionHeader(title: 'Export Tasks'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Export all your tasks to a file for backup or transfer.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.isExporting.value
                          ? null
                          : () async {
                              final path = await controller.exportToJson();
                              if (path != null) {
                                _showExportSuccessDialog(context, path);
                              }
                            },
                      icon: controller.isExporting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download),
                      label: const Text('Export to JSON'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: controller.isExporting.value
                          ? null
                          : () async {
                              final path = await controller.exportToCsv();
                              if (path != null) {
                                _showExportSuccessDialog(context, path);
                              }
                            },
                      icon: controller.isExporting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.table_chart),
                      label: const Text('Export to CSV'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Import Section
            _SectionHeader(title: 'Import Tasks'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Import tasks from a previously exported file.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: controller.isImporting.value
                          ? null
                          : () =>
                                _showImportDialog(context, controller, 'json'),
                      icon: controller.isImporting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_upload),
                      label: const Text('Import from JSON'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: controller.isImporting.value
                          ? null
                          : () => _showImportDialog(context, controller, 'csv'),
                      icon: controller.isImporting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.table_chart),
                      label: const Text('Import from CSV'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info Section
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Exported files are saved to your device\'s documents folder\n'
                      '• JSON format preserves all task data\n'
                      '• CSV format is compatible with spreadsheet apps\n'
                      '• Importing will add tasks to your existing data',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showExportSuccessDialog(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File saved to:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                filePath,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(
    BuildContext context,
    ImportExportController controller,
    String format,
  ) {
    final pathController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Import from ${format.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the full path to the file you want to import:'),
            const SizedBox(height: 16),
            TextField(
              controller: pathController,
              decoration: InputDecoration(
                labelText: 'File Path',
                hintText: '/path/to/file.$format',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final path = pathController.text.trim();
              if (path.isNotEmpty) {
                Navigator.pop(context);
                if (format == 'json') {
                  controller.importFromJson(path);
                } else {
                  controller.importFromCsv(path);
                }
              }
            },
            child: const Text('Import'),
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
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
