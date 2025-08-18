import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_controller.dart';

class MonthlyWashesWidget extends StatelessWidget {
  const MonthlyWashesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Lavados este mes: ${controller.currentMonthWashes}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
