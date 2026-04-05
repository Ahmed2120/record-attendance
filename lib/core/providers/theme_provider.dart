import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system; // Default to device OS theme
  }

  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }

  void toggleTheme(bool isCurrentlyDark) {
    state = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
