import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';
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
          clipContent: false,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 20 : 28,
            horizontal: isSmallScreen ? 28 : 36,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.tr('monthTitle'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.25,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${controller.currentMonthWashes}',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: -0.5,
                                height: 1.0,
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.waves_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
