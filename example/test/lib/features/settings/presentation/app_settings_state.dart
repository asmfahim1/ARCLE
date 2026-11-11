import 'package:flutter/material.dart';

class AppSettingsState {
  AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en', 'US'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
