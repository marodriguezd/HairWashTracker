import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/monthly_washes_widget.dart';
import '../widgets/glass_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Hair Wash Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.4),
                  Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.4),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GestureDetector(
                      onHorizontalDragEnd: (DragEndDetails details) {
                        if (details.primaryVelocity! > 0) {
                          context.read<AppController>().previousMonth();
                        } else if (details.primaryVelocity! < 0) {
                          context.read<AppController>().nextMonth();
                        }
                      },
                      child: GlassContainer(
                        blur: 20,
                        opacity: 0.1,
                        child: const CalendarWidget(),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: MonthlyWashesWidget(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
