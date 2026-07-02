import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/theme_preference.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppController>().themeMode;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeumorphicContainer(
      borderRadius: AppTheme.radiusButton + 4,
      depth: 6,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: AppThemeMode.values.asMap().entries.map((entry) {
          final mode = entry.value;
          final isSelected = themeMode == mode;
          final isFirst = entry.key == 0;
          final isLast = entry.key == AppThemeMode.values.length - 1;

          return Expanded(
            child: _ThemeModeButton(
              mode: mode,
              isSelected: isSelected,
              isFirst: isFirst,
              isLast: isLast,
              colorScheme: colorScheme,
              isDark: isDark,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ThemeModeButton extends StatefulWidget {
  final AppThemeMode mode;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final ColorScheme colorScheme;
  final bool isDark;

  const _ThemeModeButton({
    required this.mode,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  State<_ThemeModeButton> createState() => _ThemeModeButtonState();
}

class _ThemeModeButtonState extends State<_ThemeModeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        context.read<AppController>().setThemeMode(widget.mode);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? widget.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: widget.isFirst
                ? const Radius.circular(AppTheme.radiusButton + 4)
                : Radius.zero,
            bottomLeft: widget.isFirst
                ? const Radius.circular(AppTheme.radiusButton + 4)
                : Radius.zero,
            topRight: widget.isLast
                ? const Radius.circular(AppTheme.radiusButton + 4)
                : Radius.zero,
            bottomRight: widget.isLast
                ? const Radius.circular(AppTheme.radiusButton + 4)
                : Radius.zero,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: widget.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Transform.scale(
          scale: _isPressed && !widget.isSelected ? 0.95 : 1.0,
          child: Text(
            _getModeLabel(widget.mode),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isSelected
                  ? widget.colorScheme.onPrimary
                  : widget.colorScheme.onSurfaceVariant,
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    ).animate(target: widget.isSelected ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 200.ms,
        );
  }

  String _getModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'LIGHT';
      case AppThemeMode.dark:
        return 'DARK';
      case AppThemeMode.system:
        return 'AUTO';
    }
  }
}
