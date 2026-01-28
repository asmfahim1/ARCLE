import '../../state_management.dart';

class LocalizationTemplates {
  static String appStrings(StateManagement state) {
    if (state == StateManagement.getx) {
      return _getxAppStrings();
    }
    return _defaultAppStrings();
  }

  static String enJson() => '''
{
  "login_title": "Login",
  "login_hint": "Use your demo credentials to continue.",
  "email": "Email",
  "password": "Password",
  "login": "Login",
  "settings": "Settings",
  "user_list": "User List",
  "retry": "Retry",
  "theme": "Theme",
  "dark_mode": "Dark mode",
  "language": "Language"
}
''';

  static String bnJson() => '''
{
  "login_title": "লগইন",
  "login_hint": "ডেমো ক্রেডেনশিয়াল দিয়ে চালিয়ে যান।",
  "email": "ইমেইল",
  "password": "পাসওয়ার্ড",
  "login": "লগইন",
  "settings": "সেটিংস",
  "user_list": "ইউজার লিস্ট",
  "retry": "আবার চেষ্টা করুন",
  "theme": "থিম",
  "dark_mode": "ডার্ক মোড",
  "language": "ভাষা"
}
''';

  static String getxLocalization() => '''
import 'package:get/get.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'login_title': 'Login',
          'login_hint': 'Use your demo credentials to continue.',
          'email': 'Email',
          'password': 'Password',
          'login': 'Login',
          'settings': 'Settings',
          'user_list': 'User List',
          'retry': 'Retry',
          'theme': 'Theme',
          'dark_mode': 'Dark mode',
          'language': 'Language',
          // arcle:keys_en
        },
        'bn_BD': {
          'login_title': 'লগইন',
          'login_hint': 'ডেমো ক্রেডেনশিয়াল দিয়ে চালিয়ে যান।',
          'email': 'ইমেইল',
          'password': 'পাসওয়ার্ড',
          'login': 'লগইন',
          'settings': 'সেটিংস',
          'user_list': 'ইউজার লিস্ট',
          'retry': 'আবার চেষ্টা করুন',
          'theme': 'থিম',
          'dark_mode': 'ডার্ক মোড',
          'language': 'ভাষা',
          // arcle:keys_bn
        },
      };
}
''';

  static String _getxAppStrings() => '''
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppStrings {
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('bn', 'BD'),
  ];
}

extension AppLocalizationX on BuildContext {
  String tr(String key) => key.tr;
}
''';

  static String _defaultAppStrings() => '''
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppStrings {
  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('bn', 'BD'),
  ];
}

extension AppLocalizationX on BuildContext {
  String tr(String key) => AppLocalizations.of(this)?.translate(key) ?? key;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of(context, AppLocalizations);
  }

  late Map<String, String> _localizedStrings;

  Future<void> load() async {
    final jsonString = await rootBundle
        .loadString('assets/langs/\${locale.languageCode}.json');
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
  }

  String translate(String key) => _localizedStrings[key] ?? key;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
''';
}
