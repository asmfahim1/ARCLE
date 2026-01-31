import '../../state_management.dart';

class RouteTemplates {
  static String routes() => '''
import 'package:flutter/material.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const login = '/';
  static const users = '/users';
  static const settings = '/settings';
  static String initialRoute = login;
  // arcle:feature_routes
}
''';

  static String observer() => '''
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_routes.dart';

class AppRouteStorage {
  static const _key = 'last_route';

  static Future<void> restoreInitialRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final route = prefs.getString(_key);
    if (route != null && route.isNotEmpty) {
      AppRoutes.initialRoute = route;
    }
  }

  static Future<void> save(String route) async {
    if (route.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, route);
  }
}

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _saveRoute(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    AppRouteStorage.save(name);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _saveRoute(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _saveRoute(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _saveRoute(previousRoute);
  }
}

final appRouteObserver = AppRouteObserver();
''';

  static String router(StateManagement state) {
    if (state == StateManagement.getx) {
      return _getxRouter();
    }
    return _defaultRouter();
  }

  static String _defaultRouter() => '''
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

  static String _getxRouter() => '''
import 'package:get/get.dart';

import '../../features/demo/presentation/bindings/demo_binding.dart';
import '../../features/demo/presentation/login_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/demo/presentation/user_list_screen.dart';
import 'app_routes.dart';
// arcle:feature_imports

class AppRouter {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: DemoBinding(),
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => UsersListScreen(),
      binding: DemoBinding(),
    ),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    // arcle:feature_pages
  ];
}
''';
}
