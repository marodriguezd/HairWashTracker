import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/monthly_washes_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hair Wash Tracker'),
        centerTitle: true,
      ),
      drawer: const AppDrawer(),
      body: const Column(
        children: [
          Expanded(child: CalendarWidget()),
          MonthlyWashesWidget(),
        ],
      ),
    );
  }
}
