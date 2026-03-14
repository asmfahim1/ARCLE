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
