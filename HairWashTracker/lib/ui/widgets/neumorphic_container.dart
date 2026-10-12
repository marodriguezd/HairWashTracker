import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// M3 card container (API-compatible with the legacy NeumorphicContainer).
/// Uses tonal elevation instead of dual neumorphic shadows.
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double depth;
  final bool isPressed;
  final Color? color;
  final bool hasTexture;
  final bool clipContent;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusCard,
    this.depth = 0,
    this.isPressed = false,
    this.color,
    this.hasTexture = false,
    this.clipContent = true,
  });

  /// Compatibility shim: M3 tonal elevation needs no hard shadows, so this returns empty.
  static List<BoxShadow> buildShadows(
    bool isDark, {
    double depth = 0,
    bool isPressed = false,
  }) {
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = color ?? colorScheme.surfaceContainerHigh;

    return Container(
      margin: margin,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: clipContent
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}
