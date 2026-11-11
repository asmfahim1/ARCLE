import 'package:flutter/material.dart';
import '../theme_manager/app_colors.dart';

class CommonSnackbar {
  // Default background/text colors come from AppColors.primary(context) or AppTheme.
  // [backgroundColor]/[textColor] let a call site override just this one snackbar.
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    final effectiveBg = backgroundColor ?? AppColors.primary(context);
    final effectiveText = textColor ?? Colors.white;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: effectiveText),
        ),
        backgroundColor: effectiveBg,
        duration: duration,
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }

  static void success(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
  }) {
    show(
      context,
      message: message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
    );
  }
}
