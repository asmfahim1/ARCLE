  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  
  import '../../../core/localization/app_strings.dart';
  import '../../../core/session_manager/pref_manager.dart';
  import 'app_settings_state.dart';
  
  class AppSettingsCubit extends Cubit<AppSettingsState> {
    AppSettingsCubit(this._prefManager)
        : super(_initialState(_prefManager));
  
    final PrefManager _prefManager;
  
    static AppSettingsState _initialState(PrefManager prefManager) {
      try {
        final savedTheme = prefManager.getString(PrefKeys.themeMode);
        final savedLang = prefManager.getString(PrefKeys.languageCode);
  
        final themeMode =
            savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        var locale = const Locale('en', 'US');
  
        if (savedLang != null &&
            AppStrings.supportedLocales
                .any((loc) => loc.languageCode == savedLang)) {
          locale = Locale(savedLang);
        }
  
        return AppSettingsState(themeMode: themeMode, locale: locale);
      } catch (_) {
        return AppSettingsState();
      }
    }
  
    void toggleTheme(bool dark) {
      emit(state.copyWith(themeMode: dark ? ThemeMode.dark : ThemeMode.light));
      _prefManager.saveString(
        PrefKeys.themeMode,
        dark ? 'dark' : 'light',
      );
    }
  
    void changeLocale(Locale locale) {
      emit(state.copyWith(locale: locale));
      _prefManager.saveString(
        PrefKeys.languageCode,
        locale.languageCode,
      );
    }
  }
  