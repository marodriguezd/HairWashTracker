import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import 'package:hair_wash_tracker/services/data_repository.dart';
import 'package:hair_wash_tracker/services/file_operations_service.dart';
import 'package:hair_wash_tracker/ui/pages/home_page.dart';
import 'models/theme_preference.dart';

void main() {
  runApp(const MyApp());
}

ThemeMode _appThemeModeToThemeMode(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
  }
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
      child: Consumer<AppController>(
        builder: (context, controller, _) {
          return MaterialApp(
            title: 'Hair Wash Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: _appThemeModeToThemeMode(controller.themeMode),
            theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.deepPurple,
              brightness: Brightness.light,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.deepPurple,
              brightness: Brightness.dark,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
