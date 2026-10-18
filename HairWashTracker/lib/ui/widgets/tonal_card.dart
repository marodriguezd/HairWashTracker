import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// Content block on a tonal M3 surface.
///
/// Elevation stays 0: depth comes from `surfaceContainerHigh` versus the
/// scaffold background, which keeps contrast modes and dynamic color intact.
class TonalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final bool clipContent;

  const TonalCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = AppTheme.radiusCard,
    this.color,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: color ?? colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingCard),
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
