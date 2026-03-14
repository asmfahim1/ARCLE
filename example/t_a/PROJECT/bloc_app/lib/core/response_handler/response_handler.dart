import 'package:dio/dio.dart';

import '../utils/app_failure.dart';
import '../utils/result.dart';
import '../utils/logger.dart';
import '../api_client/base_response.dart';

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
  /// Handle a single object response
  static Future<Result<T>> handle<T>({
    required Future<Response> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      final data = response.data;
      
      AppLogger.network(
        'Response: ${response.statusCode}',
        tag: tag ?? 'API',
        data: data,
      );
      
      if (data == null) {
        return Results.failure(const ServerFailure('Empty response'));
      }
      
      // Handle BaseResponse wrapper if present
      if (data is Map<String, dynamic>) {
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(
            ServerFailure(data['message'] ?? 'Request failed'),
          );
        }
        
        // Extract nested data if present
        final payload = data['data'] ?? data;
        if (payload is Map<String, dynamic>) {
          return Results.success(fromJson(payload));
        }
      }
      
      return Results.success(fromJson(data));
    } on DioException catch (e) {
      AppLogger.error('DioException', tag: tag ?? 'API', error: e);
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      AppLogger.error('Unexpected error', tag: tag ?? 'API', error: e, stackTrace: stack);
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle a list response
  static Future<Result<List<T>>> handleList<T>({
    required Future<Response> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      final data = response.data;
      
      AppLogger.network(
        'Response: ${response.statusCode}',
        tag: tag ?? 'API',
      );
      
      if (data == null) {
        return Results.success([]);
      }
      
      List<dynamic> items;
      
      if (data is List) {
        items = data;
      } else if (data is Map<String, dynamic>) {
        // Handle BaseResponse wrapper
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(
            ServerFailure(data['message'] ?? 'Request failed'),
          );
        }
        items = data['data'] ?? data['items'] ?? data['results'] ?? [];
      } else {
        return Results.success([]);
      }
      
      return Results.success(
        items.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      );
    } on DioException catch (e) {
      AppLogger.error('DioException', tag: tag ?? 'API', error: e);
      return Results.failure(AppFailure.fromDioException(e));
    } catch (e, stack) {
      AppLogger.error('Unexpected error', tag: tag ?? 'API', error: e, stackTrace: stack);
      return Results.failure(AppFailure.fromException(e, stack));
    }
  }
  
  /// Handle paginated response
  static Future<Result<PaginatedResponse<T>>> handlePaginated<T>({
    required Future<Response> Function() request,
    required T Function(Map<String, dynamic>) fromJson,
    String? tag,
  }) async {
    try {
      final response = await request();
      final data = response.data;
      
      if (data == null || data is! Map<String, dynamic>) {
        return Results.success(PaginatedResponse.empty());
      }
      
      if (data.containsKey('success') && data['success'] == false) {
        return Results.failure(
          ServerFailure(data['message'] ?? 'Request failed'),
        );
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
    required Future<Response> Function() request,
    String? tag,
  }) async {
    try {
      final response = await request();
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('success') && data['success'] == false) {
          return Results.failure(
            ServerFailure(data['message'] ?? 'Request failed'),
          );
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
    final data = json['data'] ?? json;
    final List<dynamic> rawItems = data['items'] ?? data['results'] ?? data['data'] ?? [];
    final meta = json['meta'] ?? json['pagination'] ?? json;
    
    final page = meta['page'] ?? meta['current_page'] ?? 1;
    final totalPages = meta['total_pages'] ?? meta['last_page'] ?? 1;
    final totalItems = meta['total'] ?? meta['total_items'] ?? rawItems.length;
    
    return PaginatedResponse(
      items: rawItems.map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      page: page,
      totalPages: totalPages,
      totalItems: totalItems,
      hasMore: page < totalPages,
    );
  }
}
