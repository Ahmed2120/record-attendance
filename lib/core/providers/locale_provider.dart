import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the current Locale. Defaults to null so MaterialApp uses the device system language.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    return null; 
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void clearLocale() {
    state = null;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(() {
  return LocaleNotifier();
});
