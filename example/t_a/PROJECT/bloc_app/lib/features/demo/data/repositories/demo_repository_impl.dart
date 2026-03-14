import 'package:injectable/injectable.dart';

import 'package:dartz/dartz.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
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
    try {
      final response = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      final token = response.data['token']?.toString() ?? '';
      await _sessionManager.saveSession(accessToken: token);
      return Right(token);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<UserEntity>>> getUsers() async {
    try {
      final response = await _remote.fetchUsers();
      final data = response.data as List<dynamic>;
      final users = data
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(users);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    await _sessionManager.clearToken();
    return const Right(null);
  }
}
