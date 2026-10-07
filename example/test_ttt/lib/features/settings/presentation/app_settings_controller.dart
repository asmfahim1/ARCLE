  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import '../../../core/localization/app_strings.dart';
  import '../../../core/session_manager/pref_manager.dart';
  
  class AppSettingsController extends GetxController {
    final PrefManager _prefManager = Get.find<PrefManager>();
    final themeMode = ThemeMode.light.obs;
    final locale = const Locale('en', 'US').obs;
  
    @override
    void onInit() {
      super.onInit();
      loadFromPrefs();
    }
  
    Future<void> loadFromPrefs() async {
      try {
        final savedTheme = await _prefManager.getString(PrefKeys.themeMode);
        final savedLang = await _prefManager.getString(PrefKeys.languageCode);
  
        if (savedTheme != null) {
          themeMode.value =
              savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
          Get.changeThemeMode(themeMode.value);
        }
  
        if (savedLang != null &&
            AppStrings.supportedLocales
                .any((loc) => loc.languageCode == savedLang)) {
          final newLocale = Locale(savedLang);
          locale.value = newLocale;
          Get.updateLocale(newLocale);
        }
      } catch (_) {
        // Use defaults if preferences are unavailable.
      }
    }
  
    void toggleTheme(bool dark) {
      themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
      Get.changeThemeMode(themeMode.value);
      _prefManager.saveString(
        PrefKeys.themeMode,
        dark ? 'dark' : 'light',
      );
    }
  
    void changeLocale(Locale value) {
      locale.value = value;
      Get.updateLocale(value);
      _prefManager.saveString(
        PrefKeys.languageCode,
        value.languageCode,
      );
    }
  }
  