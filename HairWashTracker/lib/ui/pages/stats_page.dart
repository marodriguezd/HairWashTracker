import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_controller.dart';
import '../../models/prediction_result.dart';
import '../../utils/app_theme.dart';
import '../widgets/empty_state.dart';

class StatsPage extends StatelessWidget {
  final bool embed;
  const StatsPage({super.key, this.embed = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content = SafeArea(
      child: Consumer<AppController>(
        builder: (context, controller, child) {
          if (controller.totalWashes == 0) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingScreen),
                child: EmptyState.noWashes(),
              ),
            );
          }

          final nextWash = controller.nextRecommendedWashDate;
          final nextWashStr = nextWash != null
              ? DateFormat('EEE, MMM d').format(nextWash)
              : 'Keep logging washes';
          final confidenceStr = switch (controller.predictionConfidence) {
            PredictionConfidence.low => 'Low confidence',
            PredictionConfidence.medium => 'Medium confidence',
            PredictionConfidence.high => 'High confidence',
          };
          final confidenceIcon = switch (controller.predictionConfidence) {
            PredictionConfidence.low => Icons.signal_cellular_alt_1_bar_rounded,
            PredictionConfidence.medium => Icons.signal_cellular_alt_2_bar_rounded,
            PredictionConfidence.high => Icons.signal_cellular_alt_rounded,
          };
          final trendStr = controller.trendSlope > 0.2
              ? 'Increasing'
              : controller.trendSlope < -0.2
                  ? 'Decreasing'
                  : 'Stable';
          final trendIcon = controller.trendSlope > 0.2
              ? Icons.trending_up_rounded
              : controller.trendSlope < -0.2
                  ? Icons.trending_down_rounded
                  : Icons.trending_flat_rounded;

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingScreen),
            children: [
              // Hero card: Next Recommended Wash
              Card(
                color: colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard + 4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Next Recommended Wash',
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(confidenceIcon, size: 16, color: colorScheme.onPrimaryContainer),
                                const SizedBox(width: 4),
                                Text(
                                  confidenceStr,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        nextWashStr,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calculated from your EWMA routine model and recent washing cadence',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Routine cadence',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.75,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNeumorphicStatCard(
                      context,
                      'Interval',
                      '${controller.adaptiveInterval.toStringAsFixed(1)} d',
                      Icons.timelapse_rounded,
                      colorScheme.primary,
                      'EWMA cadence',
                      delay: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNeumorphicStatCard(
                      context,
                      'Trend',
                      trendStr,
                      trendIcon,
                      colorScheme.secondary,
                      'Recent pace',
                      delay: 150,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Volume overview',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.75,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildVolumeColumn(
                          context,
                          count: controller.totalWashes,
                          label: 'All time',
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      Expanded(
                        child: _buildVolumeColumn(
                          context,
                          count: controller.currentWeekWashes,
                          label: 'This week',
                        ),
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      Expanded(
                        child: _buildVolumeColumn(
                          context,
                          count: controller.currentMonthWashes,
                          label: 'This month',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (embed) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: content,
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeColumn(
    BuildContext context, {
    required int count,
    required String label,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          '$count',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Legacy shim maintained for compatibility with existing tests
  Widget _buildNeumorphicStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle, {
    required int delay,
  }) {
    return _buildMetricTile(
      context,
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      color: color,
    );
  }
}
