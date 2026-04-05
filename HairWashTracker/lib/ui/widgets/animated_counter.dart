import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

/// AnimatedCounter - A reusable widget that animates from 0 to target value
///
/// Features:
/// - Smooth counting animation with flutter_animate
/// - Customizable duration, curve, and text style
/// - Optional suffix/prefix
/// - Integer or decimal counting support
/// - Neumorphic design integration
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final bool animateOnLoad;
  final bool useSlideAnimation;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOutQuart,
    this.style,
    this.prefix,
    this.suffix,
    this.animateOnLoad = true,
    this.useSlideAnimation = true,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _setupAnimation();
    if (widget.animateOnLoad) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _setupAnimation();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimation() {
    _animation = IntTween(
      begin: 0,
      end: widget.value,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${widget.prefix ?? ''}${_animation.value}${widget.suffix ?? ''}',
          style: widget.style ?? Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

/// AnimatedStatValue - Enhanced counter with icon and label
///
/// A complete stat display with animated counting number,
/// icon, and label in a vertical layout with neumorphic styling.
class AnimatedStatValue extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;
  final Duration delay;
  final Duration duration;
  final double iconSize;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  const AnimatedStatValue({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1500),
    this.iconSize = 32,
    this.valueStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeumorphicContainer(
          borderRadius: AppTheme.radiusCircle - 30,
          padding: const EdgeInsets.all(16),
          depth: isDark ? 8 : 12,
          color: isDark
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
        )
            .animate(delay: delay)
            .scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            )
            .fadeIn(duration: 400.ms),
        const SizedBox(height: 16),
        AnimatedCounter(
          value: value,
          duration: duration,
          style: valueStyle ??
              Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.warmCoral,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
        ).animate(delay: delay + 100.ms).fadeIn(duration: 400.ms).slideY(
            begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutQuart),
        const SizedBox(height: 8),
        Text(
          label,
          style: labelStyle ??
              Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
        )
            .animate(delay: delay + 200.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
      ],
    );
  }
}
