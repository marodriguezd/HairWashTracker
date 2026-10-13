import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
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
              title: Text(strings.tr('drawerExport')),
              subtitle: Text(strings.tr('dataExportDesc')),
              onTap: () => _handleExport(context),
            ),
            ListTile(
              leading: Icon(Icons.file_upload_outlined, color: colorScheme.primary),
              title: Text(strings.tr('drawerImport')),
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

  void _handleImport(BuildContext context) async {
    Navigator.pop(context);
    final controller = context.read<AppController>();
    try {
      await controller.importData();
      if (context.mounted) {
        Haptics.successHaptic();
        _showSnackBar(context, controller.tr('msgImported'), isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        Haptics.errorHaptic();
        _showSnackBar(context, 'Error importing data: $e', isError: true);
      }
    }
  }

  void _handleExport(BuildContext context) async {
    Navigator.pop(context);
    final controller = context.read<AppController>();
    try {
      await controller.exportData();
      if (context.mounted) {
        Haptics.successHaptic();
        _showSnackBar(context, controller.tr('msgExported'), isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        Haptics.errorHaptic();
        _showSnackBar(context, 'Error exporting data: $e', isError: true);
      }
    }
  }

  void _handleClearData(BuildContext context) {
    Navigator.pop(context);
    final controller = context.read<AppController>();
    showDialog(
      context: context,
      builder: (dialogCtx) => ConfirmationDialog(
        title: controller.tr('dataClearTitle'),
        content: controller.tr('dataClearMsg'),
        confirmText: controller.tr('dataClearConfirm'),
        onConfirm: () async {
          try {
            await context.read<AppController>().clearAllData();
            if (context.mounted) {
              Haptics.heavyHaptic();
              _showSnackBar(context, controller.tr('msgCleared'), isError: false);
            }
          } catch (e) {
            if (context.mounted) {
              Haptics.errorHaptic();
              _showSnackBar(context, 'Error clearing data: $e', isError: true);
            }
          }
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
