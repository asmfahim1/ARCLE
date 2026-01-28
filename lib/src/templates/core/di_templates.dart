import '../../state_management.dart';

class DiTemplates {
  static String di(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''
import '../notifications/notification_service.dart';
import 'injection.dart';

Future<void> setupDependencies() async {
  await configureDependencies();
  await getIt.allReady();
  await getIt<NotificationService>().init();
}
''';
      case StateManagement.getx:
        return '''
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api_client/api_service.dart';
import '../api_client/dio_client.dart';
import '../env/env.dart';
import '../notifications/notification_service.dart';
import '../permissions/permission_service.dart';
import '../session_manager/pref_manager.dart';
import '../session_manager/session_manager.dart';
import '../../features/demo/data/repositories/demo_repository_impl.dart';
import '../../features/demo/data/sources/demo_remote_data_source.dart';
import '../../features/demo/domain/usecases/get_users_usecase.dart';
import '../../features/demo/domain/usecases/login_usecase.dart';
import '../../features/demo/domain/usecases/logout_usecase.dart';
import '../../features/demo/presentation/controller/auth_controller.dart';
import '../../features/demo/presentation/controller/users_controller.dart';
import '../../features/settings/presentation/app_settings_controller.dart';

class AppDi {
  Future<void> register(Env env) async {
    final prefManager = PrefManager();
    final sessionManager = SessionManager(prefManager);
    final dioClient = DioClient(sessionManager);
    final apiService = ApiService(dioClient);
    final permissionService = PermissionService();
    final notifications =
        NotificationService(FlutterLocalNotificationsPlugin());
    await notifications.init();
    final remote = DemoRemoteDataSource(apiService);
    final demoRepository = DemoRepositoryImpl(remote, sessionManager);
    final loginUsecase = LoginUsecase(demoRepository);
    final logoutUsecase = LogoutUsecase(demoRepository);
    final getUsersUsecase = GetUsersUsecase(demoRepository);
    final authController = AuthController(loginUsecase, logoutUsecase);
    final usersController = UsersController(getUsersUsecase);

    Get.put(env, permanent: true);
    Get.put(prefManager, permanent: true);
    Get.put(sessionManager, permanent: true);
    Get.put(apiService, permanent: true);
    Get.put(permissionService, permanent: true);
    Get.put(notifications, permanent: true);
    Get.put(AppSettingsController(), permanent: true);
    Get.put(authController, permanent: true);
    Get.put(usersController, permanent: true);
  }
}
''';
      case StateManagement.riverpod:
        return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api_client/api_service.dart';
import '../api_client/dio_client.dart';
import '../env/env.dart';
import '../notifications/notification_service.dart';
import '../permissions/permission_service.dart';
import '../session_manager/session_manager.dart';
import '../session_manager/pref_manager.dart';
import 'providers.dart';

class AppDi {
  Future<ProviderContainer> register(Env env) async {
    final prefManager = PrefManager();
    final sessionManager = SessionManager(prefManager);
    final dioClient = DioClient(sessionManager);
    final apiService = ApiService(dioClient);
    final permissionService = PermissionService();
    final notifications =
        NotificationService(FlutterLocalNotificationsPlugin());
    await notifications.init();

    return ProviderContainer(
      overrides: [
        envProvider.overrideWithValue(env),
        prefManagerProvider.overrideWithValue(prefManager),
        sessionManagerProvider.overrideWithValue(sessionManager),
        apiServiceProvider.overrideWithValue(apiService),
        permissionServiceProvider.overrideWithValue(permissionService),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
  }
}
''';
    }
  }

  static String riverpodProviders() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client/api_service.dart';
import '../env/env.dart';
import '../notifications/notification_service.dart';
import '../permissions/permission_service.dart';
import '../session_manager/pref_manager.dart';
import '../session_manager/session_manager.dart';

final envProvider = Provider<Env>((ref) {
  throw UnimplementedError('Env is not initialized');
});

final sessionManagerProvider = Provider<SessionManager>((ref) {
  throw UnimplementedError('SessionManager is not initialized');
});

final prefManagerProvider = Provider<PrefManager>((ref) {
  throw UnimplementedError('PrefManager is not initialized');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  throw UnimplementedError('ApiService is not initialized');
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  throw UnimplementedError('PermissionService is not initialized');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService is not initialized');
});
''';

  static String blocInjection() => '''
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
''';

  static String blocInjectableModule() => '''
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session_manager/session_manager.dart';

@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  @lazySingleton
  FlutterLocalNotificationsPlugin get notificationsPlugin =>
      FlutterLocalNotificationsPlugin();
}
''';

  static String blocInjectionConfig() => '''
// GENERATED CODE - This is a stub. Run build_runner to regenerate.
// ignore_for_file: unused_import
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_client/api_service.dart';
import '../api_client/dio_client.dart';
import '../notifications/notification_service.dart';
import '../permissions/permission_service.dart';
import '../session_manager/pref_manager.dart';
import '../session_manager/session_manager.dart';
import 'injectable_module.dart';

GetIt init(GetIt getIt) {
  final module = AppModule();
  getIt.registerSingletonAsync<SharedPreferences>(
    () async => await SharedPreferences.getInstance(),
  );
  getIt.registerLazySingleton<PrefManager>(
    () => PrefManager(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<SessionManager>(
    () => SessionManager(getIt<PrefManager>()),
  );
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<PermissionService>(() => PermissionService());
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(module.notificationsPlugin),
  );
  return getIt;
}
''';
}
