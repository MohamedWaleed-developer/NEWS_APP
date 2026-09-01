import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'controllers/language_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageController = LanguageController();
  await languageController.loadLanguage();

  runApp(
    MyApp(
      languageController: languageController,
    ),
  );
}

class MyApp extends StatelessWidget {
  final LanguageController languageController;
  final ThemeController themeController = ThemeController();

  MyApp({
    super.key,
    required this.languageController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        themeController,
        languageController,
      ]),
      builder: (context, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: languageController.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xffF7F7F9),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xff6C5CE7),
                  brightness: Brightness.light,
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xff101010),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xff8B7CF6),
                  brightness: Brightness.dark,
                ),
              ),
              themeMode: themeController.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: HomeScreen(
                themeController: themeController,
                languageController: languageController,
              ),
            );
          },
        );
      },
    );
  }
}