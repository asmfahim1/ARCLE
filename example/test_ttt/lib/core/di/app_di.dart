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
  