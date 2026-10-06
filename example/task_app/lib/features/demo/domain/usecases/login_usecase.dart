import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../repositories/demo_repository.dart';

@injectable
class LoginUseCase {
  LoginUseCase(this._repo);

  final DemoRepository _repo;

  Future<Result<String>> call({
    required String email,
    required String password,
  }) {
    return _repo.login(email, password);
  }
}
