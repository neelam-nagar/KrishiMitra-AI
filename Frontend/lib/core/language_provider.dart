

import 'package:flutter/material.dart';

/// LanguageProvider
/// 👉 Single source of truth for app language
/// 👉 Default language = Hindi
/// 👉 Later whole app will listen to this provider
class LanguageProvider extends ChangeNotifier {
  /// supported languages
  static const String hindi = 'hi';
  static const String english = 'en';

  /// default language (Hindi)
  String _currentLanguage = hindi;

  /// getter
  String get currentLanguage => _currentLanguage;

  /// helper getters (optional but useful)
  bool get isHindi => _currentLanguage == hindi;
  bool get isEnglish => _currentLanguage == english;

  /// change language from anywhere (Profile screen etc.)
  void changeLanguage(String langCode) {
    if (langCode == _currentLanguage) return;

    _currentLanguage = langCode;
    notifyListeners();
  }
}