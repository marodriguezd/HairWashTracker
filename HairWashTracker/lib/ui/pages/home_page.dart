import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/monthly_washes_widget.dart';
import '../widgets/glass_container.dart';
import '../../utils/animations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
      body: Consumer<AppController>(
        builder: (context, controller, child) {
          return Stack(
            children: [
              _buildAnimatedMeshGradientWrapper(context, colorScheme, controller),
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
          );
        },
      ),
    );
  }

  Widget _buildAnimatedMeshGradientWrapper(
    BuildContext context,
    ColorScheme colorScheme,
    AppController controller,
  ) {
    if (!controller.useComplexAnimations) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
      );
    }

    try {
      return AnimatedMeshGradient(
        child: Container(),
      );
    } catch (e) {
      debugPrint('AnimatedMeshGradient error: $e');
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
      );
    }
  }
}
