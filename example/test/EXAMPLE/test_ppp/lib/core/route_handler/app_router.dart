import 'package:flutter/material.dart';

import '../../features/demo/presentation/pages/splash_screen.dart';
import '../../features/demo/presentation/pages/login_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/demo/presentation/pages/user_list_screen.dart';
import 'app_routes.dart';
// arcle:feature_imports

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.users:
        return MaterialPageRoute(builder: (_) => const UsersListScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      // arcle:feature_cases
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
