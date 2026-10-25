class ConstantsTemplates {
  static String appEnums() => '''
enum AppState { initial, loading, success, error, unauthorized }

enum StorageKeys { token, userId, isFirstRun, themeMode }

enum ImageSourceType { network, offline }

enum ButtonShape { rectangular, rounded, circle }
''';

  static String appConstants({String projectName = 'my_app'}) => '''
class AppConstants {
  static const String appName = '$projectName';

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
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color brandPrimaryLight  = Color(0xFF2C3E50);
  static const Color brandPrimaryDark   = Color(0xFF3D9970);
  static const Color accentLight        = Color(0xFF18BC9C);
  static const Color accentDark         = Color(0xFFF39C12);

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color lightBackground    = Color(0xFFF5F7FA);
  static const Color darkBackground     = Color(0xFF0E1116);

  // ── Surfaces (cards, sheets, dialogs) ────────────────────────────────────
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color darkSurface        = Color(0xFF1B2028);

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color lightBorder        = Color(0xFFE0E0E0);
  static const Color darkBorder         = Color(0xFF2E3540);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color lightTextPrimary   = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color darkTextPrimary    = Color(0xFFF1F5F9);
  static const Color darkTextSecondary  = Color(0xFF94A3B8);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color error              = Color(0xFFE74C3C);
  static const Color success            = Color(0xFF27AE60);
  static const Color warning            = Color(0xFFF39C12);
  static const Color info               = Color(0xFF2980B9);

  // ── Neutral / utility ────────────────────────────────────────────────────
  static const Color divider            = Color(0xFFEEEEEE);
  static const Color disabled           = Color(0xFFBDBDBD);
  static const Color overlay            = Color(0x80000000);

  // ── Dynamic Theme Helpers ────────────────────────────────────────────────
  /// Whether the current active theme is dark mode.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Dynamic brand primary color for the current theme brightness.
  static Color primary(BuildContext context) =>
      isDark(context) ? brandPrimaryDark : brandPrimaryLight;

  /// Dynamic accent color for the current theme brightness.
  static Color accent(BuildContext context) =>
      isDark(context) ? accentDark : accentLight;

  /// Dynamic background color for the current theme brightness.
  static Color background(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  /// Dynamic surface color for cards, sheets, dialogs, etc.
  static Color surface(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  /// Dynamic border color for input borders, card outlines, etc.
  static Color border(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  /// Dynamic primary text color for the current theme brightness.
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  /// Dynamic secondary text color for the current theme brightness.
  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;
}
''';
}
