class ConstantsTemplates {
  static String appEnums() => '''
enum AppState { initial, loading, success, error, unauthorized }

enum StorageKeys { token, userId, isFirstRun, themeMode }

enum ImageSourceType { network, offline }

enum ButtonShape { rectangular, rounded, circle }
''';

  static String appConstants() => '''
class AppConstants {
  static const String token = 'token';
  static const String isLoggedIn = 'is_logged_in';
  static const String defaultTheme = 'default_theme';
  static const String defaultLanguage = 'default_language';

  static const String dark = 'dark';
  static const String light = 'light';
  static const String bangla = 'bn';
  static const String english = 'en';
}
''';

  static String apiEndpoints() => '''
class ApiEndpoints {
  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';

  // Users endpoints (demo)
  static const String usersList = '/users';
  static const String usersDetail = '/users/{id}';

  // arcle:feature_endpoints
}
''';

  static String appAssets() => '''
class AppAssets {
  static const String _imagePath = "assets/images";
  static const String _iconPath = "assets/icons";

  // Images
  static const String logo = "\$_imagePath/logo.png";
  static const String placeholder = "\$_imagePath/placeholder.png";

  // Icons
  static const String homeIcon = "\$_iconPath/home.svg";
}
''';

  static String appColors() => '''
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color error = Color(0xFFB00020);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
}
''';
}
