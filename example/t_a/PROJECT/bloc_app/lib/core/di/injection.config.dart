// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:bloc_app/core/api_client/api_service.dart' as _i364;
import 'package:bloc_app/core/api_client/dio_client.dart' as _i525;
import 'package:bloc_app/core/di/injectable_module.dart' as _i955;
import 'package:bloc_app/core/notifications/notification_service.dart' as _i631;
import 'package:bloc_app/core/permissions/permission_service.dart' as _i107;
import 'package:bloc_app/core/session_manager/pref_manager.dart' as _i121;
import 'package:bloc_app/core/session_manager/session_manager.dart' as _i69;
import 'package:bloc_app/features/demo/data/repositories/demo_repository_impl.dart'
    as _i823;
import 'package:bloc_app/features/demo/data/sources/demo_remote_data_source.dart'
    as _i575;
import 'package:bloc_app/features/demo/domain/repositories/demo_repository.dart'
    as _i563;
import 'package:bloc_app/features/demo/domain/usecases/get_users_usecase.dart'
    as _i818;
import 'package:bloc_app/features/demo/domain/usecases/login_usecase.dart'
    as _i579;
import 'package:bloc_app/features/demo/domain/usecases/logout_usecase.dart'
    as _i1043;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

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
    gh.lazySingleton<_i107.PermissionService>(() => _i107.PermissionService());
    gh.factory<_i121.PrefManager>(
      () => _i121.PrefManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i631.NotificationService>(
      () => _i631.NotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i69.SessionManager>(
      () => _i69.SessionManager(gh<_i121.PrefManager>()),
    );
    gh.lazySingleton<_i525.DioClient>(
      () => _i525.DioClient(gh<_i69.SessionManager>()),
    );
    gh.lazySingleton<_i364.ApiService>(
      () => _i364.ApiService(gh<_i525.DioClient>()),
    );
    gh.factory<_i575.DemoRemoteDataSource>(
      () => _i575.DemoRemoteDataSource(gh<_i364.ApiService>()),
    );
    gh.lazySingleton<_i563.DemoRepository>(
      () => _i823.DemoRepositoryImpl(
        gh<_i575.DemoRemoteDataSource>(),
        gh<_i69.SessionManager>(),
      ),
    );
    gh.factory<_i818.GetUsersUseCase>(
      () => _i818.GetUsersUseCase(gh<_i563.DemoRepository>()),
    );
    gh.factory<_i579.LoginUseCase>(
      () => _i579.LoginUseCase(gh<_i563.DemoRepository>()),
    );
    gh.factory<_i1043.LogoutUseCase>(
      () => _i1043.LogoutUseCase(gh<_i563.DemoRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i955.AppModule {}
