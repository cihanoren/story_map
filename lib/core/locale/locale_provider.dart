import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Desteklenen diller
const supportedLanguages = ['en', 'tr', 'de', 'fr', 'es' ,'it','ru','ar'];

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('preferred_language_code');

    if (code != null && supportedLanguages.contains(code)) {
      state = Locale(code);
    } else {
      // Kayıt yoksa cihaz dilini al
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = supportedLanguages.contains(locale.languageCode)
          ? locale.languageCode
          : 'en'; // desteklenmeyen dilse İngilizce
      state = Locale(languageCode);

      // SharedPreferences'a kaydet
      await prefs.setString('preferred_language_code', languageCode);
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLanguages.contains(locale.languageCode)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_language_code', locale.languageCode);
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);
