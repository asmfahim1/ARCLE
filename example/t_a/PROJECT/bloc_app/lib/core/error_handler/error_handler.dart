import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_failure.dart';
import '../utils/logger.dart';

/// Centralized error handler for the application.
/// 
/// Features:
/// - Converts failures to user-friendly messages
/// - Provides UI helpers for showing errors
/// - Supports error recovery actions
/// - Logs errors for debugging
/// 
/// Usage:
/// ```dart
/// // In repository/usecase:
/// result.fold(
///   (failure) => ErrorHandler.handle(context, failure),
///   (data) => showData(data),
/// );
/// 
/// // Or with recovery action:
/// ErrorHandler.handleWithRecovery(
///   context,
///   failure,
///   onRetry: () => fetchData(),
/// );
/// ```
class ErrorHandler {
  /// Global error callback for custom handling
  static void Function(AppFailure failure)? onError;
  
  /// Handle failure and show appropriate UI feedback
  static void handle(BuildContext context, AppFailure failure) {
    AppLogger.error('Error handled', tag: 'ERROR', error: failure.message);
    onError?.call(failure);
    
    final message = _getUserMessage(failure);
    showErrorSnackBar(context, message);
  }
  
  /// Handle failure with retry option
  static void handleWithRecovery(
    BuildContext context,
    AppFailure failure, {
    required VoidCallback onRetry,
    String? retryLabel,
  }) {
    final message = _getUserMessage(failure);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: retryLabel ?? 'Retry',
          onPressed: onRetry,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  /// Show error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    AppFailure failure, {
    String? title,
    VoidCallback? onDismiss,
  }) async {
    final message = _getUserMessage(failure);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Show simple error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
  
  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
  
  /// Convert failure to user-friendly message
  static String _getUserMessage(AppFailure failure) {
    return failure.when(
      network: (msg) => 'No internet connection. Please check your network and try again.',
      server: (msg, code) => msg.isNotEmpty ? msg : 'Server error occurred. Please try again later.',
      timeout: (msg) => 'Request timed out. Please check your connection and try again.',
      unauthorized: (msg) => 'Session expired. Please login again.',
      notFound: (msg) => msg.isNotEmpty ? msg : 'The requested resource was not found.',
      validation: (msg) => msg,
      cache: (msg) => 'Unable to load cached data.',
      unknown: (msg, error) => kDebugMode ? msg : 'Something went wrong. Please try again.',
    );
  }
  
  /// Check if failure requires re-authentication
  static bool requiresReAuth(AppFailure failure) {
    return failure is UnauthorizedFailure;
  }
  
  /// Check if failure is recoverable (user can retry)
  static bool isRecoverable(AppFailure failure) {
    return failure is NetworkFailure || 
           failure is TimeoutFailure || 
           failure is ServerFailure;
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  void handleError(AppFailure failure) {
    ErrorHandler.handle(context, failure);
  }
  
  void handleErrorWithRetry(AppFailure failure, VoidCallback onRetry) {
    ErrorHandler.handleWithRecovery(context, failure, onRetry: onRetry);
  }
}
