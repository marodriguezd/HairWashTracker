import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../widgets/glass_container.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Statistics',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient (Same as HomePage for consistency)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.4),
                  colorScheme.secondaryContainer.withOpacity(0.4),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Consumer<AppController>(
              builder: (context, controller, child) {
                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildGlassStatCard(
                      context,
                      'Total Washes',
                      controller.totalWashes.toString(),
                      Icons.waves_rounded,
                      colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassStatCard(
                      context,
                      'Washes This Week',
                      controller.currentWeekWashes.toString(),
                      Icons.view_week_rounded,
                      colorScheme.secondary,
                    ),
                    const SizedBox(height: 16),
                    _buildGlassStatCard(
                      context,
                      'Washes This Month',
                      controller.currentMonthWashes.toString(),
                      Icons.calendar_month_rounded,
                      colorScheme.tertiary,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(24.0),
      blur: 20,
      opacity: 0.1,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
