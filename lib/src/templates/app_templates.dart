import '../state_management.dart';

class AppTemplates {
  static String bootstrap(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''
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
''';
      case StateManagement.getx:
        return '''
import 'package:flutter/material.dart';

import 'core/di/app_di.dart';
import 'core/env/env_factory.dart';
import 'core/route_handler/app_route_observer.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvFactory.current();
  await AppDi().register(env);
  await AppRouteStorage.restoreInitialRoute();

  runApp(const App());
}
''';
      case StateManagement.riverpod:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/app_di.dart';
import 'core/env/env_factory.dart';
import 'core/route_handler/app_route_observer.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvFactory.current();
  final container = await AppDi().register(env);
  await AppRouteStorage.restoreInitialRoute();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
''';
    }
  }

  static String app(StateManagement state) {
    final stateImports = switch (state) {
      StateManagement.bloc => "import 'package:flutter_bloc/flutter_bloc.dart';\n"
          "import '../core/di/injection.dart';\n"
          "import '../core/di/bloc_providers.dart';\n"
          "import '../features/settings/presentation/app_settings_cubit.dart';\n"
          "import '../features/settings/presentation/app_settings_state.dart';\n",
      StateManagement.getx => "import 'package:get/get.dart';\n"
          "import '../features/settings/presentation/app_settings_controller.dart';\n"
          "import '../core/localization/getx_localization.dart';\n",
      StateManagement.riverpod =>
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import '../features/settings/presentation/app_settings_provider.dart';\n",
    };

    final routeImports = "import '../core/route_handler/app_router.dart';\n"
        "import '../core/route_handler/app_routes.dart';\n";

    final appBody = switch (state) {
      StateManagement.bloc => _blocAppBody(),
      StateManagement.getx => _getxAppBody(),
      StateManagement.riverpod => _riverpodAppBody(),
    };

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
$stateImports
import '../core/localization/app_strings.dart';
$routeImports
import '../core/route_handler/app_route_observer.dart';
import '../core/theme_handler/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return $appBody;
  }
}
''';
  }

  static String mainEntry() {
    return '''
import 'bootstrap.dart';

Future<void> main() async {
  await bootstrap();
}
''';
  }

  static String _blocAppBody() {
    return '''
MultiBlocProvider(
      providers: AppBlocProviders.providers,
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: getIt<AppSettingsCubit>(),
        builder: (context, settings) {
          return MaterialApp(
            title: 'Arcle Demo',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: AppStrings.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            navigatorObservers: [appRouteObserver],
            navigatorKey: AppRoutes.navigatorKey,
            initialRoute: AppRoutes.initialRoute,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    )''';
  }

  static String _getxAppBody() {
    return '''
GetBuilder<AppSettingsController>(
      init: Get.find<AppSettingsController>(),
      builder: (controller) {
        return GetMaterialApp(
          title: 'Arcle Demo',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: controller.themeMode.value,
          locale: controller.locale.value,
          supportedLocales: AppStrings.supportedLocales,
          translations: Language(),
          fallbackLocale: const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          navigatorObservers: [appRouteObserver],
          initialRoute: AppRoutes.initialRoute,
          getPages: AppRouter.pages,
        );
      },
    )''';
  }

  static String _riverpodAppBody() {
    return '''
Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(appSettingsProvider);
        return MaterialApp(
          title: 'Arcle Demo',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          navigatorObservers: [appRouteObserver],
          navigatorKey: AppRoutes.navigatorKey,
          initialRoute: AppRoutes.initialRoute,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    )''';
  }
}
