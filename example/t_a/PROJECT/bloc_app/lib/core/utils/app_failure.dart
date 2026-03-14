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
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data) ?? 'Something went wrong';
        
        return switch (statusCode) {
          401 => UnauthorizedFailure(message),
          403 => const UnauthorizedFailure('Access denied'),
          404 => NotFoundFailure(message),
          422 => ValidationFailure(message),
          500 => ServerFailure(message, statusCode: statusCode),
          _ => ServerFailure(message, statusCode: statusCode),
        };
        
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
  
  static String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
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
  const ValidationFailure(super.message);
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
