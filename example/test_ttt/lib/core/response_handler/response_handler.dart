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
