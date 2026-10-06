import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../repositories/demo_repository.dart';

@injectable
class LogoutUseCase {
  LogoutUseCase(this._repo);
  final DemoRepository _repo;

  Future<Result<void>> call() {
    return _repo.logout();
  }
}
