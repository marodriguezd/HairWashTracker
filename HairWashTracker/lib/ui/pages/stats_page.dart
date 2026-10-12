import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_controller.dart';
import '../../models/prediction_result.dart';
import '../../utils/app_theme.dart';
import '../widgets/neumorphic_container.dart';

class StatsPage extends StatelessWidget {
  final bool embed;
  const StatsPage({super.key, this.embed = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<AppController>();

    Widget content = Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.getSeedColor(controller.themePreset).withValues(alpha: 0.15),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Consumer<AppController>(
              builder: (context, controller, child) {
                final nextWash = controller.nextRecommendedWashDate;
                final nextWashStr = nextWash != null
                    ? DateFormat('yyyy-MM-dd').format(nextWash)
                    : 'N/A';
                final confidenceStr = switch (controller.predictionConfidence) {
                  PredictionConfidence.low => 'Low',
                  PredictionConfidence.medium => 'Medium',
                  PredictionConfidence.high => 'High',
                };
                final confidenceIcon = switch (controller.predictionConfidence) {
                  PredictionConfidence.low => Icons.signal_cellular_alt_1_bar_rounded,
                  PredictionConfidence.medium => Icons.signal_cellular_alt_2_bar_rounded,
                  PredictionConfidence.high => Icons.signal_cellular_alt_rounded,
                };
                final trendStr = controller.trendSlope > 0.2
                    ? '↑ Increasing'
                    : controller.trendSlope < -0.2
                        ? '↓ Decreasing'
                        : '→ Stable';

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildNeumorphicStatCard(
                      context,
                      'Total Washes',
                      controller.totalWashes.toString(),
                      Icons.waves_rounded,
                      colorScheme.primary,
                      'All time',
                      delay: 0,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicStatCard(
                      context,
                      'Washes This Week',
                      controller.currentWeekWashes.toString(),
                      Icons.view_week_rounded,
                      colorScheme.secondary,
                      'Past 7 days',
                      delay: 100,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicStatCard(
                      context,
                      'Washes This Month',
                      controller.currentMonthWashes.toString(),
                      Icons.calendar_month_rounded,
                      colorScheme.tertiary,
                      'Past 30 days',
                      delay: 200,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicStatCard(
                      context,
                      'Adaptive Interval',
                      '${controller.adaptiveInterval.toStringAsFixed(1)} days',
                      Icons.auto_graph_rounded,
                      colorScheme.primary,
                      'EWMA prediction',
                      delay: 300,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicStatCard(
                      context,
                      'Model Confidence',
                      confidenceStr,
                      confidenceIcon,
                      colorScheme.tertiary,
                      'Prediction quality',
                      delay: 350,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicStatCard(
                      context,
                      'Interval Trend',
                      trendStr,
                      Icons.trending_up_rounded,
                      colorScheme.secondary,
                      'Recent pattern',
                      delay: 400,
                    ),
                    const SizedBox(height: 16),
                    _buildNeumorphicStatCard(
                      context,
                      'Next Wash Recommended',
                      nextWashStr,
                      Icons.calendar_today_rounded,
                      colorScheme.primary,
                      'Suggested date',
                      delay: 450,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    if (embed) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: content,
    );
  }

  Widget _buildNeumorphicStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle, {
    required int delay,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NeumorphicContainer(
      clipContent: false,
      padding: const EdgeInsets.all(24),
      depth: 4,
      child: Row(
        children: [
          // Flat design icon with radial gradient and single subtle shadow
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: -3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                        border: Border.all(
                          color: color.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        subtitle,
                        style: textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay.clamp(0, 400)))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
