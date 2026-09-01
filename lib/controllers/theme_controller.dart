import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;

    notifyListeners();
  }
}