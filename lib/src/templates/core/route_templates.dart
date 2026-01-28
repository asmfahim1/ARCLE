class RouteTemplates {
  static String routes() => '''
import 'package:flutter/material.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const login = '/';
  static const users = '/users';
  static const settings = '/settings';
  // arcle:feature_routes
}
''';

  static String router() => '''
import 'package:flutter/material.dart';

import '../../features/demo/presentation/login_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/demo/presentation/user_list_screen.dart';
import 'app_routes.dart';
// arcle:feature_imports

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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
''';

  static String getxRoutes() => '''
import 'package:get/get.dart';

import '../../features/demo/presentation/login_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/demo/presentation/user_list_screen.dart';
// arcle:getx_imports

class GetxRoutes {
  static const login = '/';
  static const users = '/users';
  static const settings = '/settings';
}

final getxPages = <GetPage>[
  GetPage(name: GetxRoutes.login, page: () => const LoginScreen()),
  GetPage(name: GetxRoutes.users, page: () => UsersListScreen()),
  GetPage(name: GetxRoutes.settings, page: () => const SettingsScreen()),
  // arcle:getx_pages
];
''';
}
