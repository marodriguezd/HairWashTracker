import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../pages/settings_page.dart';
import '../pages/stats_page.dart';
import 'confirmation_dialog.dart';
import '../../utils/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = Provider.of<AppController>(context);

    return Drawer(
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppTheme.radiusCard),
          bottomRight: Radius.circular(AppTheme.radiusCard),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.waves_rounded,
                      color: colorScheme.onPrimaryContainer, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.tr('appTitle'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.tr('drawerTagline'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        letterSpacing: 0.25,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: strings.tr('drawerHome'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  isSelected: true,
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: strings.tr('pageStatistics'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const StatsPage()));
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: strings.tr('navSettings'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()));
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    strings.tr('drawerSectionData'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.75,
                        ),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.upload_file_rounded,
                  label: strings.tr('drawerImport'),
                  onTap: () => _handleImport(context),
                ),
                _DrawerItem(
                  icon: Icons.download_for_offline_rounded,
                  label: strings.tr('drawerExport'),
                  onTap: () => _handleExport(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(),
                ),
                _DrawerItem(
                  icon: Icons.delete_forever_rounded,
                  label: strings.tr('drawerClear'),
                  iconColor: colorScheme.error,
                  textColor: colorScheme.error,
                  onTap: () => _handleClearData(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleImport(BuildContext context) async {
    Navigator.pop(context);
    final controller = Provider.of<AppController>(context, listen: false);
    try {
      await controller.importData();
      if (context.mounted) {
        _showSnackBar(context, controller.tr('msgImported'), isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error importing data: $e', isError: true);
      }
    }
  }

  void _handleExport(BuildContext context) async {
    Navigator.pop(context);
    final controller = Provider.of<AppController>(context, listen: false);
    try {
      await controller.exportData();
      if (context.mounted) {
        _showSnackBar(context, controller.tr('msgExported'), isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error exporting data: $e', isError: true);
      }
    }
  }

  void _handleClearData(BuildContext context) {
    final controller = Provider.of<AppController>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: controller.tr('dataClearTitle'),
        content: controller.tr('dataClearMsgShort'),
        onConfirm: () async {
          Navigator.pop(context);
          try {
            await Provider.of<AppController>(context, listen: false)
                .clearAllData();
            if (context.mounted) {
              _showSnackBar(context, controller.tr('msgCleared'),
                  isError: false);
            }
          } catch (e) {
            if (context.mounted) {
              _showSnackBar(context, 'Error clearing data: $e', isError: true);
            }
          }
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon,
          color: iconColor ??
              (isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant)),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor ??
                  (isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              letterSpacing: 0.5,
            ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
      selected: isSelected,
      selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
    );
  }
}
