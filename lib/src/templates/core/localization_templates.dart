import '../../state_management.dart';

class LocalizationTemplates {
  // ─── Locale metadata ───────────────────────────────────────────────────────

  /// Maps an ISO 639-1 language code to its most common country/region code.
  /// Falls back to the language code uppercased for unknown codes.
  static String countryCode(String langCode) {
    const codes = <String, String>{
      'en': 'US', 'bn': 'BD', 'my': 'MM', 'ar': 'SA',
      'fr': 'FR', 'de': 'DE', 'es': 'ES', 'zh': 'CN',
      'hi': 'IN', 'ja': 'JP', 'ko': 'KR', 'pt': 'BR',
      'ru': 'RU', 'it': 'IT', 'tr': 'TR', 'vi': 'VN',
      'th': 'TH', 'id': 'ID', 'ms': 'MY', 'ur': 'PK',
      'nl': 'NL', 'pl': 'PL', 'uk': 'UA', 'fa': 'IR',
      'he': 'IL', 'sw': 'KE', 'ro': 'RO', 'cs': 'CZ',
      'hu': 'HU', 'el': 'GR', 'fi': 'FI', 'sv': 'SE',
      'da': 'DK', 'nb': 'NO', 'sk': 'SK', 'bg': 'BG',
      'hr': 'HR', 'sr': 'RS', 'lt': 'LT', 'lv': 'LV',
      'et': 'EE', 'sl': 'SI', 'ka': 'GE', 'az': 'AZ',
      'kk': 'KZ', 'uz': 'UZ', 'af': 'ZA', 'sq': 'AL',
      'hy': 'AM', 'be': 'BY', 'bs': 'BA', 'mk': 'MK',
      'mn': 'MN', 'ne': 'NP', 'si': 'LK', 'tl': 'PH',
      'ta': 'IN', 'te': 'IN', 'ml': 'IN', 'kn': 'IN',
      'gu': 'IN', 'pa': 'PK', 'am': 'ET', 'so': 'SO',
      'km': 'KH', 'lo': 'LA', 'bo': 'CN', 'ky': 'KG',
      'tg': 'TJ', 'tk': 'TM',
    };
    return codes[langCode.toLowerCase()] ?? langCode.toUpperCase();
  }

  // ─── Per-locale JSON ───────────────────────────────────────────────────────

  /// Returns the translation JSON for a locale.
  /// Known locales (en, bn) get their curated translation.
  /// All other locales get an English-value placeholder so the app won't crash.
  static String localeJson(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'en':
        return enJson();
      case 'bn':
        return bnJson();
      default:
        return _placeholderJson();
    }
  }

  static String _placeholderJson() => '''
{
  "login_title": "Login",
  "login_hint": "Use your credentials to continue.",
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

  // ─── Initial single-locale dart files ─────────────────────────────────────

  /// Generates app_strings.dart with a single locale entry.
  /// Subsequent locales are added by [add_command] via string manipulation.
  static String initialAppStrings(
    StateManagement state,
    String langCode,
    String country,
  ) {
    if (state == StateManagement.getx) {
      return _initialGetxAppStrings(langCode, country);
    }
    return _initialDefaultAppStrings(langCode, country);
  }

  static String _initialDefaultAppStrings(
    String langCode,
    String country,
  ) =>
      '''
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppStrings {
  static const supportedLocales = [
    Locale('$langCode', '$country'),
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
      ['$langCode'].contains(locale.languageCode);

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

  static String _initialGetxAppStrings(String langCode, String country) => '''
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AppStrings {
  static const supportedLocales = [
    Locale('$langCode', '$country'),
  ];
}

extension AppLocalizationX on BuildContext {
  String tr(String key) => key.tr;
}
''';

  /// Generates getx_localization.dart with a single locale entry.
  static String initialGetxLocalization(String langCode, String country) => '''
import 'package:get/get.dart';

class Language extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        '${langCode}_$country': {
          'welcome': 'Welcome',
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
          // arcle:keys_$langCode
        },
      };
}
''';


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
          'welcome': 'Welcome',
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
          'welcome': 'সবগতম',
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
