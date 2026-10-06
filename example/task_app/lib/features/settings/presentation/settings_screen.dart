import 'package:flutter/material.dart';
import 'app_settings_cubit.dart';
import 'app_settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';

import '../../../core/localization/app_strings.dart';
import 'settings_body.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body:   BlocProvider<AppSettingsCubit>.value(
          value: getIt<AppSettingsCubit>(),
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, state) {
              return SettingsBody(
                themeMode: state.themeMode,
                locale: state.locale,
                onThemeChanged: (value) =>
                    context.read<AppSettingsCubit>().toggleTheme(value),
                onLocaleChanged: (value) =>
                    context.read<AppSettingsCubit>().changeLocale(value),
              );
            },
          ),
        ),
    );
  }
}
