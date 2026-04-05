import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double depth;
  final bool isPressed;
  final Color? color;
  final bool hasTexture;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.depth = 8.0,
    this.isPressed = false,
    this.color,
    this.hasTexture = false,
  });

  static List<BoxShadow> _buildRaisedShadows(bool isDark, double depth) {
    if (isDark) {
      return [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.6),
          offset: Offset(-depth, -depth),
          blurRadius: depth * 2,
        ),
        BoxShadow(
          color: const Color.fromRGBO(255, 255, 255, 0.08),
          offset: Offset(depth, depth),
          blurRadius: depth * 2,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: const Color.fromRGBO(255, 255, 255, 0.9),
          offset: Offset(-depth, -depth),
          blurRadius: depth * 2,
        ),
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.2),
          offset: Offset(depth, depth),
          blurRadius: depth * 2,
        ),
      ];
    }
  }

  static List<BoxShadow> _buildPressedShadows(bool isDark, double depth) {
    if (isDark) {
      return [
        BoxShadow(
          color: const Color.fromRGBO(255, 255, 255, 0.1),
          offset: Offset(-depth * 0.5, -depth * 0.5),
          blurRadius: depth,
        ),
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.6),
          offset: Offset(depth * 0.5, depth * 0.5),
          blurRadius: depth,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: const Color.fromRGBO(0, 0, 0, 0.25),
          offset: Offset(-depth * 0.5, -depth * 0.5),
          blurRadius: depth,
        ),
        BoxShadow(
          color: const Color.fromRGBO(255, 255, 255, 0.9),
          offset: Offset(depth * 0.5, depth * 0.5),
          blurRadius: depth,
        ),
      ];
    }
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
        boxShadow: isPressed
            ? _buildPressedShadows(isDark, depth)
            : _buildRaisedShadows(isDark, depth),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      ),
    );
  }
}
