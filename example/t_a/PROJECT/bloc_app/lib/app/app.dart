import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/di/injection.dart';
import '../core/di/bloc_providers.dart';
import '../features/settings/presentation/app_settings_cubit.dart';
import '../features/settings/presentation/app_settings_state.dart';

import '../core/localization/app_strings.dart';
import '../core/route_handler/app_router.dart';
import '../core/route_handler/app_routes.dart';

import '../core/route_handler/app_route_observer.dart';
import '../core/theme_handler/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
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
    );
  }
}
