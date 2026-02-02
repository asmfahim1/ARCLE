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
  import '../../features/settings/presentation/app_settings_controller.dart';

class AppDi {
  Future<void> register(Env env) async {
    // Environment config (base URLs, flavor, feature toggles).
    Get.put(env, permanent: true);

    // Local storage used by SessionManager and other services.
    final prefManager = PrefManager();
    Get.put(prefManager, permanent: true);

    // Session/auth data for API calls and app state.
    final sessionManager = SessionManager(prefManager);
    Get.put(sessionManager, permanent: true);

    // Network stack shared across repositories.
    final dioClient = DioClient(sessionManager);
    final apiService = ApiService(dioClient);
    Get.put(apiService, permanent: true);

    // Permissions used by core services/features.
    final permissionService = PermissionService();
    Get.put(permissionService, permanent: true);

    // Push/local notifications initialized once app-wide.
    final notifications =
        NotificationService(FlutterLocalNotificationsPlugin());
    await notifications.init();
    Get.put(notifications, permanent: true);

      // App-wide settings controller (theme/locale) used by App widget.
      Get.put(AppSettingsController(), permanent: true);
      await Get.find<AppSettingsController>().loadFromPrefs();
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
  import '../../features/settings/presentation/app_settings_provider.dart';
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

      final container = ProviderContainer(
        overrides: [
          envProvider.overrideWithValue(env),
          prefManagerProvider.overrideWithValue(prefManager),
          sessionManagerProvider.overrideWithValue(sessionManager),
          apiServiceProvider.overrideWithValue(apiService),
          permissionServiceProvider.overrideWithValue(permissionService),
          notificationServiceProvider.overrideWithValue(notifications),
        ],
      );
  
      await container.read(appSettingsProvider.notifier).loadFromPrefs();
      return container;
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
// arcle:feature_imports

// ============================================================================
// Core Providers - Overridden in AppDi.register()
// ============================================================================

/// Environment configuration provider.
/// Overridden at startup with the current environment (local/stag/prod).
final envProvider = Provider<Env>((ref) {
  throw UnimplementedError('Env is not initialized. Call AppDi.register() first.');
});

/// Session manager for handling authentication state and tokens.
final sessionManagerProvider = Provider<SessionManager>((ref) {
  throw UnimplementedError('SessionManager is not initialized. Call AppDi.register() first.');
});

/// Preference manager for persistent key-value storage.
final prefManagerProvider = Provider<PrefManager>((ref) {
  throw UnimplementedError('PrefManager is not initialized. Call AppDi.register() first.');
});

/// API service for making HTTP requests.
final apiServiceProvider = Provider<ApiService>((ref) {
  throw UnimplementedError('ApiService is not initialized. Call AppDi.register() first.');
});

/// Permission service for handling runtime permissions.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  throw UnimplementedError('PermissionService is not initialized. Call AppDi.register() first.');
});

/// Notification service for local and push notifications.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('NotificationService is not initialized. Call AppDi.register() first.');
});

// ============================================================================
// Feature Provider Exports
// ============================================================================
// arcle:feature_exports
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
  import '../../features/settings/presentation/app_settings_cubit.dart';
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
    getIt.registerLazySingleton<AppSettingsCubit>(
      () => AppSettingsCubit(getIt<PrefManager>()),
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
