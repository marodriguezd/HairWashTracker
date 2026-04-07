import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../pages/stats_page.dart';
import 'confirmation_dialog.dart';
import 'theme_switch.dart';
import '../../utils/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.warmCoral, AppTheme.peachBlush],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.waves_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hair Wash Tracker',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Taking care of your hair',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
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
                  label: 'Home',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  isSelected: true,
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Statistics',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const StatsPage()));
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.75,
                        ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ThemeSwitch(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.75,
                        ),
                  ),
                ),
                _DrawerItem(
                  icon: Icons.upload_file_rounded,
                  label: 'Import Data (CSV)',
                  onTap: () => _handleImport(context),
                ),
                _DrawerItem(
                  icon: Icons.download_for_offline_rounded,
                  label: 'Export Data (CSV)',
                  onTap: () => _handleExport(context),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Divider(),
                ),
                _DrawerItem(
                  icon: Icons.delete_forever_rounded,
                  label: 'Clear Data',
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
    try {
      await Provider.of<AppController>(context, listen: false).importData();
      if (context.mounted) {
        _showSnackBar(context, 'Data imported successfully', isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error importing data: $e', isError: true);
      }
    }
  }

  void _handleExport(BuildContext context) async {
    Navigator.pop(context);
    try {
      await Provider.of<AppController>(context, listen: false).exportData();
      if (context.mounted) {
        _showSnackBar(context, 'Data exported successfully', isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error exporting data: $e', isError: true);
      }
    }
  }

  void _handleClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Clear all data?',
        content: 'This action cannot be undone.',
        onConfirm: () async {
          Navigator.pop(context);
          try {
            await Provider.of<AppController>(context, listen: false)
                .clearAllData();
            if (context.mounted) {
              _showSnackBar(context, 'All data has been cleared',
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
