import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/theme_preference.dart';
import '../../providers/app_controller.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final themeMode = controller.themeMode;
    return SegmentedButton<AppThemeMode>(
      segments: [
        ButtonSegment(
          value: AppThemeMode.light,
          label: Text(controller.tr('themeLight')),
          icon: const Icon(Icons.light_mode_outlined, size: 18),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          label: Text(controller.tr('themeDark')),
          icon: const Icon(Icons.dark_mode_outlined, size: 18),
        ),
        ButtonSegment(
          value: AppThemeMode.system,
          label: Text(controller.tr('themeAuto')),
          icon: const Icon(Icons.settings_suggest_outlined, size: 18),
        ),
      ],
      selected: {themeMode},
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
      ),
      onSelectionChanged: (selection) {
        HapticFeedback.selectionClick();
        context.read<AppController>().setThemeMode(selection.first);
      },
    );
  }
}
