import 'package:flutter/material.dart';

class CommonSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white),
        ),
        backgroundColor: backgroundColor ?? Colors.grey[800],
        duration: duration,
      ),
    );
  }

  static void error(
    BuildContext context, {
    required String message,
  }) {
    show(context, message: message, backgroundColor: Colors.red);
  }

  static void success(
    BuildContext context, {
    required String message,
  }) {
    show(context, message: message, backgroundColor: Colors.green);
  }
}
