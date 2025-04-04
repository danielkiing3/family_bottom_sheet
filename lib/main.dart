import 'package:family_bottom_sheet/src/presentation/home_screen.dart';
import 'package:family_bottom_sheet/src/theme/app_theme.dart';
import 'package:family_bottom_sheet/src/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeModeNotifierProvider(
      themeModeNotifier: ThemeModeNotifier(),
      child: Builder(
        builder: (context) {
          return ValueListenableBuilder(
            valueListenable: ThemeModeNotifierProvider.of(context),
            builder: (context, themeMode, _) {
              return MaterialApp(
                title: 'Family Tray Animation',
                themeMode: themeMode,
                theme: AppTheme.lightTheme,
                highContrastTheme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                highContrastDarkTheme: AppTheme.darkTheme,
                // debugShowCheckedModeBanner: false,
                home: HomeScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
