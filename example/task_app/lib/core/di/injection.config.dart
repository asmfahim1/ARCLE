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
import 'package:task_app/core/api_client/api_service.dart' as _i402;
import 'package:task_app/core/api_client/dio_client.dart' as _i142;
import 'package:task_app/core/di/injectable_module.dart' as _i354;
import 'package:task_app/core/notifications/notification_service.dart' as _i995;
import 'package:task_app/core/permissions/permission_service.dart' as _i244;
import 'package:task_app/core/session_manager/pref_manager.dart' as _i873;
import 'package:task_app/core/session_manager/session_manager.dart' as _i639;
import 'package:task_app/features/demo/data/repositories/demo_repository_impl.dart'
    as _i881;
import 'package:task_app/features/demo/data/sources/demo_remote_data_source.dart'
    as _i238;
import 'package:task_app/features/demo/domain/repositories/demo_repository.dart'
    as _i689;
import 'package:task_app/features/demo/domain/usecases/get_users_usecase.dart'
    as _i609;
import 'package:task_app/features/demo/domain/usecases/login_usecase.dart'
    as _i1013;
import 'package:task_app/features/demo/domain/usecases/logout_usecase.dart'
    as _i1016;

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
    gh.lazySingleton<_i244.PermissionService>(() => _i244.PermissionService());
    gh.factory<_i873.PrefManager>(
      () => _i873.PrefManager(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i995.NotificationService>(
      () => _i995.NotificationService(
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.factory<_i639.SessionManager>(
      () => _i639.SessionManager(gh<_i873.PrefManager>()),
    );
    gh.lazySingleton<_i142.DioClient>(
      () => _i142.DioClient(gh<_i639.SessionManager>()),
    );
    gh.lazySingleton<_i402.ApiService>(
      () => _i402.ApiService(gh<_i142.DioClient>()),
    );
    gh.factory<_i238.DemoRemoteDataSource>(
      () => _i238.DemoRemoteDataSource(gh<_i402.ApiService>()),
    );
    gh.lazySingleton<_i689.DemoRepository>(
      () => _i881.DemoRepositoryImpl(
        gh<_i238.DemoRemoteDataSource>(),
        gh<_i639.SessionManager>(),
      ),
    );
    gh.factory<_i609.GetUsersUseCase>(
      () => _i609.GetUsersUseCase(gh<_i689.DemoRepository>()),
    );
    gh.factory<_i1013.LoginUseCase>(
      () => _i1013.LoginUseCase(gh<_i689.DemoRepository>()),
    );
    gh.factory<_i1016.LogoutUseCase>(
      () => _i1016.LogoutUseCase(gh<_i689.DemoRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i354.AppModule {}
