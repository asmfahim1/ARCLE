import 'package:dio/dio.dart';

import 'api_failure.dart';
import 'result.dart';

/// Generic base response wrapper for API responses.
///
/// Handles common response patterns:
/// ```json
/// { "success": true, "message": "OK", "data": {...} }
/// { "status": "success", "data": [...] }
/// { "result": {...} }
/// ```
///
/// This is the ONLY place that interprets a raw backend envelope shape.
/// [ResponseHandler] below consumes [BaseResponse] rather than re-parsing
/// the raw JSON itself, so response-shape detection lives in one place.
class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final rawSuccess = json['success'];
    final isSuccess = rawSuccess is bool
        ? rawSuccess
        : (json['status']?.toString().toLowerCase() == 'success' ||
            _asInt(json['code']) == 200);
    final rawErrors = json['errors'];
    final parsedErrors = rawErrors is Map<String, dynamic>
        ? rawErrors
        : rawErrors is Map
            ? rawErrors.map(
                (key, value) => MapEntry(key.toString(), value),
              )
            : null;
    final rawData = json['data'] ?? json['result'] ?? json['payload'];

    return BaseResponse(
      success: isSuccess,
      message: _asString(json['message']) ?? _asString(json['msg']) ?? '',
      statusCode: _asInt(json['code']) ?? _asInt(json['status_code']),
      errors: parsedErrors,
      data: (rawData != null && fromJsonT != null)
          ? fromJsonT(rawData)
          : null,
    );
  }
  
  /// Create a successful response
  factory BaseResponse.success(T data, {String message = 'Success'}) {
    return BaseResponse(success: true, message: message, data: data);
  }
  
  /// Create a failed response
  factory BaseResponse.failure(String message, {int? statusCode}) {
    return BaseResponse(success: false, message: message, statusCode: statusCode);
  }
  
  /// Check if response has validation errors
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;
  
  /// Get first validation error message
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstField = errors!.values.first;
    if (firstField is List && firstField.isNotEmpty) {
      return firstField.first.toString();
    }
    return firstField.toString();
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(dynamic value) {
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    return null;
  }
}

/// Centralized response handler for API calls.
///
/// Converts a raw request into a [BaseResponse] (via [BaseResponse.fromJson])
/// and derives a [Result] from it, so no caller re-implements envelope
/// detection on its own.
///
/// Usage:
/// ```dart
/// final result = await ResponseHandler.handle(
///   request: () => apiService.get('/users'),
///   fromJson: (json) => User.fromJson(json),
/// );
///
/// result.fold(
///   (failure) => showError(failure.message),
///   (user) => showUser(user),
/// );
/// ```
class ResponseHandler {
  static bool _isSuccessStatus(int? statusCode) {
    if (statusCode == null) return false;
    return statusCode >= 200 && statusCode < 300;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  static BaseResponse<dynamic> _toBaseResponse(dynamic rawData) {
    final map = _asMap(rawData);
    if (map == null) return BaseResponse<dynamic>.success(rawData);
    return BaseResponse<dynamic>.fromJson(map, (d) => d);
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
      final rawData = response.data;
      if (rawData == null) {
        return Results.failure(const ServerFailure('Empty response'));
      }

      final baseResponse = _toBaseResponse(rawData);
      if (!baseResponse.success) {
        return Results.failure(AppFailure.fromResponse(response));
      }

      final payloadMap = _asMap(baseResponse.data) ?? _asMap(rawData);
      if (payloadMap == null) {
        return Results.failure(const ServerFailure('Invalid response format'));
      }

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
      final rawData = response.data;
      if (rawData == null) {
        return Results.success([]);
      }

      List<dynamic> rawItems;
      if (rawData is List) {
        rawItems = rawData;
      } else {
        final baseResponse = _toBaseResponse(rawData);
        if (!baseResponse.success) {
          return Results.failure(AppFailure.fromResponse(response));
        }
        final payload = baseResponse.data;
        if (payload is List) {
          rawItems = payload;
        } else {
          final payloadMap = _asMap(payload);
          final nested = payloadMap?['items'] ?? payloadMap?['results'];
          rawItems = nested is List ? nested : const <dynamic>[];
        }
      }

      final items = rawItems
          .map(_asMap)
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();

      return Results.success(items);
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
      final rawData = _asMap(response.data);
      if (rawData == null) {
        return Results.success(PaginatedResponse.empty());
      }

      final baseResponse = BaseResponse<dynamic>.fromJson(rawData, (d) => d);
      if (!baseResponse.success) {
        return Results.failure(AppFailure.fromResponse(response));
      }

      return Results.success(PaginatedResponse.fromJson(rawData, fromJson));
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
      final rawData = _asMap(response.data);

      if (rawData != null) {
        final baseResponse = BaseResponse<dynamic>.fromJson(rawData, (d) => d);
        if (!baseResponse.success) {
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
