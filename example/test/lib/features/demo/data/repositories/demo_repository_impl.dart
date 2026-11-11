import 'package:injectable/injectable.dart';

import 'package:dartz/dartz.dart';
import '../../../../core/network/api_failure.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/services/session_manager.dart';
import '../../../../core/network/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/demo_repository.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';
import '../sources/demo_remote_data_source.dart';

@LazySingleton(as: DemoRepository)

class DemoRepositoryImpl implements DemoRepository {
  DemoRepositoryImpl(this._remote, this._sessionManager);

  final DemoRemoteDataSource _remote;
  final SessionManager _sessionManager;

  @override
  Future<Result<String>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(ValidationFailure('Please enter email and password'));
    }
    final result = await ResponseHandler.handle<Map<String, dynamic>>(
      request: () => _remote.login(
        LoginRequest(email: email, password: password),
      ),
      fromJson: (json) => json,
    );
    return result.fold(
      (failure) => Left(failure),
      (data) async {
        final token = data['token']?.toString() ?? '';
        await _sessionManager.saveSession(accessToken: token);
        return Right(token);
      },
    );
  }

  @override
  Future<Result<List<UserEntity>>> getUsers() async {
    return ResponseHandler.handleList(
      request: () => _remote.fetchUsers(),
      fromJson: (json) => UserModel.fromJson(json),
    );
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _sessionManager.clearToken();
      return const Right(null);
    } catch (e, stack) {
      return Left(AppFailure.fromException(e, stack));
    }
  }
}
