import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

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
@lazySingleton

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
