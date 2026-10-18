import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hair_wash_tracker/providers/app_controller.dart';
import 'package:hair_wash_tracker/services/data_repository.dart';
import 'package:hair_wash_tracker/services/file_operations_service.dart';
import 'package:hair_wash_tracker/l10n/app_localizations.dart';
import 'package:hair_wash_tracker/models/theme_preference.dart';
import 'package:hair_wash_tracker/ui/pages/home_page.dart';
import 'package:hair_wash_tracker/utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

ThemeMode _themeModeFor(AppThemeMode mode) => switch (mode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };

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
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              // System dynamic color applies only when the user kept it
              // enabled in Settings; otherwise the seed preset always wins.
              final light = AppTheme.getTheme(
                controller.themePreset,
                Brightness.light,
                dynamicScheme:
                    controller.useDynamicColor ? lightDynamic : null,
              );
              final dark = AppTheme.getTheme(
                controller.themePreset,
                Brightness.dark,
                dynamicScheme:
                    controller.useDynamicColor ? darkDynamic : null,
              );
              return MaterialApp(
                title: 'Hair Wash Tracker',
                debugShowCheckedModeBanner: false,
                themeMode: _themeModeFor(controller.themeMode),
                theme: light,
                darkTheme: dark,
                locale: controller.flutterLocale,
                supportedLocales:
                    AppLanguage.supported.map((l) => l.locale).toList(),
                home: const HomePage(),
              );
            },
          );
        },
      ),
    );
  }
}
