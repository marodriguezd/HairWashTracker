import 'package:flutter/material.dart';

/// Centralized neumorphic shadow system for consistent styling throughout the app.
/// Uses refined, subtle shadow values to avoid the "superpuffed" look.
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
    this.borderRadius = 24.0,
    this.depth = 3.5,
    this.isPressed = false,
    this.color,
    this.hasTexture = false,
    this.clipContent = true,
  });

  /// Builds subtle, refined raised shadows for light theme
  /// White shadow: 0.75 opacity (was 0.9)
  /// Black shadow: 0.12 opacity (was 0.2)
  static List<BoxShadow> _buildLightRaised(double depth) {
    return [
      BoxShadow(
        color: const Color.fromRGBO(255, 255, 255, 0.75),
        offset: Offset(-depth, -depth),
        blurRadius: depth * 1.5,
      ),
      BoxShadow(
        color: const Color.fromRGBO(0, 0, 0, 0.12),
        offset: Offset(depth, depth),
        blurRadius: depth * 1.5,
      ),
    ];
  }

  /// Builds subtle, refined raised shadows for dark theme
  /// White shadow: 0.06 opacity (was 0.08)
  /// Black shadow: 0.45 opacity (was 0.6)
  static List<BoxShadow> _buildDarkRaised(double depth) {
    return [
      BoxShadow(
        color: const Color.fromRGBO(255, 255, 255, 0.06),
        offset: Offset(-depth, -depth),
        blurRadius: depth * 1.5,
      ),
      BoxShadow(
        color: const Color.fromRGBO(0, 0, 0, 0.45),
        offset: Offset(depth, depth),
        blurRadius: depth * 1.5,
      ),
    ];
  }

  /// Builds subtle pressed shadows for light theme (inverted)
  static List<BoxShadow> _buildLightPressed(double depth) {
    return [
      BoxShadow(
        color: const Color.fromRGBO(0, 0, 0, 0.15),
        offset: Offset(-depth * 0.5, -depth * 0.5),
        blurRadius: depth,
      ),
      BoxShadow(
        color: const Color.fromRGBO(255, 255, 255, 0.7),
        offset: Offset(depth * 0.5, depth * 0.5),
        blurRadius: depth,
      ),
    ];
  }

  /// Builds subtle pressed shadows for dark theme (inverted)
  static List<BoxShadow> _buildDarkPressed(double depth) {
    return [
      BoxShadow(
        color: const Color.fromRGBO(255, 255, 255, 0.08),
        offset: Offset(-depth * 0.5, -depth * 0.5),
        blurRadius: depth,
      ),
      BoxShadow(
        color: const Color.fromRGBO(0, 0, 0, 0.5),
        offset: Offset(depth * 0.5, depth * 0.5),
        blurRadius: depth,
      ),
    ];
  }

  /// Public factory for building consistent shadows across the app
  static List<BoxShadow> buildShadows(
    bool isDark, {
    double depth = 3.5,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return isDark ? _buildDarkPressed(depth) : _buildLightPressed(depth);
    }
    return isDark ? _buildDarkRaised(depth) : _buildLightRaised(depth);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = color ?? colorScheme.surface;

    Widget content = child;

    if (hasTexture) {
      content = Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.02),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.02),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.02),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: buildShadows(isDark, depth: depth, isPressed: isPressed),
      ),
      child: clipContent
          ? ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: content,
            )
          : content,
    );
  }
}
