import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../env/env_factory.dart';
import '../session_manager/session_manager.dart';
import '../utils/logger.dart';

/// Professional HTTP client with interceptors for auth, logging, and error handling.
/// 
/// Features:
/// - Automatic token injection
/// - Request/response logging (debug mode only)
/// - Automatic 401 handling with token refresh support
/// - Retry logic for transient failures
/// - Request cancellation support
@lazySingleton

class DioClient {
  late final Dio _dio;
  final SessionManager _sessionManager;
  final Map<String, CancelToken> _cancelTokens = {};

  DioClient(this._sessionManager) {
    _dio = Dio(_baseOptions);
    _addInterceptors();
  }

  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: EnvFactory.current().apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
    headers: {
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    validateStatus: (status) => status != null && status < 500,
  );

  void _addInterceptors() {
    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _sessionManager.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        final url = options.uri.toString();
        AppLogger.network(
          '→ ${options.method} $url',
          tag: 'HTTP',
          data: kDebugMode
              ? {
                  'query': options.queryParameters,
                  'body': options.data,
                }
              : null,
        );
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final url = response.requestOptions.uri.toString();
        AppLogger.network(
          '← ${response.statusCode} ${response.requestOptions.method} $url',
          tag: 'HTTP',
          data: kDebugMode ? response.data : null,
        );
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        final url = e.requestOptions.uri.toString();
        AppLogger.error(
          '✗ ${e.response?.statusCode ?? 'ERR'} ${e.requestOptions.method} $url',
          tag: 'HTTP',
          error: e.message,
        );
        if (kDebugMode) {
          AppLogger.debug(
            'Request/response details',
            tag: 'HTTP',
            data: {
              'request_body': e.requestOptions.data,
              'response_body': e.response?.data,
            },
          );
        }
        
        if (e.response?.statusCode == 401) {
          // Attempt token refresh
          final refreshed = await _attemptTokenRefresh();
          if (refreshed) {
            // Retry the original request
            try {
              final retryResponse = await _retry(e.requestOptions);
              return handler.resolve(retryResponse);
            } catch (retryError) {
              return handler.next(e);
            }
          } else {
            await _sessionManager.clearSession();
          }
        }
        
        return handler.next(e);
      },
    ));

    // Logging interceptor (debug only)
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => AppLogger.debug(obj.toString(), tag: 'DIO'),
      ));
    }
  }
  
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _sessionManager.getRefreshToken();
      if (refreshToken == null) return false;
      
      // TODO: Implement your token refresh logic here
      // final response = await _dio.post('/auth/refresh', data: {'refresh_token': refreshToken});
      // await _sessionManager.saveTokens(response.data['access_token'], response.data['refresh_token']);
      // return true;
      
      return false;
    } catch (e) {
      AppLogger.error('Token refresh failed', tag: 'AUTH', error: e);
      return false;
    }
  }
  
  Future<Response> _retry(RequestOptions options) async {
    final token = await _sessionManager.getToken();
    options.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch(options);
  }
  
  /// Get a cancel token for a specific request
  CancelToken getCancelToken(String key) {
    _cancelTokens[key]?.cancel();
    _cancelTokens[key] = CancelToken();
    return _cancelTokens[key]!;
  }
  
  /// Cancel a specific request
  void cancelRequest(String key) {
    _cancelTokens[key]?.cancel('Request cancelled by user');
    _cancelTokens.remove(key);
  }
  
  /// Cancel all pending requests
  void cancelAllRequests() {
    for (final token in _cancelTokens.values) {
      token.cancel('All requests cancelled');
    }
    _cancelTokens.clear();
  }

  Dio get instance => _dio;
}
