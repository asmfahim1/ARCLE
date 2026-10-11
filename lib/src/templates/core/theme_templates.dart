class ThemeTemplates {
  static String themeHandler() => '''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

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
      cardTheme: CardThemeData(
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
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimaryLight,
          disabledForegroundColor: AppColors.disabled,
          side: const BorderSide(color: AppColors.brandPrimaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimaryLight,
          disabledForegroundColor: AppColors.disabled,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled;
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryLight;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled;
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryLight;
          return AppColors.lightTextSecondary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled;
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryLight;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled.withValues(alpha: 0.4);
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryLight.withValues(alpha: 0.5);
          return AppColors.lightBorder;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandPrimaryLight,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandPrimaryLight,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brandPrimaryLight,
        unselectedLabelColor: AppColors.lightTextSecondary,
        indicatorColor: AppColors.brandPrimaryLight,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.brandPrimaryLight,
        selectionColor: AppColors.brandPrimaryLight.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.brandPrimaryLight,
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
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: _textTheme.titleMedium?.copyWith(color: AppColors.lightTextPrimary),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.lightTextPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
      cardTheme: CardThemeData(
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
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: Colors.black45,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimaryDark,
          disabledForegroundColor: AppColors.disabled,
          side: const BorderSide(color: AppColors.brandPrimaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandPrimaryDark,
          disabledForegroundColor: AppColors.disabled,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled;
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryDark;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.black),
        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled;
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryDark;
          return AppColors.darkTextSecondary;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled;
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryDark;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.disabled.withValues(alpha: 0.4);
          if (states.contains(WidgetState.selected)) return AppColors.brandPrimaryDark.withValues(alpha: 0.5);
          return AppColors.darkBorder;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brandPrimaryDark,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brandPrimaryDark,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brandPrimaryDark,
        unselectedLabelColor: AppColors.darkTextSecondary,
        indicatorColor: AppColors.brandPrimaryDark,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 12),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.brandPrimaryDark,
        selectionColor: AppColors.brandPrimaryDark.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.brandPrimaryDark,
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
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: _textTheme.titleMedium?.copyWith(color: AppColors.darkTextPrimary),
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: AppColors.darkTextPrimary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
