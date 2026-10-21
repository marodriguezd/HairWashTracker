import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/language_preference.dart';
import '../../models/theme_preference.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
import '../widgets/theme_switch.dart';

/// Settings page: appearance (theme mode + accent color).
///
/// Accent defaults to the system wallpaper color on Android 12+.
/// Picking a preset seed opts out of dynamic color; re-selecting
/// "System" opts back in.
class SettingsPage extends StatelessWidget {
  final bool embed;
  const SettingsPage({super.key, this.embed = false});

  static String presetLabel(AppPresetTheme preset, AppController controller) {
    switch (preset) {
      case AppPresetTheme.warmCoral:
        return controller.tr('presetWarmCoral');
      case AppPresetTheme.lavenderMist:
        return controller.tr('presetLavender');
      case AppPresetTheme.sageMist:
        return controller.tr('presetSage');
      case AppPresetTheme.oceanBlue:
        return controller.tr('presetOcean');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final Widget list = ListView(
      padding: const EdgeInsets.all(AppTheme.spacingScreen),
      children: [
        Text(
          controller.tr('setLanguage'),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.75,
              ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingScreen),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.tr('setLanguageDesc'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: controller.languageCode,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: [
                    DropdownMenuItem(
                      value: LanguagePreference.auto,
                      child: Text(controller.tr('setLangAuto')),
                    ),
                    ...AppLanguage.supported.map(
                      (lang) => DropdownMenuItem(
                        value: lang.code,
                        child: Text(lang.nativeName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    Haptics.selectionHaptic();
                    controller.setLanguageCode(value);
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          controller.tr('setAppearance'),
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
          controller.tr('setAccent'),
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
                    title: controller.tr('setAccentSystem'),
                    subtitle: controller.tr('setAccentSystemDesc'),
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
                      Haptics.selectionHaptic();
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
                        title: presetLabel(preset, controller),
                        selected: selected,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: seed,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? scheme.primary
                                  : scheme.outlineVariant.withValues(alpha: 0.5),
                              width: selected ? 2.5 : 1,
                            ),
                          ),
                        ),
                        onTap: () {
                          Haptics.selectionHaptic();
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
    );

    final Widget content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
        child: list,
      ),
    );

    if (embed) return content;
    return Scaffold(
      appBar: AppBar(title: Text(controller.tr('navSettings'))),
      body: content,
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
