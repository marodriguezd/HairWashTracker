import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/monthly_washes_widget.dart';
import '../widgets/neumorphic_container.dart';
import '../../utils/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final bottomPadding = screenWidth < 360 ? 12.0 : 16.0;

    final gradientColors = AppTheme.getGradientColors(
      controller.themePreset,
      isDark ? Brightness.dark : Brightness.light,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Hair Wash Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: horizontalPadding),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: const _CalendarGestureDetector(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(bottomPadding),
                child: const MonthlyWashesWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarGestureDetector extends StatelessWidget {
  const _CalendarGestureDetector();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        HapticFeedback.lightImpact();
        if (details.primaryVelocity! > 0) {
          context.read<AppController>().previousMonth();
        } else if (details.primaryVelocity! < 0) {
          context.read<AppController>().nextMonth();
        }
      },
      child: const NeumorphicContainer(
        child: CalendarWidget(),
      ),
    );
  }
}
