import 'package:get/get.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_users_usecase.dart';

class UsersController extends GetxController {
  UsersController(this._getUsersUseCase);

  final GetUsersUseCase _getUsersUseCase;

  final users = <UserEntity>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    final result = await _getUsersUseCase();
    result.fold(
      (failure) => error.value = failure.message,
      (list) => users.assignAll(list),
    );
    loading.value = false;
  }
}
