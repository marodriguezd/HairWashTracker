import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/haptics.dart';
import 'soft_container.dart';

/// Empty state widget for when no data exists
/// 
/// Features:
/// - Soft, calming illustration
/// - Gentle encouraging message
/// - Animated entrance
/// - Optional action button
/// - Haptic feedback on interaction
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
      message: 'Start tracking your hair wash routine to see your progress here.',
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
    final effectiveIcon = icon ?? Icons.inbox_outlined;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft illustration container
            _SoftIllustration(
              icon: effectiveIcon,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 32),
            // Title
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
            // Message
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
            // Custom widget
            if (customWidget != null)
              customWidget!
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms),
            // Action button
            if (actionLabel != null && onAction != null)
              SoftCard(
                onTap: () {
                  Haptics.mediumHaptic();
                  onAction!();
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                glowColor: colorScheme.primary.withOpacity(0.2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      actionLabel!,
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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

/// Animated soft illustration with floating animation
class _SoftIllustration extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _SoftIllustration({
    required this.icon,
    required this.color,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    widget.color.withOpacity(0.15),
                    widget.color.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color.withOpacity(0.2),
                        widget.color.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 48,
                    color: widget.color.withOpacity(0.8),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
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
          color: colorScheme.primary.withOpacity(0.7),
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
