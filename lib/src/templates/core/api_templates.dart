import '../../state_management.dart';

class ApiTemplates {
  static String dioClient(StateManagement state) {
    final injectableImport =
        state == StateManagement.bloc
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
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final options = response.requestOptions;
        AppLogger.apiCall(
          url: options.uri.toString(),
          endpoint: options.path,
          requestBody: options.data,
          responseBody: response.data,
        );
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        AppLogger.apiCall(
          url: e.requestOptions.uri.toString(),
          endpoint: e.requestOptions.path,
          requestBody: e.requestOptions.data,
          responseBody: e.response?.data,
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
    } catch (_) {
      return false;
    }
  }
  
  Future<Response<dynamic>> _retry(RequestOptions options) async {
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

  static String httpClient(StateManagement state) {
    final injectableImport =
        state == StateManagement.bloc
            ? "import 'package:injectable/injectable.dart';\n"
            : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
$injectableImport
import '../env/env_factory.dart';
import '../session_manager/session_manager.dart';
import '../utils/logger.dart';

/// Lightweight, structured response object returned by HTTP operations.
class ApiResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, String> headers;

  const ApiResponse({
    required this.statusCode,
    this.data,
    this.headers = const {},
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Robust HTTP client based on package:http with auth injection, logging, and retry.
$injectableAnno
class ApiHttpClient {
  final SessionManager _sessionManager;
  final http.Client _innerClient;
  final Map<String, Completer<void>> _cancelTokens = {};

  ApiHttpClient(this._sessionManager, [http.Client? client])
      : _innerClient = client ?? http.Client();

  String get baseUrl => EnvFactory.current().apiBaseUrl;

  Uri buildUri(String path, [Map<String, dynamic>? query]) {
    final base =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/\$path';
    final queryString =
        (query != null && query.isNotEmpty)
            ? query.map((k, v) => MapEntry(k, v?.toString() ?? ''))
            : null;
    return Uri.parse('\$base\$normalizedPath').replace(queryParameters: queryString);
  }

  Future<Map<String, String>> _headers([Map<String, dynamic>? customHeaders]) async {
    final headers = <String, String>{
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    final token = await _sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer \$token';
    }
    if (customHeaders != null) {
      for (final entry in customHeaders.entries) {
        if (entry.value != null) {
          headers[entry.key] = entry.value.toString();
        }
      }
    }
    return headers;
  }

  Future<ApiResponse> send({
    required String method,
    required String path,
    Map<String, dynamic>? query,
    dynamic data,
    Map<String, dynamic>? headers,
    String? cancelKey,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final uri = buildUri(path, query);
    final requestHeaders = await _headers(headers);

    Future<http.Response> execute() async {
      Completer<void>? cancelCompleter;
      if (cancelKey != null) {
        cancelCompleter = Completer<void>();
        _cancelTokens[cancelKey] = cancelCompleter;
      }

      final request = http.AbortableRequest(
        method,
        uri,
        abortTrigger: cancelCompleter?.future,
      );
      request.headers.addAll(requestHeaders);

      if (data != null) {
        if (data is String) {
          request.body = data;
        } else if (data is List || data is Map) {
          request.body = jsonEncode(data);
        } else {
          request.body = data.toString();
        }
      }

      final streamed = await _innerClient.send(request).timeout(timeout);
      return http.Response.fromStream(streamed);
    }

    try {
      var response = await execute();
      AppLogger.apiCall(
        url: uri.toString(),
        endpoint: path,
        requestBody: data,
        responseBody: response.body,
      );

      if (response.statusCode == 401) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          final retryHeaders = await _headers(headers);
          requestHeaders.addAll(retryHeaders);
          response = await execute();
        } else {
          await _sessionManager.clearSession();
        }
      }

      final parsedData = _decodeBody(response.body);
      return ApiResponse(
        statusCode: response.statusCode,
        data: parsedData,
        headers: response.headers,
      );
    } finally {
      if (cancelKey != null) {
        _cancelTokens.remove(cancelKey);
      }
    }
  }

  Future<ApiResponse> upload({
    required String path,
    required Map<String, dynamic> data,
    void Function(int sent, int total)? onProgress,
    String? cancelKey,
  }) async {
    final uri = buildUri(path);
    final requestHeaders = await _headers();

    Completer<void>? cancelCompleter;
    if (cancelKey != null) {
      cancelCompleter = Completer<void>();
      _cancelTokens[cancelKey] = cancelCompleter;
    }

    try {
      final request = http.AbortableMultipartRequest(
        'POST',
        uri,
        abortTrigger: cancelCompleter?.future,
      );
      request.headers.addAll(requestHeaders);

      for (final entry in data.entries) {
        final val = entry.value;
        if (val is File) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, val.path),
          );
        } else if (val is List<File>) {
          for (final f in val) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, f.path),
            );
          }
        } else if (val != null) {
          request.fields[entry.key] = val.toString();
        }
      }

      final streamed = await _innerClient.send(request);
      final response = await http.Response.fromStream(streamed);

      AppLogger.apiCall(
        url: uri.toString(),
        endpoint: path,
        requestBody: '[Multipart: \${data.keys.join(", ")}]',
        responseBody: response.body,
      );

