class BlocProvidersTemplates {
  static String appBlocProviders() => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/demo/presentation/bloc/auth_bloc.dart';
import '../../features/demo/presentation/bloc/users_bloc.dart';
import '../../features/demo/domain/usecases/login_usecase.dart';
import '../../features/demo/domain/usecases/logout_usecase.dart';
import '../../features/demo/domain/usecases/get_users_usecase.dart';
import '../../features/settings/presentation/app_settings_cubit.dart';
import '../session_manager/pref_manager.dart';
import 'injection.dart';
// arcle:feature_imports

/// Centralized BLoC providers for the application.
/// 
/// All BLoCs are provided at the app level to ensure they are available
/// throughout the widget tree without needing to create them in individual screens.
class AppBlocProviders {
  /// Returns a list of all BLoC providers for the application.
  static List<BlocProvider> get providers => [
    BlocProvider<AppSettingsCubit>(
      create: (_) => AppSettingsCubit(getIt<PrefManager>()),
    ),
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(
        getIt<LoginUseCase>(),
        getIt<LogoutUseCase>(),
      ),
    ),
    BlocProvider<UsersBloc>(
      create: (_) => UsersBloc(getIt<GetUsersUseCase>()),
    ),
    // arcle:feature_providers
  ];

  /// Wraps the given child widget with MultiBlocProvider.
  static Widget wrapWithProviders(Widget child) {
    return MultiBlocProvider(
      providers: providers,
      child: child,
    );
  }
}
''';
}
