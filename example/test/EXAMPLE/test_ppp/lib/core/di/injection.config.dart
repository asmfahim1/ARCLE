// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:test_ppp/core/di/injectable_module.dart' as _i407;
import 'package:test_ppp/core/network/api_service.dart' as _i778;
import 'package:test_ppp/core/network/dio_client.dart' as _i455;
import 'package:test_ppp/core/services/notification_service.dart' as _i617;
import 'package:test_ppp/core/services/permission_service.dart' as _i617;
import 'package:test_ppp/core/services/pref_manager.dart' as _i183;
import 'package:test_ppp/core/services/session_manager.dart' as _i981;
import 'package:test_ppp/features/demo/data/repositories/demo_repository_impl.dart'
    as _i509;
import 'package:test_ppp/features/demo/data/sources/demo_remote_data_source.dart'
    as _i245;
import 'package:test_ppp/features/demo/domain/repositories/demo_repository.dart'
    as _i17;
import 'package:test_ppp/features/demo/domain/usecases/get_users_usecase.dart'
    as _i73;
import 'package:test_ppp/features/demo/domain/usecases/login_usecase.dart'
    as _i627;
import 'package:test_ppp/features/demo/domain/usecases/logout_usecase.dart'
    as _i774;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => appModule.notificationsPlugin,
    );
    gh.lazySingleton<_i617.PermissionService>(() => _i617.PermissionService());
    gh.factory<_i183.PrefManager>(
      () => _i183.PrefManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i617.NotificationService>(
      () => _i617.NotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i981.SessionManager>(
      () => _i981.SessionManager(gh<_i183.PrefManager>()),
    );
    gh.lazySingleton<_i455.DioClient>(
      () => _i455.DioClient(gh<_i981.SessionManager>()),
    );
    gh.lazySingleton<_i778.ApiService>(
      () => _i778.ApiService(gh<_i455.DioClient>()),
    );
    gh.factory<_i245.DemoRemoteDataSource>(
      () => _i245.DemoRemoteDataSource(gh<_i778.ApiService>()),
    );
    gh.lazySingleton<_i17.DemoRepository>(
      () => _i509.DemoRepositoryImpl(
        gh<_i245.DemoRemoteDataSource>(),
        gh<_i981.SessionManager>(),
      ),
    );
    gh.factory<_i73.GetUsersUseCase>(
      () => _i73.GetUsersUseCase(gh<_i17.DemoRepository>()),
    );
    gh.factory<_i627.LoginUseCase>(
      () => _i627.LoginUseCase(gh<_i17.DemoRepository>()),
    );
    gh.factory<_i774.LogoutUseCase>(
      () => _i774.LogoutUseCase(gh<_i17.DemoRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i407.AppModule {}
