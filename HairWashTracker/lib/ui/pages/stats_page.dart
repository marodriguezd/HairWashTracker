import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: Consumer<AppController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatCard(
                  context,
                  'Total de Lavados',
                  controller.totalWashes.toString(),
                  Icons.soap,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  'Lavados esta Semana',
                  controller.currentWeekWashes.toString(),
                  Icons.calendar_view_week,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  context,
                  'Lavados este Mes',
                  controller.currentMonthWashes.toString(),
                  Icons.calendar_month,
                  Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
