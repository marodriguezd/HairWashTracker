import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_controller.dart';
import '../../models/prediction_result.dart';
import '../../utils/app_theme.dart';
import '../widgets/empty_state.dart';

class StatsPage extends StatelessWidget {
  final bool embed;

  /// Invoked by the empty state so the shell can switch to the calendar.
  final VoidCallback? onAddWash;

  const StatsPage({super.key, this.embed = false, this.onAddWash});

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
                child: EmptyState.noWashes(context, onAddWash: onAddWash),
              ),
            );
          }

          final nextWash = controller.nextRecommendedWashDate;
          // The prediction date is user-facing, so it follows the active UI
          // language instead of intl's default English locale.
          final nextWashStr = nextWash != null
              ? DateFormat.MMMEd(
                      Localizations.localeOf(context).toLanguageTag())
                  .format(nextWash)
              : controller.tr('statsKeepLogging');
          final confidenceStr = switch (controller.predictionConfidence) {
            PredictionConfidence.low => controller.tr('confLow'),
            PredictionConfidence.medium => controller.tr('confMedium'),
            PredictionConfidence.high => controller.tr('confHigh'),
          };
          final confidenceIcon = switch (controller.predictionConfidence) {
            PredictionConfidence.low => Icons.signal_cellular_alt_1_bar_rounded,
            PredictionConfidence.medium =>
              Icons.signal_cellular_alt_2_bar_rounded,
            PredictionConfidence.high => Icons.signal_cellular_alt_rounded,
          };
          final trendStr = controller.trendSlope > 0.2
              ? controller.tr('trendUp')
              : controller.trendSlope < -0.2
                  ? controller.tr('trendDown')
                  : controller.tr('trendFlat');
          final trendIcon = controller.trendSlope > 0.2
              ? Icons.trending_up_rounded
              : controller.trendSlope < -0.2
                  ? Icons.trending_down_rounded
                  : Icons.trending_flat_rounded;

          return Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppTheme.contentMaxWidth),
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingScreen),
                children: [
                  Card(
                    color: colorScheme.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
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
                                controller.tr('statsNextWash'),
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusButton),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      confidenceIcon,
                                      size: 16,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
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
                            controller.tr('statsCalcDesc'),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    controller.tr('statsCadence'),
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
                        child: _buildMetricTile(
                          context,
                          title: controller.tr('statsInterval'),
                          value:
                              '${controller.adaptiveInterval.toStringAsFixed(1)} d',
                          icon: Icons.timelapse_rounded,
                          color: colorScheme.primary,
                          subtitle: controller.tr('statsEwma'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          title: controller.tr('statsTrend'),
                          value: trendStr,
                          icon: trendIcon,
                          color: colorScheme.secondary,
                          subtitle: controller.tr('statsRecentPace'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          title: controller.tr('statsAverage'),
                          value: _formatInterval(controller.averageInterval,
                              controller.totalWashes),
                          icon: Icons.functions_rounded,
                          color: colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricTile(
                          context,
                          title: controller.tr('statsMedian'),
                          value: _formatInterval(controller.medianInterval,
                              controller.totalWashes),
                          icon: Icons.horizontal_rule_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    controller.tr('statsVolume'),
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildVolumeColumn(
                              context,
                              count: controller.totalWashes,
                              label: controller.tr('statsAllTime'),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          Expanded(
                            child: _buildVolumeColumn(
                              context,
                              count: controller.currentWeekWashes,
                              label: controller.tr('statsThisWeek'),
                            ),
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                          Expanded(
                            child: _buildVolumeColumn(
                              context,
                              count: controller.currentMonthWashes,
                              label: controller.tr('statsThisMonth'),
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
        },
      ),
    );

    if (embed) return content;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              Provider.of<AppController>(context, listen: false).tr('pageStatistics'))),
      body: content,
    );
  }

  /// A single wash has no interval; rendering `0.0 d` would read as daily
  /// washing, so the tiles stay blank until a second wash exists.
  static String _formatInterval(double days, int washCount) =>
      washCount < 2 ? '—' : '${days.toStringAsFixed(1)} d';

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    String? subtitle,
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
}
