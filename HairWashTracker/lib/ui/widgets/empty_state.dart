import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/haptics.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

/// Empty state widget for when no data exists
///
/// Features:
/// - Soft, calming illustration
/// - Gentle encouraging message
/// - Animated entrance
/// - Optional action button
/// - Haptic feedback on interaction
/// - Neumorphic styling
class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customWidget;

  const EmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.customWidget,
  });

  /// Creates an empty state for no wash data
  factory EmptyState.noWashes({
    VoidCallback? onAddWash,
  }) {
    return EmptyState(
      title: 'No Washes Yet',
      message:
          'Start tracking your hair wash routine to see your progress here.',
      icon: Icons.water_drop_outlined,
      actionLabel: onAddWash != null ? 'Add First Wash' : null,
      onAction: onAddWash,
    );
  }

  /// Creates an empty state for no data in a date range
  factory EmptyState.noDataInRange({
    VoidCallback? onAction,
  }) {
    return const EmptyState(
      title: 'No Data Available',
      message: 'There are no washes recorded for this time period.',
      icon: Icons.calendar_today_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIcon = icon ?? Icons.inbox_outlined;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SoftIllustration(
              icon: effectiveIcon,
              color: AppTheme.warmCoral,
              isDark: isDark,
            ),
            const SizedBox(height: 32),
            if (title != null)
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            if (title != null && message != null) const SizedBox(height: 12),
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            const SizedBox(height: 32),
            if (customWidget != null)
              customWidget!
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            if (actionLabel != null && onAction != null)
              NeumorphicContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                borderRadius: AppTheme.radiusCard,
                depth: 10,
                child: InkWell(
                  onTap: () {
                    Haptics.mediumHaptic();
                    onAction!();
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        actionLabel!,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms)
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    delay: 400.ms,
                    curve: Curves.elasticOut,
                  ),
          ],
        ),
      ),
    );
  }
}

/// Animated soft illustration with floating animation and neumorphic styling
class _SoftIllustration extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SoftIllustration({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  State<_SoftIllustration> createState() => _SoftIllustrationState();
}

class _SoftIllustrationState extends State<_SoftIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: NeumorphicContainer(
              borderRadius: AppTheme.radiusCircle,
              depth: widget.isDark ? 12 : 15,
              padding: const EdgeInsets.all(28),
              color: widget.isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surface,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      widget.color.withValues(alpha: 0.25),
                      widget.color.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 48,
                  color: widget.color.withValues(alpha: 0.9),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
          ),
        );
      },
    );
  }
}

/// Empty state for stats page
class EmptyStatsState extends StatelessWidget {
  final VoidCallback? onStartTracking;

  const EmptyStatsState({
    super.key,
    this.onStartTracking,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No Statistics Yet',
      message:
          'Track your hair washes for at least a week to see insightful statistics about your routine.',
      icon: Icons.analytics_outlined,
      actionLabel: onStartTracking != null ? 'Start Tracking' : null,
      onAction: onStartTracking,
      customWidget: Column(
        children: [
          _buildFeatureItem(
            context,
            icon: Icons.calendar_month_outlined,
            text: 'Track wash frequency',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.trending_up_outlined,
            text: 'View progress charts',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.schedule_outlined,
            text: 'Optimize your routine',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context,
      {required IconData icon, required String text}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
