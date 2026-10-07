import 'package:get/get.dart';

import '../../features/demo/presentation/bindings/demo_binding.dart';
import '../../features/demo/presentation/pages/splash_screen.dart';
import '../../features/demo/presentation/pages/login_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/demo/presentation/pages/user_list_screen.dart';
import 'app_routes.dart';
// arcle:feature_imports

class AppRouter {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: DemoBinding(),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersListScreen(),
      binding: DemoBinding(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    // arcle:feature_pages
  ];
}
