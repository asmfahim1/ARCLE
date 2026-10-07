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
  factory AppFailure.fromResponse(Response<dynamic> response) {
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
