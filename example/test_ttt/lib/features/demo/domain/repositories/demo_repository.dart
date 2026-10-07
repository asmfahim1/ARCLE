import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

abstract class DemoRepository {
  /// Auth
  Future<Result<String>> login(String email, String password);
  Future<Result<void>> logout();

  /// Users
  Future<Result<List<UserEntity>>> getUsers();
}
