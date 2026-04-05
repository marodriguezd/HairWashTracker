import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class SoftContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final Color? glowColor;
  final bool hasInnerShadow;
  final double innerShadowOpacity;
  final List<BoxShadow>? boxShadows;
  final Gradient? gradient;

  const SoftContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.08,
    this.borderRadius = AppTheme.radiusCard,
    this.padding,
    this.margin,
    this.border,
    this.glowColor,
    this.hasInnerShadow = false,
    this.innerShadowOpacity = 0.15,
    this.boxShadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveGlowColor =
        glowColor ?? colorScheme.primary.withValues(alpha: 0.15);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? colorScheme.surface.withValues(alpha: opacity)
            : null,
        gradient: gradient?.opacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ??
            Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
              width: 0.5,
            ),
        boxShadow: boxShadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, -2),
              ),
              if (hasInnerShadow)
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: innerShadowOpacity * 0.5),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 3),
                ),
            ],
      ),
      child: glowColor != null
          ? Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [
                          effectiveGlowColor,
                          effectiveGlowColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                child,
              ],
            )
          : child,
    );
  }
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double elevation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hasInnerShadow;
  final Gradient? gradient;

  const SoftCard({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusCard,
    this.padding,
    this.margin,
    this.glowColor,
    this.elevation = 8.0,
    this.onTap,
    this.onLongPress,
    this.hasInnerShadow = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveGlowColor =
        glowColor ?? colorScheme.primary.withValues(alpha: 0.12);

    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? colorScheme.surface.withValues(alpha: 0.85)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: elevation * 2.5,
            spreadRadius: elevation * 0.3,
            offset: Offset(0, elevation),
          ),
          BoxShadow(
            color: effectiveGlowColor,
            blurRadius: elevation * 4,
            spreadRadius: -elevation * 0.5,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.6),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
          if (hasInnerShadow)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: -8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      card = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}

class SoftSurface extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? surfaceColor;
  final bool hasBorder;
  final Gradient? gradient;

  const SoftSurface({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusCard - 4,
    this.padding,
    this.margin,
    this.surfaceColor,
    this.hasBorder = true,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveSurfaceColor = surfaceColor ?? colorScheme.surface;

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? effectiveSurfaceColor.withValues(alpha: 0.6)
            : null,
        gradient: gradient?.opacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius),
        border: hasBorder
            ? Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
                width: 0.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SoftDialog extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? glowColor;
  final double blur;
  final double opacity;
  final Gradient? gradient;
  final List<Widget>? actions;
  final String? title;

  const SoftDialog({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusCard + 8,
    this.padding,
    this.margin,
    this.glowColor,
    this.blur = 25.0,
    this.opacity = 0.9,
    this.gradient,
    this.actions,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveGlowColor =
        glowColor ?? colorScheme.primary.withValues(alpha: 0.2);

    return Container(
      margin: margin ?? const EdgeInsets.all(24),
      constraints: const BoxConstraints(
        maxWidth: 400,
        minWidth: 280,
      ),
      decoration: BoxDecoration(
        color: gradient == null
            ? colorScheme.surface.withValues(alpha: opacity)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 8,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: effectiveGlowColor,
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            blurRadius: 15,
            spreadRadius: -4,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          Flexible(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(24),
              child: child,
            ),
          ),
          if (actions != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ),
        ],
      ),
    );
  }
}

@Deprecated(
    'Use SoftContainer instead. This class is kept for backwards compatibility.')
class GlassContainer extends SoftContainer {
  const GlassContainer({
    super.key,
    required super.child,
    super.blur = 15.0,
    super.opacity = 0.1,
    super.borderRadius = 24.0,
    super.padding,
    super.margin,
    super.border,
  });
}

extension GradientOpacity on Gradient {
  Gradient opacity(double value) {
    if (this is LinearGradient) {
      final linear = this as LinearGradient;
      return LinearGradient(
        begin: linear.begin,
        end: linear.end,
        colors:
            linear.colors.map((c) => c.withValues(alpha: value * c.a)).toList(),
        stops: linear.stops,
      );
    } else if (this is RadialGradient) {
      final radial = this as RadialGradient;
      return RadialGradient(
        center: radial.center,
        radius: radial.radius,
        colors:
            radial.colors.map((c) => c.withValues(alpha: value * c.a)).toList(),
        stops: radial.stops,
      );
    } else if (this is SweepGradient) {
      final sweep = this as SweepGradient;
      return SweepGradient(
        center: sweep.center,
        startAngle: sweep.startAngle,
        endAngle: sweep.endAngle,
        colors:
            sweep.colors.map((c) => c.withValues(alpha: value * c.a)).toList(),
        stops: sweep.stops,
      );
    }
    return this;
  }
}
