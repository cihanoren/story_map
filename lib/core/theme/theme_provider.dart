import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_theme.dart';

// Tema durumunu yöneten Provider
class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(AppThemes.lightTheme);

  void toggleTheme() {
    state = (state.brightness == Brightness.dark)
        ? AppThemes.lightTheme
        : AppThemes.darkTheme;
  }
}

// Riverpod Provider tanımlaması
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});
