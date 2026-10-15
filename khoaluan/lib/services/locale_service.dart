import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _storageKey = 'app_language_code';
  static const supportedLanguageCodes = {'vi', 'en'};

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('vi'));

  static Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedCode = preferences.getString(_storageKey);
    final browserCode = PlatformDispatcher.instance.locale.languageCode;
    final initialCode = supportedLanguageCodes.contains(savedCode)
        ? savedCode!
        : supportedLanguageCodes.contains(browserCode)
        ? browserCode
        : 'vi';
    locale.value = Locale(initialCode);
  }

  static Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguageCodes.contains(languageCode) ||
        locale.value.languageCode == languageCode) {
      return;
    }
    locale.value = Locale(languageCode);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, languageCode);
  }
}
