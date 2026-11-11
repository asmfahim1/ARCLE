import 'dart:async';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_service.dart';
import '../models/login_request.dart';

@injectable

class DemoRemoteDataSource {
  DemoRemoteDataSource(this._apiService);

  final ApiService _apiService;

  /// Demo login. Replace with your real API later.
  Future<Response<dynamic>> login(LoginRequest request) async {
    return _apiService.post('/auth/login', data: request.toJson());
  }

  /// Fetch users from JSONPlaceholder.
  Future<Response<dynamic>> fetchUsers() async {
    return _apiService.get('/users');
  }
}
