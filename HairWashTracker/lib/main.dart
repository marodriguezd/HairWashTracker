import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import 'package:hair_wash_tracker/services/data_repository.dart';
import 'package:hair_wash_tracker/services/file_operations_service.dart';
import 'package:hair_wash_tracker/ui/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppController(
        repository: SharedPreferencesRepository(),
        fileOperations: FileOperationsService(),
      ),
      child: MaterialApp(
        title: 'Hair Wash Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
      ),
    );
  }
}
