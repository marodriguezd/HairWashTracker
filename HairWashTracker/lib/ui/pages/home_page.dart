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

  static const LinearGradient _lightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppTheme.lightGradientStart, AppTheme.lightGradientEnd],
  );

  static const LinearGradient _darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppTheme.darkGradientStart, AppTheme.darkGradientEnd],
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 360 ? 12.0 : 16.0;
    final bottomPadding = screenWidth < 360 ? 12.0 : 16.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Hair Wash Tracker',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? _darkGradient : _lightGradient,
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
