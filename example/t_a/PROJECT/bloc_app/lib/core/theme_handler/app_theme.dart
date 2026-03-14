import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // All app-wide colors live here.
  static const _brand = Color(0xFF2C3E50);
  static const _accent = Color(0xFF18BC9C);
  static const _surface = Color(0xFFF5F7FA);
  static const _error = Color(0xFFE74C3C);
  static const _darkSurface = Color(0xFF12161C);
  static const _darkBackground = Color(0xFF0E1116);

  // Update typography here to affect all text in the app.
  static final _textTheme = GoogleFonts.poppinsTextTheme(
    const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 15),
    ),
  );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      // Backgrounds and main brand palette.
      colorScheme: ColorScheme.fromSeed(
        seedColor: _brand,
        primary: _brand,
        secondary: _accent,
        surface: _surface,
        error: _error,
      ),
      // Text across the entire app (titles, body, captions).
      textTheme: _textTheme,
      // App-wide background (Scaffold).
      scaffoldBackgroundColor: _surface,
      // App bar styling (top navigation).
      appBarTheme: const AppBarTheme(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      // Bottom navigation bar (legacy).
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _brand,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
      ),
      // Navigation bar (Material 3).
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0x1A2C3E50),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Drawer panel styling.
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        scrimColor: Color(0x662C3E50),
      ),
      // Text fields and input boxes.
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _brand, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      // Dropdowns using Material 3 dropdown menu.
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),
      // Chips (filters, tags).
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFFE8EEF3),
        selectedColor: _brand,
        labelStyle: TextStyle(color: Colors.black87),
        secondaryLabelStyle: TextStyle(color: Colors.white),
      ),
      // Snackbars / lightweight feedback.
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _brand,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.dark,
        primary: _accent,
        secondary: _brand,
        surface: _darkSurface,
        error: _error,
      ),
      textTheme: _textTheme,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1B2028),
        selectedItemColor: _accent,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF1B2028),
        indicatorColor: Color(0x332C3E50),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1B2028),
        scrimColor: Color(0x662C3E50),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1B2028),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1B2028),
          border: OutlineInputBorder(),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF202631),
        selectedColor: _accent,
        labelStyle: TextStyle(color: Colors.white70),
        secondaryLabelStyle: TextStyle(color: Colors.black),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _accent,
        contentTextStyle: TextStyle(color: Colors.black),
      ),
    );
  }
}
