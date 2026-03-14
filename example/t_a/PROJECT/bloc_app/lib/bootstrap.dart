import 'package:flutter/material.dart';

import 'core/di/app_di.dart';
import 'core/route_handler/app_route_observer.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();
  await AppRouteStorage.restoreInitialRoute();

  runApp(const App());
}
