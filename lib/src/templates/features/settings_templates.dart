import '../../state_management.dart';

class SettingsTemplates {
  static String blocState() => '''
import 'package:flutter/material.dart';

class AppSettingsState {
  AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en', 'US'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}
''';

  static String blocCubit() => '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_settings_state.dart';

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(AppSettingsState());

  void toggleTheme(bool dark) {
    emit(state.copyWith(themeMode: dark ? ThemeMode.dark : ThemeMode.light));
  }

  void changeLocale(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}
''';

  static String getxController() => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  final themeMode = ThemeMode.light.obs;
  final locale = const Locale('en', 'US').obs;

  void toggleTheme(bool dark) {
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  void changeLocale(Locale value) {
    locale.value = value;
  }
}
''';

  static String riverpodNotifier() => '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettingsState {
  AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en', 'US'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  AppSettingsNotifier() : super(AppSettingsState());

  void toggleTheme(bool dark) {
    state = state.copyWith(
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void changeLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}
''';

  static String riverpodProvider() => '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings_notifier.dart';

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier();
});
''';

  static String settingsScreen(StateManagement state) {
    final stateImport = switch (state) {
      StateManagement.bloc => "import 'app_settings_cubit.dart';\n"
          "import 'app_settings_state.dart';\n"
          "import 'package:flutter_bloc/flutter_bloc.dart';\n",
      StateManagement.getx => "import 'app_settings_controller.dart';\n"
          "import 'package:get/get.dart';\n",
      StateManagement.riverpod =>
        "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
            "import 'app_settings_provider.dart';\n",
    };

    final body = switch (state) {
      StateManagement.bloc => _blocSettingsBody(),
      StateManagement.getx => _getxSettingsBody(),
      StateManagement.riverpod => _riverpodSettingsBody(),
    };

    return '''
import 'package:flutter/material.dart';
$stateImport
import '../../../core/localization/app_strings.dart';
import 'settings_body.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: $body,
    );
  }
}
''';
  }

  static String _blocSettingsBody() => '''
BlocBuilder<AppSettingsCubit, AppSettingsState>(
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
      )''';

  static String _getxSettingsBody() => '''
GetBuilder<AppSettingsController>(
        init: Get.find<AppSettingsController>(),
        builder: (controller) {
          return Obx(() {
            return SettingsBody(
              themeMode: controller.themeMode.value,
              locale: controller.locale.value,
              onThemeChanged: controller.toggleTheme,
              onLocaleChanged: controller.changeLocale,
            );
          });
        },
      )''';

  static String _riverpodSettingsBody() => '''
Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(appSettingsProvider);
          final notifier = ref.read(appSettingsProvider.notifier);
          return SettingsBody(
            themeMode: state.themeMode,
            locale: state.locale,
            onThemeChanged: notifier.toggleTheme,
            onLocaleChanged: notifier.changeLocale,
          );
        },
      )''';

  static String settingsBodyWidget(StateManagement state) {
    final dimensionAccess = state == StateManagement.getx
        ? 'Dimensions'
        : 'Dimensions(context)';
    final padding = state == StateManagement.getx
        ? 'Dimensions.allPadding(20)'
        : 'Dimensions(context).all(20)';
    return '''
import 'package:flutter/material.dart';

import '../../../core/common_widgets/common_checkbox.dart';
import '../../../core/common_widgets/common_dropdown.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/utils/dimensions.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({
    super.key, 
    required this.themeMode,
    required this.locale,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: $padding,
      children: [
        Text(
          context.tr('theme'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: ${dimensionAccess}.height(8)),
        CommonCheckbox(
          value: themeMode == ThemeMode.dark,
          label: context.tr('dark_mode'),
          onChanged: (value) => onThemeChanged(value ?? false),
        ),
        SizedBox(height: ${dimensionAccess}.height(16)),
        Text(
          context.tr('language'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: ${dimensionAccess}.height(8)),
        CommonDropdown<Locale>(
          value: locale,
          items: AppStrings.supportedLocales,
          itemLabel: (loc) => loc.languageCode.toUpperCase(),
          onChanged: (value) {
            if (value != null) onLocaleChanged(value);
          },
        ),
      ],
    );
  }
}
''';
  }

  static Map<String, String> files(StateManagement state) {
    final map = <String, String>{
      'lib/features/settings/presentation/settings_screen.dart':
          settingsScreen(state),
      'lib/features/settings/presentation/settings_body.dart':
          settingsBodyWidget(state),
    };

    switch (state) {
      case StateManagement.bloc:
        map['lib/features/settings/presentation/app_settings_state.dart'] =
            blocState();
        map['lib/features/settings/presentation/app_settings_cubit.dart'] =
            blocCubit();
      case StateManagement.getx:
        map['lib/features/settings/presentation/app_settings_controller.dart'] =
            getxController();
      case StateManagement.riverpod:
        map['lib/features/settings/presentation/app_settings_notifier.dart'] =
            riverpodNotifier();
        map['lib/features/settings/presentation/app_settings_provider.dart'] =
            riverpodProvider();
    }

    return map;
  }
}
