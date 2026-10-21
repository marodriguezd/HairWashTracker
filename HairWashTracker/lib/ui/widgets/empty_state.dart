import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../../utils/haptics.dart';
import '../../utils/app_theme.dart';
import 'tonal_card.dart';

/// Reads a localized string, falling back to [fallback] when no
/// [AppController] is available above this context.
String _lt(BuildContext context, String key, String fallback) {
  try {
    return Provider.of<AppController>(context, listen: false).tr(key);
  } catch (_) {
    return fallback;
  }
}

/// Placeholder shown when the statistics have nothing to summarize yet.
///
/// One primitive covers the only empty state the app renders: no washes at all,
/// with an optional action that takes the user to the calendar.
class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  /// Creates the empty state for a history without any wash.
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
            _SoftIllustration(icon: effectiveIcon),
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
            if (actionLabel != null && onAction != null)
              TonalCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                borderRadius: AppTheme.radiusCard,
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

  const _SoftIllustration({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TonalCard(
      borderRadius: 70,
      padding: const EdgeInsets.all(28),
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
