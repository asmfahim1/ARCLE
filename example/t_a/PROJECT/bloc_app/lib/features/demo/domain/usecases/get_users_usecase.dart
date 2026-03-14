import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/demo_repository.dart';

@injectable
class GetUsersUseCase {
  GetUsersUseCase(this._repo);

  final DemoRepository _repo;

  Future<Result<List<UserEntity>>> call() {
    return _repo.getUsers();
  }
}
