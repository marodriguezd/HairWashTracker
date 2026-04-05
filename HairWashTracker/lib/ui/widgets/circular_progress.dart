import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Converts degrees to radians
double radians(double degrees) => degrees * (math.pi / 180.0);

/// CircularProgressPainter - Custom painter for smooth circular progress
/// 
/// Features:
/// - Soft glow effect around the progress arc
/// - Smooth gradient progress indication
/// - Background track with subtle styling
/// - Optional center content
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double glowWidth;
  final double startAngle;
  final double sweepAngle;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 12,
    this.glowWidth = 4,
    this.startAngle = -90,
    this.sweepAngle = 360,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      radians(startAngle.toDouble()),
      radians(sweepAngle.toDouble()),
      false,
      backgroundPaint,
    );

    // Draw glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + glowWidth * 2
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final progressSweep = sweepAngle * progress;
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(startAngle.toDouble()),
        radians(progressSweep),
        false,
        glowPaint,
      );
    }

    // Draw progress arc with gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: radians(startAngle.toDouble()),
        endAngle: radians(startAngle + sweepAngle.toDouble()),
        colors: [
          color.withOpacity(0.8),
          color,
          color.withOpacity(0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(radians(startAngle.toDouble())),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(startAngle.toDouble()),
        radians(progressSweep),
        false,
        progressPaint,
      );
    }

    // Draw decorative dots at start and end
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Start dot
    final startRadians = radians(startAngle.toDouble());
    final startDot = Offset(
      center.dx + radius * math.cos(startRadians),
      center.dy + radius * math.sin(startRadians),
    );
    canvas.drawCircle(startDot, strokeWidth / 3, dotPaint);

    // End dot (if progress > 0)
    if (progress > 0) {
      final endRadians = radians(startAngle + progressSweep);
      final endDot = Offset(
        center.dx + radius * math.cos(endRadians),
        center.dy + radius * math.sin(endRadians),
      );
      canvas.drawCircle(endDot, strokeWidth / 2.5, dotPaint);
      
      // Glow dot at end
      final glowDotPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(endDot, strokeWidth / 1.5, glowDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// AnimatedCircularProgress - A circular progress indicator with animations
/// 
/// Features:
/// - Animated progress value transition
/// - Soft glow effects
/// - Customizable size, colors, and stroke width
/// - Optional center label/value display
class AnimatedCircularProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final Color color;
  final Color? backgroundColor;
  final double strokeWidth;
  final Duration duration;
  final Curve curve;
  final Widget? centerChild;
  final String? label;
  final int targetValue;
  final int currentValue;

  const AnimatedCircularProgress({
    super.key,
    required this.progress,
    this.size = 150,
    required this.color,
    this.backgroundColor,
    this.strokeWidth = 12,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOutQuart,
    this.centerChild,
    this.label,
    this.targetValue = 8,
    this.currentValue = 0,
  });

  @override
  State<AnimatedCircularProgress> createState() =>
      _AnimatedCircularProgressState();
}

class _AnimatedCircularProgressState extends State<AnimatedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _valueAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _setupAnimations();
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.currentValue != widget.currentValue) {
      _setupAnimations();
      _controller.forward(from: 0);
    }
  }

  void _setupAnimations() {
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _valueAnimation = Tween<double>(
      begin: 0,
      end: widget.currentValue.toDouble(),
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
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHighest;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularProgressPainter(
                progress: _progressAnimation.value,
                color: widget.color,
                backgroundColor: effectiveBackgroundColor,
                strokeWidth: widget.strokeWidth,
              ),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Center(
                  child: widget.centerChild ??
                      _buildDefaultCenter(colorScheme),
                ),
              ),
            ),
            if (widget.label != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.label!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildDefaultCenter(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_valueAnimation.value.toInt()}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: widget.color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          '/ ${widget.targetValue}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// CircularProgressCard - Soft card with embedded circular progress
/// 
/// A complete widget combining SoftCard styling with animated
/// circular progress for monthly goal tracking.
class CircularProgressCard extends StatelessWidget {
  final int currentValue;
  final int targetValue;
  final String title;
  final String subtitle;
  final Color color;
  final Duration delay;

  const CircularProgressCard({
    super.key,
    required this.currentValue,
    this.targetValue = 8,
    required this.title,
    required this.subtitle,
    required this.color,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (currentValue / targetValue).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withOpacity(0.95),
            colorScheme.surface.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCircularProgress(
            progress: progress,
            size: 110,
            color: color,
            strokeWidth: 10,
            currentValue: currentValue,
            targetValue: targetValue,
            duration: const Duration(milliseconds: 1800),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuart)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 600.ms,
        );
  }
}
