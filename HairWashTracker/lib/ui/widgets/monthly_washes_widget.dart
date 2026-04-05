import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
import '../../utils/app_theme.dart';
import 'neumorphic_container.dart';

class MonthlyWashesWidget extends StatelessWidget {
  const MonthlyWashesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Consumer<AppController>(
      builder: (context, controller, child) {
        return NeumorphicContainer(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 20 : 28,
            horizontal: isSmallScreen ? 16 : 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Washes This Month',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.currentMonthWashes}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                ),
                child: Icon(
                  Icons.waves_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