      final parsed = _decodeBody(response.body);
      return ApiResponse(
        statusCode: response.statusCode,
        data: parsed,
        headers: response.headers,
      );
    } finally {
      if (cancelKey != null) {
        _cancelTokens.remove(cancelKey);
      }
    }
  }

  Future<ApiResponse> download({
    required String path,
    required String savePath,
    void Function(int received, int total)? onProgress,
    String? cancelKey,
  }) async {
    final uri = buildUri(path);
    final requestHeaders = await _headers();

    Completer<void>? cancelCompleter;
    if (cancelKey != null) {
      cancelCompleter = Completer<void>();
      _cancelTokens[cancelKey] = cancelCompleter;
    }

    try {
      final request = http.AbortableRequest(
        'GET',
        uri,
        abortTrigger: cancelCompleter?.future,
      );
      request.headers.addAll(requestHeaders);

      final streamed = await _innerClient.send(request);
      final total = streamed.contentLength ?? -1;
      var received = 0;

      final file = File(savePath);
      await file.parent.create(recursive: true);
      final sink = file.openWrite();

      await for (final chunk in streamed.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
      await sink.flush();
      await sink.close();

      return ApiResponse(
        statusCode: streamed.statusCode,
        data: savePath,
        headers: streamed.headers,
      );
    } finally {
      if (cancelKey != null) {
        _cancelTokens.remove(cancelKey);
      }
    }
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await _sessionManager.getRefreshToken();
      if (refreshToken == null) return false;
      return false;
    } catch (_) {
      return false;
    }
  }

  void cancelRequest(String key) {
    final completer = _cancelTokens.remove(key);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void cancelAllRequests() {
    for (final completer in _cancelTokens.values) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _cancelTokens.clear();
  }

  http.Client get client => _innerClient;
}
''';
  }

  static String apiService(
    StateManagement state, [
    NetworkClient network = NetworkClient.dio,
  ]) {
    if (network.isHttp) {
      return _httpApiService(state);
    }
    return _dioApiService(state);
  }

  static String _httpApiService(StateManagement state) {
    final injectableImport =
        state == StateManagement.bloc
            ? "import 'package:injectable/injectable.dart';\n"
            : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
$injectableImport
import 'http_client.dart';

/// Centralized API service for all HTTP operations using package:http.
$injectableAnno
class ApiService {
  final ApiHttpClient _client;

  ApiService(this._client);

  /// GET request
  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? cancelKey,
  }) async {
    return _client.send(
      method: 'GET',
      path: path,
      query: query,
      headers: headers,
      cancelKey: cancelKey,
    );
  }

  /// POST request
  Future<ApiResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? cancelKey,
  }) async {
    return _client.send(
      method: 'POST',
      path: path,
      data: data,
      query: query,
      headers: headers,
      cancelKey: cancelKey,
    );
  }

  /// PUT request
  Future<ApiResponse> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _client.send(
      method: 'PUT',
      path: path,
      data: data,
      query: query,
      headers: headers,
    );
  }

  /// PATCH request
  Future<ApiResponse> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _client.send(
      method: 'PATCH',
      path: path,
      data: data,
      query: query,
      headers: headers,
    );
  }

  /// DELETE request
  Future<ApiResponse> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    return _client.send(
      method: 'DELETE',
      path: path,
      data: data,
      query: query,
      headers: headers,
    );
  }

  /// Upload file(s) with multipart form data
  Future<ApiResponse> upload(
    String path,
    Map<String, dynamic> data, {
    void Function(int sent, int total)? onProgress,
    String? cancelKey,
  }) async {
    return _client.upload(
      path: path,
      data: data,
      onProgress: onProgress,
      cancelKey: cancelKey,
    );
  }

  /// Download file
  Future<ApiResponse> download(
    String path,
    String savePath, {
    void Function(int received, int total)? onProgress,
    String? cancelKey,
  }) async {
    return _client.download(
      path: path,
      savePath: savePath,
      onProgress: onProgress,
      cancelKey: cancelKey,
    );
  }

  /// Cancel a specific request
  void cancel(String key) => _client.cancelRequest(key);

  /// Cancel all pending requests
  void cancelAll() => _client.cancelAllRequests();
}
''';
  }

  static String _dioApiService(StateManagement state) {
    final injectableImport =
        state == StateManagement.bloc
            ? "import 'package:injectable/injectable.dart';\n"
            : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
import 'dart:io';
import 'package:dio/dio.dart';
$injectableImport
import 'dio_client.dart';

/// Centralized API service for all HTTP operations using Dio.
$injectableAnno
class ApiService {
  final DioClient _client;

  ApiService(this._client);
  
  Dio get _dio => _client.instance;

  /// GET request
  Future<Response<dynamic>> get(
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
  Future<Response<dynamic>> post(
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
  Future<Response<dynamic>> put(
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
  Future<Response<dynamic>> patch(
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
  Future<Response<dynamic>> delete(
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
  Future<Response<dynamic>> upload(
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
  Future<Response<dynamic>> download(
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
