import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/theme_preference.dart';
import '../../providers/app_controller.dart';
import 'glass_container.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppController>().themeMode;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassContainer(
      borderRadius: 16,
      opacity: 0.1,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: AppThemeMode.values.asMap().entries.map((entry) {
          final mode = entry.value;
          final isSelected = themeMode == mode;
          final isFirst = entry.key == 0;
          final isLast = entry.key == AppThemeMode.values.length - 1;

          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<AppController>().setThemeMode(mode),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
                    bottomLeft:
                        isFirst ? const Radius.circular(16) : Radius.zero,
                    topRight: isLast ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                        isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                ),
                child: Text(
                  mode.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
