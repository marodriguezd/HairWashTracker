import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../../utils/haptics.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

/// Reads a localized string, falling back to [fallback] when no
/// [AppController] is available above this context.
String _lt(BuildContext context, String key, String fallback) {
  try {
    return Provider.of<AppController>(context, listen: false).tr(key);
  } catch (_) {
    return fallback;
  }
}

/// Empty state widget for when no data exists
///
/// Features:
/// - Soft, calming illustration
/// - Gentle encouraging message
/// - Animated entrance
/// - Optional action button
/// - Haptic feedback on interaction
/// - M3 tonal styling
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
  factory EmptyState.noWashes(
    BuildContext context, {
    VoidCallback? onAddWash,
  }) {
    return EmptyState(
      title: _lt(context, 'emptyNoWashes', 'No Washes Yet'),
      message: _lt(context, 'emptyNoWashesMsg',
          'Start tracking your hair wash routine to see your progress here.'),
      icon: Icons.water_drop_outlined,
      actionLabel:
          onAddWash != null ? _lt(context, 'emptyAddFirst', 'Add First Wash') : null,
      onAction: onAddWash,
    );
  }

  /// Creates an empty state for no data in a date range
  factory EmptyState.noDataInRange(
    BuildContext context, {
    VoidCallback? onAction,
  }) {
    return EmptyState(
      title: _lt(context, 'emptyNoData', 'No Data Available'),
      message: _lt(context, 'emptyNoDataMsg',
          'There are no washes recorded for this time period.'),
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
              color: Theme.of(context).colorScheme.primary,
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
              ),
            if (title != null && message != null) const SizedBox(height: 12),
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            if (customWidget != null) customWidget!,
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
              ),
          ],
        ),
      ),
    );
  }
}

class _SoftIllustration extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;

  const _SoftIllustration({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return NeumorphicContainer(
      borderRadius: 70,
      depth: isDark ? 12 : 15,
      padding: const EdgeInsets.all(28),
      color: isDark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 48,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
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
      title: _lt(context, 'emptyNoStats', 'No Statistics Yet'),
      message: _lt(context, 'emptyNoStatsMsg',
          'Track your hair washes for at least a week to see insightful statistics about your routine.'),
      icon: Icons.analytics_outlined,
      actionLabel:
          onStartTracking != null ? _lt(context, 'emptyStartTracking', 'Start Tracking') : null,
      onAction: onStartTracking,
      customWidget: Column(
        children: [
          _buildFeatureItem(
            context,
            icon: Icons.calendar_month_outlined,
            text: _lt(context, 'featTrack', 'Track wash frequency'),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.trending_up_outlined,
            text: _lt(context, 'featCharts', 'View progress charts'),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            context,
            icon: Icons.schedule_outlined,
            text: _lt(context, 'featOptimize', 'Optimize your routine'),
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
