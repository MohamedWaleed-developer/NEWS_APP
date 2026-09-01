import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  Future<void> loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_languageKey);

    if (languageCode == 'ar') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('en');
    }

    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final preferences = await SharedPreferences.getInstance();

    if (isArabic) {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }

    await preferences.setString(
      _languageKey,
      _locale.languageCode,
    );

    notifyListeners();
  }
}