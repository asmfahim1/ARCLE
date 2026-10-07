import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import '../features/settings/presentation/app_settings_controller.dart';
import '../core/localization/getx_localization.dart';

import '../core/localization/app_strings.dart';
import '../core/route_handler/app_router.dart';
import '../core/route_handler/app_routes.dart';

import '../core/route_handler/app_route_observer.dart';
import '../core/theme_handler/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppSettingsController>(
      init: Get.find<AppSettingsController>(),
      builder: (controller) {
        return GetMaterialApp(
          title: 'Arcle Demo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
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
    );
  }
}
