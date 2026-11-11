import 'package:flutter/material.dart';
import '../route_handler/app_routes.dart';

class AppDialogs {
  static void showLoader() {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void hideLoader() {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context != null && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Show error alert dialog
  static Future<void> showError(
    String message, {
    String title = 'Error',
    VoidCallback? onDismiss,
  }) async {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog with retry action
  static Future<void> showRetry({
    required String title,
    required String message,
    required VoidCallback onRetry,
    String retryText = 'Retry',
    String cancelText = 'Cancel',
  }) async {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: Text(retryText),
          ),
        ],
      ),
    );
  }

  /// Show success snackbar for 2 seconds
  static void showSuccess(String message) {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
