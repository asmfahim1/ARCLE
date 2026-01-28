class BlocProvidersTemplates {
  static String appBlocProviders() => '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/demo/presentation/bloc/auth_bloc.dart';
import '../../features/settings/presentation/app_settings_cubit.dart';
import 'injection.dart';
// arcle:feature_imports

class AppBlocProviders {
  static List<BlocProvider> providers = [
    BlocProvider<AppSettingsCubit>(create: (_) => AppSettingsCubit()),
    BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
    // arcle:feature_providers
  ];
}
''';
}
