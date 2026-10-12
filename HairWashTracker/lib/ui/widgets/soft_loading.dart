import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Soft shimmer/loading widget with soft aesthetic
///
/// Features:
/// - Gentle pulse animation (not harsh flashing)
/// - Customizable colors to match theme
/// - Multiple preset styles (card, circle, text)
/// - Configurable shimmer speed and intensity
class SoftShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const SoftShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 500),
  });

  /// Creates a shimmer that looks like a card
  factory SoftShimmer.card({
    double width = double.infinity,
    double height = 100,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return SoftShimmer(
      width: width,
      height: height,
      borderRadius: 16,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Creates a shimmer that looks like a circle
  factory SoftShimmer.circle({
    double size = 48,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return SoftShimmer(
      width: size,
      height: size,
      borderRadius: size / 2,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// Creates a shimmer that looks like text
  factory SoftShimmer.text({
    double width = 200,
    double height = 16,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return SoftShimmer(
      width: width,
      height: height,
      borderRadius: 4,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  @override
  State<SoftShimmer> createState() => _SoftShimmerState();
}

class _SoftShimmerState extends State<SoftShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
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
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = widget.baseColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final highlightColor = widget.highlightColor ??
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(
                -1 + (2 * _animation.value),
                0,
              ),
              end: Alignment(
                1 + (2 * _animation.value),
                0,
              ),
              colors: [
                baseColor,
                Color.lerp(baseColor, highlightColor, 0.5)!,
                highlightColor,
                Color.lerp(highlightColor, baseColor, 0.5)!,
                baseColor,
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Soft loading indicator with pulsing animation
class SoftLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const SoftLoadingIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  State<SoftLoadingIndicator> createState() => _SoftLoadingIndicatorState();
}

class _SoftLoadingIndicatorState extends State<SoftLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
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
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.color ?? colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.6),
                    color.withValues(alpha: 0.3),
                    color.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: widget.size * 0.7,
                  height: widget.size * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surface.withValues(alpha: 0.9),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.water_drop_outlined,
                      size: widget.size * 0.35,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Soft loading container with shimmer effect
class SoftLoadingContainer extends StatelessWidget {
  final int itemCount;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const SoftLoadingContainer({
    super.key,
    this.itemCount = 3,
    this.spacing = 16,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(itemCount * 2 - 1, (index) {
          if (index.isOdd) {
            return SizedBox(height: spacing);
          }
          final itemIndex = index ~/ 2;
          return SoftShimmer.card()
              .animate(delay: Duration(milliseconds: itemIndex * 100))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, duration: 400.ms);
        }),
      ),
    );
  }
}

/// Full screen soft loading overlay
class SoftLoadingOverlay extends StatelessWidget {
  final String? message;

  const SoftLoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SoftLoadingIndicator(size: 64),
            if (message != null) ...[
              const SizedBox(height: 24),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}
