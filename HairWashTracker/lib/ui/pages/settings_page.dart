import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/theme_preference.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import '../widgets/theme_switch.dart';

/// Settings page: appearance (theme mode + accent color).
///
/// Accent defaults to the system wallpaper color on Android 12+.
/// Picking a preset seed opts out of dynamic color; re-selecting
/// "System" opts back in.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static String presetLabel(AppPresetTheme preset) {
    switch (preset) {
      case AppPresetTheme.warmCoral:
        return 'Warm Coral';
      case AppPresetTheme.lavenderMist:
        return 'Lavender';
      case AppPresetTheme.sageMist:
        return 'Sage';
      case AppPresetTheme.oceanBlue:
        return 'Ocean';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingScreen),
        children: [
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.75,
                ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingScreen),
              child: ThemeSwitch(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Accent color',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.75,
                ),
          ),
          const SizedBox(height: 8),
          Consumer<AppController>(
            builder: (context, controller, _) {
              final scheme = Theme.of(context).colorScheme;
              return Card(
                child: Column(
                  children: [
                    _AccentTile(
                      title: 'System',
                      subtitle:
                          'Follows your wallpaper on Android 12+. Falls back to the selected preset otherwise.',
                      selected: controller.useDynamicColor,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary,
                              scheme.secondary,
                              scheme.tertiary,
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        controller.setUseDynamicColor(true);
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ...AppPresetTheme.values.map(
                      (preset) {
                        final selected = !controller.useDynamicColor &&
                            controller.themePreset == preset;
                        final seed = AppTheme.getSeedColor(preset);
                        return _AccentTile(
                          title: presetLabel(preset),
                          selected: selected,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: seed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: seed.withValues(alpha: 0.4),
                                  blurRadius: selected ? 8 : 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            controller.setThemePreset(preset);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AccentTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool selected;
  final Widget leading;
  final VoidCallback onTap;

  const _AccentTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : Icon(Icons.circle_outlined, color: scheme.outline),
      selected: selected,
      selectedColor: scheme.onSurface,
      onTap: onTap,
    );
  }
}
