import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(); // Se inicializa en main.dart
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final Ref ref;
  static const _localeKey = 'selected_locale';

  LocaleNotifier(this.ref) : super(null) {
    _loadLocale();
  }

  void _loadLocale() {
    final prefs = ref.read(sharedPreferencesProvider);
    final localeStr = prefs.getString(_localeKey);
    if (localeStr != null) {
      state = Locale(localeStr);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeKey, locale.languageCode);
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref);
});
