import '../state_management.dart';

class AppTemplates {
  static String bootstrap(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '''
import 'package:flutter/material.dart';

import 'core/di/app_di.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const App());
}
''';
      case StateManagement.getx:
        return '''
import 'package:flutter/material.dart';

import 'core/di/app_di.dart';
import 'core/env/env_factory.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvFactory.current();
  await AppDi().register(env);

  runApp(const App());
}
''';
      case StateManagement.riverpod:
        return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/app_di.dart';
import 'core/env/env_factory.dart';
import 'app/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = EnvFactory.current();
  final container = await AppDi().register(env);

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
    final appClass = switch (state) {
      StateManagement.bloc => 'MaterialApp',
      StateManagement.getx => 'GetMaterialApp',
      StateManagement.riverpod => 'MaterialApp',
    };

    final appBody = switch (state) {
      StateManagement.bloc => _blocAppBody(appClass),
      StateManagement.getx => _getxAppBody(appClass),
      StateManagement.riverpod => _riverpodAppBody(appClass),
    };

    final stateImports = switch (state) {
      StateManagement.bloc =>
        "import 'package:flutter_bloc/flutter_bloc.dart';\n"
            "import '../core/di/bloc_providers.dart';\n"
            "import '../features/settings/presentation/app_settings_cubit.dart';\n"
            "import '../features/settings/presentation/app_settings_state.dart';\n",
      StateManagement.getx =>
        "import 'package:get/get.dart';\n"
            "import '../features/settings/presentation/app_settings_controller.dart';\n"
            "import '../core/route_handler/getx_routes.dart';\n"
            "import '../core/localization/getx_localization.dart';\n",
      StateManagement.riverpod =>
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import '../features/settings/presentation/app_settings_provider.dart';\n",
    };

    final routeImports = switch (state) {
      StateManagement.getx => '',
      _ =>
        "import '../core/route_handler/app_router.dart';\n"
            "import '../core/route_handler/app_routes.dart';\n",
    };

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
$stateImports
import '../core/localization/app_strings.dart';
$routeImports
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

  static String _sharedMaterialApp(
    String appClass, {
    required String themeMode,
    required String locale,
  }) {
    const localizationDelegates = '''
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
''';
    return '''
$appClass(
          title: 'Arcle Demo',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: $themeMode,
          locale: $locale,
          supportedLocales: AppStrings.supportedLocales,
$localizationDelegates
          navigatorKey: AppRoutes.navigatorKey,
          initialRoute: AppRoutes.login,
          onGenerateRoute: AppRouter.onGenerateRoute,
        )''';
  }

  static String _blocAppBody(String appClass) {
    final material = _sharedMaterialApp(
      appClass,
      themeMode: 'settings.themeMode',
      locale: 'settings.locale',
    );
    return '''
MultiBlocProvider(
      providers: AppBlocProviders.providers,
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settings) {
          return $material;
        },
      ),
    )''';
  }

  static String _getxAppBody(String appClass) {
    return '''
GetBuilder<AppSettingsController>(
      init: Get.find<AppSettingsController>(),
      builder: (controller) {
        return Obx(() {
          final settings = controller;
          return $appClass(
            title: 'Arcle Demo',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode.value,
            locale: settings.locale.value,
            supportedLocales: AppStrings.supportedLocales,
            translations: Language(),
            fallbackLocale: const Locale('en', 'US'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: GetxRoutes.login,
            getPages: getxPages,
          );
        });
      },
    )''';
  }

  static String _riverpodAppBody(String appClass) {
    final material = _sharedMaterialApp(
      appClass,
      themeMode: 'settings.themeMode',
      locale: 'settings.locale',
    );
    return '''
Consumer(
      builder: (context, ref, _) {
        final settings = ref.watch(appSettingsProvider);
        return $material;
      },
    )''';
  }
}
