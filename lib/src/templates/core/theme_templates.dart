class ThemeTemplates {
  static String themeHandler() => '''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class AppTheme {
  AppTheme._();

  static final _textTheme = GoogleFonts.poppinsTextTheme(
    const TextTheme(
      displayLarge:  TextStyle(fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleMedium:   TextStyle(fontWeight: FontWeight.w600),
      bodyMedium:    TextStyle(fontSize: 15),
    ),
  );

  // ── LIGHT THEME ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.brandPrimaryLight,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary:    AppColors.brandPrimaryLight,
        secondary:  AppColors.accentLight,
        surface:    AppColors.lightSurface,
        error:      AppColors.error,
        onPrimary:  Colors.white,
        onSecondary: Colors.white,
        onSurface:  AppColors.lightTextPrimary,
        onError:    Colors.white,
      ),
      textTheme: _textTheme.apply(
        bodyColor:    AppColors.lightTextPrimary,
        displayColor: AppColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimaryLight,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimaryLight,
          side: const BorderSide(color: AppColors.brandPrimaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandPrimaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.brandPrimaryLight,
        unselectedItemColor: AppColors.lightTextSecondary,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: Color(0x1A2C3E50),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.lightSurface,
        scrimColor: AppColors.overlay,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedColor: AppColors.brandPrimaryLight,
        labelStyle: TextStyle(color: AppColors.lightTextPrimary),
        secondaryLabelStyle: TextStyle(color: Colors.white),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.brandPrimaryLight,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  // ── DARK THEME ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.brandPrimaryDark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.brandPrimaryDark,
        secondary:  AppColors.accentDark,
        surface:    AppColors.darkSurface,
        error:      AppColors.error,
        onPrimary:  Colors.white,
        onSecondary: Colors.black,
        onSurface:  AppColors.darkTextPrimary,
        onError:    Colors.white,
      ),
      textTheme: _textTheme.apply(
        bodyColor:    AppColors.darkTextPrimary,
        displayColor: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimaryDark,
          side: const BorderSide(color: AppColors.brandPrimaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.brandPrimaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.brandPrimaryDark,
        unselectedItemColor: AppColors.darkTextSecondary,
        showUnselectedLabels: true,
        elevation: 8,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: Color(0x333D9970),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        scrimColor: AppColors.overlay,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedColor: AppColors.brandPrimaryDark,
        labelStyle: TextStyle(color: AppColors.darkTextPrimary),
        secondaryLabelStyle: TextStyle(color: Colors.black),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.brandPrimaryDark,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
''';
}
