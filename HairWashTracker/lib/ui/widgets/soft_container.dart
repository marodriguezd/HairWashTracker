import 'dart:ui';
import 'package:flutter/material.dart';

/// Soft Container - Enhanced glassmorphism with Soft Architecture aesthetics
/// 
/// Base widget with inner shadow support, ambient glow effects, and subtle
/// border gradients for depth perception following Soft Architecture principles.
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
    this.borderRadius = 24.0,
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
    final effectiveGlowColor = glowColor ?? colorScheme.primary.withOpacity(0.15);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadows ?? [
          // Soft ambient shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Subtle top highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null 
                  ? colorScheme.surface.withOpacity(opacity)
                  : null,
              gradient: gradient != null
                  ? gradient!.opacity(opacity)
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ?? Border.all(
                color: colorScheme.onSurface.withOpacity(0.08),
                width: 0.5,
              ),
              // Inner shadow effect using boxShadow with inset
              boxShadow: hasInnerShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(innerShadowOpacity * 0.5),
                        blurRadius: 15,
                        spreadRadius: -5,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Ambient glow overlay
                if (glowColor != null)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.2,
                          colors: [
                            effectiveGlowColor,
                            effectiveGlowColor.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft Card - Elevated variant with higher elevation and soft shadows
/// 
/// Perfect for cards, lists, and content containers that need to stand out
/// with a soft, elevated appearance.
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
    this.borderRadius = 24.0,
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
    final effectiveGlowColor = glowColor ?? colorScheme.primary.withOpacity(0.12);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Primary elevation shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: elevation * 2.5,
            spreadRadius: elevation * 0.3,
            offset: Offset(0, elevation),
          ),
          // Soft ambient glow
          BoxShadow(
            color: effectiveGlowColor,
            blurRadius: elevation * 4,
            spreadRadius: -elevation * 0.5,
            offset: const Offset(0, 0),
          ),
          // Top highlight for depth
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null
                  ? colorScheme.surface.withOpacity(0.85)
                  : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: hasInnerShadow
                  ? [
                      // Inner shadow for depth
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: -8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Soft Surface - Flat variant for backgrounds and sections
/// 
/// No elevation, just subtle surface color. Perfect for section backgrounds,
/// content areas, and anywhere you need a soft, flat surface.
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
    this.borderRadius = 20.0,
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Very subtle shadow for surface definition
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: gradient == null
                  ? effectiveSurfaceColor.withOpacity(0.6)
                  : null,
              gradient: gradient != null
                  ? gradient!.opacity(0.6)
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: hasBorder
                  ? Border.all(
                      color: colorScheme.onSurface.withOpacity(0.06),
                      width: 0.5,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Soft Dialog - Modal variant for dialogs and bottom sheets
/// 
/// Enhanced blur and glow effects specifically designed for modal presentations.
/// Includes proper padding and generous rounded corners.
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
    this.borderRadius = 32.0,
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
    final effectiveGlowColor = glowColor ?? colorScheme.primary.withOpacity(0.2);

    return Container(
      margin: margin ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Deep modal shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: 8,
            offset: const Offset(0, 16),
          ),
          // Ambient glow
          BoxShadow(
            color: effectiveGlowColor,
            blurRadius: 60,
            spreadRadius: -10,
            offset: const Offset(0, 0),
          ),
          // Top highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 15,
            spreadRadius: -4,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
              minWidth: 280,
            ),
            decoration: BoxDecoration(
              color: gradient == null
                  ? colorScheme.surface.withOpacity(opacity)
                  : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.12),
                width: 0.5,
              ),
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
                          color: colorScheme.onSurface.withOpacity(0.08),
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
          ),
        ),
      ),
    );
  }
}

/// Glass Container - Legacy compatibility alias
/// 
/// This is the original GlassContainer for backwards compatibility.
/// New code should use SoftContainer or one of the specialized variants.
@Deprecated('Use SoftContainer instead. This class is kept for backwards compatibility.')
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

/// Extension to apply opacity to gradients
extension GradientOpacity on Gradient {
  Gradient opacity(double value) {
    if (this is LinearGradient) {
      final linear = this as LinearGradient;
      return LinearGradient(
        begin: linear.begin,
        end: linear.end,
        colors: linear.colors.map((c) => c.withOpacity(c.opacity * value)).toList(),
        stops: linear.stops,
      );
    } else if (this is RadialGradient) {
      final radial = this as RadialGradient;
      return RadialGradient(
        center: radial.center,
        radius: radial.radius,
        colors: radial.colors.map((c) => c.withOpacity(c.opacity * value)).toList(),
        stops: radial.stops,
      );
    } else if (this is SweepGradient) {
      final sweep = this as SweepGradient;
      return SweepGradient(
        center: sweep.center,
        startAngle: sweep.startAngle,
        endAngle: sweep.endAngle,
        colors: sweep.colors.map((c) => c.withOpacity(c.opacity * value)).toList(),
        stops: sweep.stops,
      );
    }
    return this;
  }
}