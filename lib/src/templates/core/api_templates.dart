import '../../state_management.dart';

class ApiTemplates {
  static String dioClient(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
import 'dart:io';
import 'package:dio/dio.dart';
$injectableImport
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
$injectableAnno
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
          options.headers['Authorization'] = 'Bearer \$token';
        }
        
        final url = options.uri.toString();
        AppLogger.network(
          'HTTP Request',
          tag: 'HTTP',
          data: {
            'method': options.method,
            'url': url,
            'requestBody': options.data,
          },
        );
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final url = response.requestOptions.uri.toString();
        AppLogger.network(
          'HTTP Response',
          tag: 'HTTP',
          data: {
            'method': response.requestOptions.method,
            'url': url,
            'response': response.data,
          },
        );
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        final url = e.requestOptions.uri.toString();
        AppLogger.network(
          'HTTP Error',
          tag: 'HTTP',
          data: {
            'method': e.requestOptions.method,
            'url': url,
            'requestBody': e.requestOptions.data,
            'response': e.response?.data,
          },
        );
        
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
    options.headers['Authorization'] = 'Bearer \$token';
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
''';
  }

  static String apiResponse() => '''
/// Generic base response wrapper for API responses.
/// 
/// Handles common response patterns:
/// ```json
/// { "success": true, "message": "OK", "data": {...} }
/// { "status": "success", "data": [...] }
/// ```
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
    
    return BaseResponse(
      success: isSuccess,
      message: _asString(json['message']) ?? _asString(json['msg']) ?? '',
      statusCode: _asInt(json['code']) ?? _asInt(json['status_code']),
      errors: parsedErrors,
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
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
''';

  static String apiService(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
import 'dart:io';
import 'package:dio/dio.dart';
$injectableImport
import 'dio_client.dart';

/// Centralized API service for all HTTP operations.
/// 
/// Usage:
/// ```dart
/// // Simple GET
/// final response = await apiService.get('/users');
/// 
/// // GET with query params
/// final response = await apiService.get('/users', query: {'page': 1});
/// 
/// // POST with body
/// final response = await apiService.post('/login', data: {'email': '...', 'password': '...'});
/// 
/// // With cancellation support
/// final response = await apiService.get('/search', cancelKey: 'search_query');
/// apiService.cancel('search_query'); // Cancel if needed
/// ```
$injectableAnno
class ApiService {
  final DioClient _client;

  ApiService(this._client);
  
  Dio get _dio => _client.instance;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? cancelKey,
  }) async {
    return _dio.get(
      path,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelKey != null ? _client.getCancelToken(cancelKey) : null,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? cancelKey,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
      cancelToken: cancelKey != null ? _client.getCancelToken(cancelKey) : null,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }
  
  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: query,
      options: Options(headers: headers),
    );
  }

  /// Upload file(s) with multipart form data
  Future<Response> upload(
    String path,
    Map<String, dynamic> data, {
    void Function(int sent, int total)? onProgress,
    String? cancelKey,
  }) async {
    final formMap = <String, dynamic>{};
    
    for (final entry in data.entries) {
      if (entry.value is File) {
        final file = entry.value as File;
        formMap[entry.key] = await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        );
      } else if (entry.value is List<File>) {
        formMap[entry.key] = await Future.wait(
          (entry.value as List<File>).map((file) async {
            return MultipartFile.fromFile(
              file.path,
              filename: file.path.split(Platform.pathSeparator).last,
            );
          }),
        );
      } else {
        formMap[entry.key] = entry.value;
      }
    }

    final formData = FormData.fromMap(formMap);
    
    return _dio.post(
      path,
      data: formData,
      onSendProgress: onProgress,
      cancelToken: cancelKey != null ? _client.getCancelToken(cancelKey) : null,
    );
  }
  
  /// Download file
  Future<Response> download(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
    String? cancelKey,
  }) async {
    return _dio.download(
      path,
      savePath,
      onReceiveProgress: onProgress,
      cancelToken: cancelKey != null ? _client.getCancelToken(cancelKey) : null,
    );
  }
  
  /// Cancel a specific request
  void cancel(String key) => _client.cancelRequest(key);
  
  /// Cancel all pending requests
  void cancelAll() => _client.cancelAllRequests();
}
''';
  }
}
