class BlocProvidersTemplates {
  static String appBlocProviders() => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/demo/presentation/bloc/auth_bloc.dart';
import '../../features/demo/domain/usecases/login_usecase.dart';
import '../../features/demo/domain/usecases/logout_usecase.dart';
import '../../features/settings/presentation/app_settings_cubit.dart';
import 'injection.dart';
// arcle:feature_imports

class AppBlocProviders {
  static List<BlocProvider> providers = [
    BlocProvider<AppSettingsCubit>(create: (_) => AppSettingsCubit()),
    BlocProvider<AuthBloc>(
      create: (_) => AuthBloc(
        getIt<LoginUseCase>(),
        getIt<LogoutUseCase>(),
      ),
    ),
    // arcle:feature_providers
  ];
}
''';
}
