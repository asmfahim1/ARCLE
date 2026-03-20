class UtilsTemplates {
  static String utilsLogger() => '''
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Professional-grade logger with structured output and log levels.
/// 
/// Features:
/// - Color-coded output in debug mode
/// - Structured log format with timestamps
/// - Stack trace support for errors
/// - Production-safe (no console output in release)
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in', tag: 'AUTH');
/// AppLogger.error('API failed', error: e, stackTrace: stack);
/// ```
class AppLogger {
  static const String _defaultTag = 'APP';
  
  static bool _enableLogging = kDebugMode;
  
  /// Enable or disable logging globally
  static void setEnabled(bool enabled) => _enableLogging = enabled;
  
  /// Log informational messages
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }
  
  /// Log debug messages (development only)
  static void debug(String message, {String? tag, Object? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }
  
  /// Log error messages with optional exception and stack trace
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log API requests/responses
  static void network(String message, {String? tag, Object? data}) {
    _log(LogLevel.network, message, tag: tag ?? 'NETWORK', data: data);
  }
  
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final logTag = tag ?? _defaultTag;
    final prefix = '\${level.emoji} [\$timestamp] [\$logTag]';
    
    final buffer = StringBuffer();
    buffer.writeln('\$prefix \$message');
    
    if (data != null) {
      buffer.writeln('  \u2514\u2500 Data: \$data');
    }
    
    if (error != null) {
      buffer.writeln('  \u2514\u2500 Error: \$error');
    }
    
    if (stackTrace != null) {
      buffer.writeln('  \u2514\u2500 StackTrace:');
      final frames = stackTrace.toString().split('\\n').take(5);
      for (final frame in frames) {
        buffer.writeln('       \$frame');
      }
    }
    
    developer.log(
      buffer.toString(),
      name: logTag,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
    
    // Also print to console in debug mode for visibility
    if (kDebugMode) {
      // ignore: avoid_print
      print('\${level.color}\${buffer.toString()}\\x1B[0m');
    }
  }
}

enum LogLevel {
  debug(500, '\ud83d\udcac', '\\x1B[37m'),   // White
  info(800, '\u2139\ufe0f', '\\x1B[34m'),    // Blue
  warning(900, '\u26a0\ufe0f', '\\x1B[33m'), // Yellow
  error(1000, '\u274c', '\\x1B[31m'),        // Red
  network(700, '\ud83c\udf10', '\\x1B[36m'); // Cyan

  const LogLevel(this.value, this.emoji, this.color);
  final int value;
  final String emoji;
  final String color;
}
''';

  static String utilsValidators() => '''
/// Basic validators for common input types.
/// For form-specific validation, use [AppValidators].
class Validators {
  static bool isEmail(String value) {
    final regex = RegExp(r'^[\\w.-]+@[\\w.-]+\\.\\w{2,}\$');
    return regex.hasMatch(value.trim());
  }
  
  static bool isPhone(String value) {
    final regex = RegExp(r'^\\+?[0-9]{10,14}\$');
    return regex.hasMatch(value.replaceAll(RegExp(r'[\\s-]'), ''));
  }
  
  static bool isUrl(String value) {
    return Uri.tryParse(value)?.hasAbsolutePath ?? false;
  }
  
  static bool isStrongPassword(String value) {
    // At least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}\$');
    return regex.hasMatch(value);
  }
}
''';

  static String appValidators() => '''
/// Form field validators with localization-ready error messages.
/// 
/// Usage:
/// ```dart
/// TextFormField(
///   validator: AppValidators.email,
/// )
/// ```
class AppValidators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\\w.-]+@[\\w.-]+\\.\\w{2,}\$');
    if (!regex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password with minimum requirements
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least \$minLength characters';
    }
    return null;
  }
  
  /// Validates strong password (uppercase, lowercase, number, special char)
  static String? strongPassword(String? value) {
    final baseError = password(value);
    if (baseError != null) return baseError;
    
    if (!RegExp(r'[A-Z]').hasMatch(value!)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[@\$!%*?&]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
  
  /// Validates password confirmation matches
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Generic required field validator
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '\$fieldName is required';
      }
      return null;
    };
  }
  
  /// Validates minimum length
  static String? Function(String?) minLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.length < length) {
        return '\${fieldName ?? 'Field'} must be at least \$length characters';
      }
      return null;
    };
  }
  
  /// Validates maximum length
  static String? Function(String?) maxLength(int length, {String? fieldName}) {
    return (String? value) {
      if (value != null && value.length > length) {
        return '\${fieldName ?? 'Field'} must be at most \$length characters';
      }
      return null;
    };
  }
  
  /// Validates phone number format
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\\s-()]'), '');
    if (!RegExp(r'^\\+?[0-9]{10,14}\$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '\${fieldName ?? 'Field'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
  
  /// Combines multiple validators
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
''';

  static String utilsFailure() => '''
import 'package:dio/dio.dart';

/// Represents all possible failure types in the application.
/// 
/// This sealed class enables exhaustive pattern matching:
/// ```dart
/// failure.when(
///   network: (msg) => showNoInternet(),
///   server: (msg, code) => showServerError(),
///   // ...
/// );
/// ```
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
  
  /// Optional structured details (validation, etc.)
  String get displayMessage => message.isNotEmpty ? message : 'Something went wrong';
  
  /// Pattern matching helper
  T when<T>({
    required T Function(String message) network,
    required T Function(String message, int? statusCode) server,
    required T Function(String message) timeout,
    required T Function(String message) unauthorized,
    required T Function(String message) notFound,
    required T Function(String message) validation,
    required T Function(String message) cache,
    required T Function(String message, Object? error) unknown,
  }) {
    return switch (this) {
      NetworkFailure f => network(f.message),
      ServerFailure f => server(f.message, f.statusCode),
      TimeoutFailure f => timeout(f.message),
      UnauthorizedFailure f => unauthorized(f.message),
      NotFoundFailure f => notFound(f.message),
      ValidationFailure f => validation(f.message),
      CacheFailure f => cache(f.message),
      UnknownFailure f => unknown(f.message, f.error),
    };
  }
  
  /// Create appropriate failure from DioException
  factory AppFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('Connection timed out. Please try again.');
        
      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection. Please check your network.');
        
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response != null) {
          return AppFailure.fromResponse(response);
        }
        return const ServerFailure('Server error occurred');
        
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled');
        
      default:
        return UnknownFailure(e.message ?? 'An unexpected error occurred', e);
    }
  }
  
  /// Create failure from generic exception
  factory AppFailure.fromException(Object e, [StackTrace? stack]) {
    if (e is DioException) {
      return AppFailure.fromDioException(e);
    }
    return UnknownFailure(e.toString(), e);
  }
  
  /// Create failure from HTTP response (non-2xx).
  factory AppFailure.fromResponse(Response response) {
    final statusCode = response.statusCode;
    final parsed = _parseErrorPayload(response.data);
    final message = parsed.message ?? _fallbackMessage(statusCode) ?? 'Something went wrong';

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedFailure(message);
    }
    if (statusCode == 404) {
      return NotFoundFailure(message);
    }
    if (statusCode == 422 || statusCode == 400) {
      return ValidationFailure(
        message,
        fieldErrors: parsed.fieldErrors,
        globalErrors: parsed.globalErrors,
      );
    }
    if (statusCode != null && statusCode >= 500) {
      return ServerFailure(message, statusCode: statusCode);
    }
    return ServerFailure(message, statusCode: statusCode);
  }

  static String? _fallbackMessage(int? statusCode) {
    return switch (statusCode) {
      400 => 'Invalid request',
      401 => 'Session expired. Please login again.',
      403 => 'Access denied',
      404 => 'The requested resource was not found.',
      408 => 'Request timed out',
      409 => 'Conflict detected',
      422 => 'Please correct the highlighted fields.',
      500 => 'Server error occurred.',
      503 => 'Service unavailable. Please try again later.',
      _ => null,
    };
  }

  static _ParsedErrorPayload _parseErrorPayload(dynamic data) {
    final fieldErrors = <String, List<String>>{};
    final globalErrors = <String>[];
    String? message;

    if (data == null) {
      return _ParsedErrorPayload(
        message: null,
        fieldErrors: fieldErrors,
        globalErrors: globalErrors,
      );
    }

    if (data is String) {
      message = data;
      return _ParsedErrorPayload(
        message: message,
        fieldErrors: fieldErrors,
        globalErrors: globalErrors,
      );
    }

    if (data is List) {
      for (final item in data) {
        _collectMessages(item, globalErrors);
      }
      message = globalErrors.isNotEmpty ? globalErrors.first : null;
      return _ParsedErrorPayload(
        message: message,
        fieldErrors: fieldErrors,
        globalErrors: globalErrors,
      );
    }

    if (data is Map) {
      message = _firstString(
            data['message'],
          ) ??
          _firstString(data['error']) ??
          _firstString(data['msg']) ??
          _firstString(data['detail']) ??
          _firstString(data['title']);

      _parseErrorsNode(data['errors'], fieldErrors, globalErrors);
      _parseErrorsNode(data['error'], fieldErrors, globalErrors);
      _parseErrorsNode(data['data'], fieldErrors, globalErrors);

      if (message == null && globalErrors.isNotEmpty) {
        message = globalErrors.first;
      }
    }

    return _ParsedErrorPayload(
      message: message,
      fieldErrors: fieldErrors,
      globalErrors: globalErrors,
    );
  }

  static void _parseErrorsNode(
    dynamic node,
    Map<String, List<String>> fieldErrors,
    List<String> globalErrors,
  ) {
    if (node == null) return;

    if (node is String) {
      globalErrors.add(node);
      return;
    }

    if (node is List) {
      for (final item in node) {
        if (item is Map && item['field'] is String) {
          final field = item['field'] as String;
          final msg = _firstString(item['message']) ??
              _firstString(item['error']) ??
              _firstString(item['msg']);
          if (msg != null) {
            fieldErrors.putIfAbsent(field, () => []).add(msg);
            continue;
          }
        }
        _collectMessages(item, globalErrors);
      }
      return;
    }

    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key?.toString() ?? 'error';
        final value = entry.value;
        if (value is List) {
          final messages = value
              .map((e) => _firstString(e) ?? e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
          if (messages.isNotEmpty) {
            fieldErrors.putIfAbsent(key, () => []).addAll(messages);
          }
        } else if (value is String) {
          fieldErrors.putIfAbsent(key, () => []).add(value);
        } else if (value is Map) {
          final msg = _firstString(value['message']) ??
              _firstString(value['error']) ??
              _firstString(value['msg']);
          if (msg != null) {
            fieldErrors.putIfAbsent(key, () => []).add(msg);
          }
        } else {
          final msg = _firstString(value);
          if (msg != null) {
            fieldErrors.putIfAbsent(key, () => []).add(msg);
          }
        }
      }
    }
  }

  static void _collectMessages(dynamic node, List<String> out) {
    final msg = _firstString(node);
    if (msg != null) {
      out.add(msg);
      return;
    }
    if (node is Map) {
      final nested =
          _firstString(node['message']) ?? _firstString(node['error']) ?? _firstString(node['msg']);
      if (nested != null) {
        out.add(nested);
      }
    }
  }

  static String? _firstString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return null;
  }
}

/// No internet or network connectivity issues
class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network error occurred']);
}

/// Server returned an error response (5xx)
class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {this.statusCode});
  final int? statusCode;
}

/// Request timed out
class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

/// User is not authenticated or session expired
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure([super.message = 'Session expired. Please login again.']);
}

/// Requested resource not found (404)
class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Validation error from server (422)
class ValidationFailure extends AppFailure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    this.globalErrors = const [],
  });

  final Map<String, List<String>> fieldErrors;
  final List<String> globalErrors;

  /// Flattened list of all validation errors
  List<String> get allErrors => [
        ...globalErrors,
        ...fieldErrors.values.expand((e) => e),
      ];

  @override
  String get displayMessage {
    if (message.isNotEmpty) return message;
    if (allErrors.isNotEmpty) return allErrors.first;
    return 'Please correct the highlighted fields.';
  }
}

/// Local cache/storage error
class CacheFailure extends AppFailure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Unknown or unhandled error
class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'An unexpected error occurred', this.error]);
  final Object? error;
}

class _ParsedErrorPayload {
  const _ParsedErrorPayload({
    required this.message,
    required this.fieldErrors,
    required this.globalErrors,
  });

  final String? message;
  final Map<String, List<String>> fieldErrors;
  final List<String> globalErrors;
}
''';

  static String utilsResult() => '''
import 'package:dartz/dartz.dart';

import '../response_handler/api_failure.dart';

/// Type alias for Either-based result handling.
/// 
/// Left = Failure, Right = Success
/// 
/// Usage:
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await api.fetchUser(id);
///     return Right(user);
///   } catch (e) {
///     return Left(AppFailure.fromException(e));
///   }
/// }
/// 
/// // Consuming:
/// final result = await getUser('123');
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showUser(user),
/// );
/// ```
typedef Result<T> = Either<AppFailure, T>;

/// Extension methods for Result type
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a successful result
  bool get isSuccess => isRight();
  
  /// Returns true if this is a failure result
  bool get isFailure => isLeft();
  
  /// Get the success value or null
  T? get valueOrNull => fold((_) => null, (value) => value);
  
  /// Get the failure or null
  AppFailure? get failureOrNull => fold((failure) => failure, (_) => null);
  
  /// Transform success value, preserving failures
  Result<R> mapSuccess<R>(R Function(T value) transform) {
    return fold(
      (failure) => Left(failure),
      (value) => Right(transform(value)),
    );
  }
  
  /// Execute side effect on success
  Result<T> onSuccess(void Function(T value) action) {
    fold((_) {}, action);
    return this;
  }
  
  /// Execute side effect on failure
  Result<T> onFailure(void Function(AppFailure failure) action) {
    fold(action, (_) {});
    return this;
  }
}

/// Helper functions for creating Results
class Results {
  /// Create a successful result
  static Result<T> success<T>(T value) => Right(value);
  
  /// Create a failure result
  static Result<T> failure<T>(AppFailure failure) => Left(failure);
  
  /// Create a failure from exception
  static Result<T> fromException<T>(Object error, [StackTrace? stack]) {
    return Left(AppFailure.fromException(error, stack));
  }
  
  /// Run async operation and wrap in Result
  static Future<Result<T>> guard<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
''';

  static String utilsDateFormatter() => '''
import 'package:intl/intl.dart';

/// Shared date and time formatter for app-wide UX formatting.
///
/// Backend APIs usually return date values as strings. This helper accepts:
/// - ISO8601 string dates
/// - [DateTime]
/// - Unix timestamps in seconds or milliseconds
///
/// Usage:
/// ```dart
/// final createdAt = formatter.date('2026-03-20T15:30:00Z');
/// final localTime = formatter.time('2026-03-20T15:30:00Z');
/// final custom = formatter.format('2026-03-20T15:30:00Z', pattern: 'dd MMM yyyy, hh:mm a');
/// final ago = formatter.timeAgo('2026-03-20T15:30:00Z');
/// ```
class DateFormatter {
  const DateFormatter();

  /// Global ready-to-use instance for convenience.
  static const DateFormatter instance = DateFormatter();

  /// Converts supported input into local [DateTime].
  DateTime? toLocalDateTime(dynamic input) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  /// Converts supported input into UTC [DateTime].
  DateTime? toUtcDateTime(dynamic input) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  /// Formats input into a custom pattern.
  String format(
    dynamic input, {
    String pattern = 'dd MMM yyyy',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    final date = _resolve(input, toLocal: toLocal);
    if (date == null) return fallback;
    return DateFormat(pattern, locale).format(date);
  }

  /// Example: 20 Mar 2026
  String date(
    dynamic input, {
    String pattern = 'dd MMM yyyy',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: pattern,
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: 03:45 PM
  String time(
    dynamic input, {
    String pattern = 'hh:mm a',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: pattern,
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: 20 Mar 2026, 03:45 PM
  String dateTime(
    dynamic input, {
    String pattern = 'dd MMM yyyy, hh:mm a',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: pattern,
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: Mar 20, 2026
  String shortDate(
    dynamic input, {
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: 'MMM dd, yyyy',
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: Friday, 20 Mar 2026
  String fullDate(
    dynamic input, {
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: 'EEEE, dd MMM yyyy',
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: Today, Yesterday, or a date fallback.
  String uxDate(
    dynamic input, {
    String fallback = '',
    String? locale,
  }) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return fallback;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == -1) return 'Yesterday';
    if (difference == 1) return 'Tomorrow';
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  /// Example: 2m ago, 5h ago, 3d ago
  String timeAgo(dynamic input, {String fallback = ''}) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return fallback;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return inFuture(date, fallback: fallback);
    }
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '\${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '\${difference.inHours}h ago';
    if (difference.inDays < 7) return '\${difference.inDays}d ago';
    if (difference.inDays < 30) return '\${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '\${(difference.inDays / 30).floor()}mo ago';
    return '\${(difference.inDays / 365).floor()}y ago';
  }

  /// Example: In 5m, In 2h, In 3d
  String inFuture(dynamic input, {String fallback = ''}) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return fallback;

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return timeAgo(date, fallback: fallback);
    }
    if (difference.inSeconds < 60) return 'In a moment';
    if (difference.inMinutes < 60) return 'In \${difference.inMinutes}m';
    if (difference.inHours < 24) return 'In \${difference.inHours}h';
    if (difference.inDays < 7) return 'In \${difference.inDays}d';
    return 'In \${DateFormat('dd MMM yyyy').format(date)}';
  }

  bool isToday(dynamic input) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return false;
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool isPast(dynamic input) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  int? differenceInDays(dynamic from, dynamic to) {
    final start = _resolve(from, toLocal: true);
    final end = _resolve(to, toLocal: true);
    if (start == null || end == null) return null;
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return normalizedEnd.difference(normalizedStart).inDays;
  }

  DateTime? _resolve(dynamic input, {required bool toLocal}) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    if (toLocal) {
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  DateTime? _parse(dynamic input) {
    if (input == null) return null;

    if (input is DateTime) {
      return input;
    }

    if (input is int) {
      return _fromTimestamp(input);
    }

    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return null;

      final timestamp = int.tryParse(trimmed);
      if (timestamp != null) {
        return _fromTimestamp(timestamp);
      }

      return DateTime.tryParse(trimmed);
    }

    return null;
  }

  DateTime _fromTimestamp(int timestamp) {
    final isMilliseconds = timestamp.abs() > 9999999999;
    return DateTime.fromMillisecondsSinceEpoch(
      isMilliseconds ? timestamp : timestamp * 1000,
      isUtc: true,
    );
  }
}

const formatter = DateFormatter.instance;
''';
}
