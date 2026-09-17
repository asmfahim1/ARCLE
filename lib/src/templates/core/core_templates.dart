class CoreTemplates {
  static String responseHandler() => '''
import 'package:dio/dio.dart';

import '../response_handler/api_failure.dart';
import '../utils/result.dart';

/// Centralized response handler for API calls.
/// 
/// Provides consistent parsing, error handling, and logging across all API calls.
/// 
/// Usage:
/// ```dart
/// final result = await ResponseHandler.handle(
///   () => apiService.get('/users'),
///   fromJson: (json) => User.fromJson(json),
/// );
/// 
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showUser(user),
/// );
/// ```
class ResponseHandler {
  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static List<Map<String, dynamic>> _toMapList(List<dynamic> source) {
    return source
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static bool _isSuccessStatus(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  /// Handle a single object response
  static Future<Result<T>> handle<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data == null) {
        return Results.failure(const ServerFailure('Empty response'));
      }

      final mapData = _asMap(data);
      if (mapData == null) {
        return Results.failure(const ServerFailure('Invalid response format'));
      }

      if (mapData.containsKey('success') && mapData['success'] == false) {
        return Results.failure(AppFailure.fromResponse(response));
      }

      final payload = mapData['data'] ?? mapData['result'] ?? mapData['payload'];
      final payloadMap = _asMap(payload) ?? mapData;
      return Results.success(fromJson(payloadMap));
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle a list response
  static Future<Result<List<T>>> handleList<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data == null) {
        return Results.success([]);
      }
      
      List<Map<String, dynamic>> items;
      
      if (data is List) {
        items = _toMapList(data);
      } else if (data is Map<String, dynamic>) {
        // Handle BaseResponse wrapper
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(AppFailure.fromResponse(response));
        }
        final payload = data['data'] ?? data['result'] ?? data['payload'] ?? data;
        if (payload is List) {
          items = _toMapList(payload);
        } else if (payload is Map<String, dynamic>) {
          final nestedList =
              payload['items'] ?? payload['results'] ?? payload['data'];
          items = nestedList is List ? _toMapList(nestedList) : [];
        } else {
          items = [];
        }
      } else {
        return Results.success([]);
      }
      
      return Results.success(
        items.map(fromJson).toList(),
      );
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle paginated response
  static Future<Result<PaginatedResponse<T>>> handlePaginated<T>({
    required Future<Response<dynamic>> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data == null || data is! Map<String, dynamic>) {
        return Results.success(PaginatedResponse.empty());
      }
      
      if (data.containsKey('success') && data['success'] == false) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      
      return Results.success(PaginatedResponse.fromJson(data, fromJson));
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle void response (no data expected)
  static Future<Result<void>> handleVoid({
    required Future<Response<dynamic>> Function() request,
    String? tag,
  }) async {
    try {
      final response = await request();
      if (!_isSuccessStatus(response.statusCode)) {
        return Results.failure(AppFailure.fromResponse(response));
      }
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(AppFailure.fromResponse(response));
        }
      }
      
      return Results.success(null);
    } on DioException catch (e) {
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
}

/// Model for paginated API responses
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int totalItems;
  final bool hasMore;
  
  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
    required this.hasMore,
  });
  
  factory PaginatedResponse.empty() => const PaginatedResponse(
    items: [],
    page: 1,
    totalPages: 1,
    totalItems: 0,
    hasMore: false,
  );
  
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data = _asMap(json['data']) ?? json;
    final rawItemsDynamic = data['items'] ?? data['results'] ?? data['data'];
    final rawItems = rawItemsDynamic is List ? rawItemsDynamic : <dynamic>[];
    final meta = _asMap(json['meta']) ?? _asMap(json['pagination']) ?? json;

    final page = _asInt(meta['page']) ?? _asInt(meta['current_page']) ?? 1;
    final totalPages =
        _asInt(meta['total_pages']) ?? _asInt(meta['last_page']) ?? 1;
    final totalItems =
        _asInt(meta['total']) ?? _asInt(meta['total_items']) ?? rawItems.length;
    
    return PaginatedResponse(
      items: rawItems
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(),
      page: page,
      totalPages: totalPages,
      totalItems: totalItems,
      hasMore: page < totalPages,
    );
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
''';

  static String errorHandler() => '''
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../response_handler/api_failure.dart';
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
    if (failure is ValidationFailure) {
      return failure.displayMessage;
    }
    return failure.when(
      network: (msg) => 'No internet connection. Please check your network and try again.',
      server: (msg, code) => msg.isNotEmpty ? msg : 'Server error occurred. Please try again later.',
      timeout: (msg) => 'Request timed out. Please check your connection and try again.',
      unauthorized: (msg) => 'Session expired. Please login again.',
      notFound: (msg) => msg.isNotEmpty ? msg : 'The requested resource was not found.',
      validation: (msg) => msg.isNotEmpty ? msg : 'Please correct the highlighted fields.',
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
''';
}
