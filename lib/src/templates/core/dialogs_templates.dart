import '../../state_management.dart';

class DialogsTemplates {
  static String dialogs(StateManagement state) {
    if (state == StateManagement.getx) {
      return _getxDialogs();
    }
    return _contextDialogs();
  }

  static String _contextDialogs() => '''
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

  static void showError(String message) {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

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
''';

  static String _getxDialogs() => '''
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AppDialogs {
  static void showLoader() {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  static void hideLoader() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static Future<bool> showConfirm({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
''';
}
