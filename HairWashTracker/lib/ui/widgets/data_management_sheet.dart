import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
import 'app_snack_bar.dart';
import 'confirmation_dialog.dart';

/// Modal bottom sheet for local data backup, restore, and wipe operations.
class DataManagementSheet extends StatelessWidget {
  const DataManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    Haptics.lightHaptic();
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusDialog)),
      ),
      builder: (_) => const DataManagementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = Provider.of<AppController>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                strings.tr('dataTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.file_download_outlined, color: colorScheme.primary),
              title: Text(strings.tr('dataExport')),
              subtitle: Text(strings.tr('dataExportDesc')),
              onTap: () => _handleExport(context),
            ),
            ListTile(
              leading: Icon(Icons.file_upload_outlined, color: colorScheme.primary),
              title: Text(strings.tr('dataImport')),
              subtitle: Text(strings.tr('dataImportDesc')),
              onTap: () => _handleImport(context),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Divider(),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
              title: Text(
                strings.tr('dataClearAll'),
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(strings.tr('dataClearDesc')),
              onTap: () => _handleClearData(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImport(BuildContext context) async {
    final controller = context.read<AppController>();
    // The sheet closes immediately, so its context is unmounted before the
    // async work finishes; messenger must be captured first or the
    // confirmation snackbar would be silently dropped.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    try {
      final imported = await controller.importData();
      // Dismissing the picker is not an import: report nothing.
      if (!imported) return;
      Haptics.successHaptic();
      showAppSnackBar(messenger, controller.tr('msgImported'));
    } catch (e) {
      Haptics.errorHaptic();
      showAppSnackBar(messenger, 'Error importing data: $e', isError: true);
    }
  }

  Future<void> _handleExport(BuildContext context) async {
    final controller = context.read<AppController>();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    try {
      await controller.exportData();
      Haptics.successHaptic();
      showAppSnackBar(messenger, controller.tr('msgExported'));
    } catch (e) {
      Haptics.errorHaptic();
      showAppSnackBar(messenger, 'Error exporting data: $e', isError: true);
    }
  }

  void _handleClearData(BuildContext context) {
    final controller = context.read<AppController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigatorContext = Navigator.of(context).context;
    Navigator.pop(context);
    showDialog<void>(
      context: navigatorContext,
      builder: (_) => ConfirmationDialog(
        title: controller.tr('dataClearTitle'),
        content: controller.tr('dataClearMsg'),
        confirmText: controller.tr('dataClearConfirm'),
        onConfirm: () async {
          try {
            await controller.clearAllData();
            Haptics.heavyHaptic();
            showAppSnackBar(messenger, controller.tr('msgCleared'));
          } catch (e) {
            Haptics.errorHaptic();
            showAppSnackBar(messenger, 'Error clearing data: $e', isError: true);
          }
        },
      ),
    );
  }
}
