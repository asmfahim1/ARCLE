import 'package:get/get.dart';

import '../../../../core/api_client/api_service.dart';
import '../../../../core/session_manager/session_manager.dart';
import '../../data/repositories/demo_repository_impl.dart';
import '../../data/sources/demo_remote_data_source.dart';
import '../../domain/repositories/demo_repository.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../controller/auth_controller.dart';
import '../controller/users_controller.dart';

class DemoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DemoRemoteDataSource(Get.find<ApiService>()));
    Get.lazyPut<DemoRepository>(
      () => DemoRepositoryImpl(
        Get.find<DemoRemoteDataSource>(),
        Get.find<SessionManager>(),
      ),
    );
    Get.lazyPut(() => LoginUseCase(Get.find<DemoRepository>()));
    Get.lazyPut(() => LogoutUseCase(Get.find<DemoRepository>()));
    Get.lazyPut(() => GetUsersUseCase(Get.find<DemoRepository>()));
    Get.lazyPut(
      () => AuthController(
        Get.find<LoginUseCase>(),
        Get.find<LogoutUseCase>(),
      ),
    );
    Get.lazyPut(() => UsersController(Get.find<GetUsersUseCase>()));
  }
}
