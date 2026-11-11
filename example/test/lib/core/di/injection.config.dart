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
import 'package:test/core/di/injectable_module.dart' as _i40;
import 'package:test/core/network/api_service.dart' as _i384;
import 'package:test/core/network/dio_client.dart' as _i206;
import 'package:test/core/services/notification_service.dart' as _i249;
import 'package:test/core/services/permission_service.dart' as _i593;
import 'package:test/core/services/pref_manager.dart' as _i725;
import 'package:test/core/services/session_manager.dart' as _i307;
import 'package:test/features/demo/data/repositories/demo_repository_impl.dart'
    as _i626;
import 'package:test/features/demo/data/sources/demo_remote_data_source.dart'
    as _i567;
import 'package:test/features/demo/domain/repositories/demo_repository.dart'
    as _i1068;
import 'package:test/features/demo/domain/usecases/get_users_usecase.dart'
    as _i903;
import 'package:test/features/demo/domain/usecases/login_usecase.dart' as _i126;
import 'package:test/features/demo/domain/usecases/logout_usecase.dart'
    as _i305;

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
    gh.lazySingleton<_i593.PermissionService>(() => _i593.PermissionService());
    gh.factory<_i725.PrefManager>(
      () => _i725.PrefManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i249.NotificationService>(
      () => _i249.NotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i307.SessionManager>(
      () => _i307.SessionManager(gh<_i725.PrefManager>()),
    );
    gh.lazySingleton<_i206.DioClient>(
      () => _i206.DioClient(gh<_i307.SessionManager>()),
    );
    gh.lazySingleton<_i384.ApiService>(
      () => _i384.ApiService(gh<_i206.DioClient>()),
    );
    gh.factory<_i567.DemoRemoteDataSource>(
      () => _i567.DemoRemoteDataSource(gh<_i384.ApiService>()),
    );
    gh.lazySingleton<_i1068.DemoRepository>(
      () => _i626.DemoRepositoryImpl(
        gh<_i567.DemoRemoteDataSource>(),
        gh<_i307.SessionManager>(),
      ),
    );
    gh.factory<_i903.GetUsersUseCase>(
      () => _i903.GetUsersUseCase(gh<_i1068.DemoRepository>()),
    );
    gh.factory<_i126.LoginUseCase>(
      () => _i126.LoginUseCase(gh<_i1068.DemoRepository>()),
    );
    gh.factory<_i305.LogoutUseCase>(
      () => _i305.LogoutUseCase(gh<_i1068.DemoRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i40.AppModule {}
