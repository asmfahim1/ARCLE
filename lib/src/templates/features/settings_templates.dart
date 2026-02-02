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
  
  import '../../../core/localization/app_strings.dart';
  import '../../../core/session_manager/pref_manager.dart';
  import 'app_settings_state.dart';
  
  class AppSettingsCubit extends Cubit<AppSettingsState> {
    AppSettingsCubit(this._prefManager)
        : super(_initialState(_prefManager));
  
    final PrefManager _prefManager;
  
    static AppSettingsState _initialState(PrefManager prefManager) {
      try {
        final savedTheme = prefManager.getString(PrefKeys.themeMode);
        final savedLang = prefManager.getString(PrefKeys.languageCode);
  
        final themeMode =
            savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        var locale = const Locale('en', 'US');
  
        if (savedLang != null &&
            AppStrings.supportedLocales
                .any((loc) => loc.languageCode == savedLang)) {
          locale = Locale(savedLang);
        }
  
        return AppSettingsState(themeMode: themeMode, locale: locale);
      } catch (_) {
        return AppSettingsState();
      }
    }
  
    void toggleTheme(bool dark) {
      emit(state.copyWith(themeMode: dark ? ThemeMode.dark : ThemeMode.light));
      _prefManager.saveString(
        PrefKeys.themeMode,
        dark ? 'dark' : 'light',
      );
    }
  
    void changeLocale(Locale locale) {
      emit(state.copyWith(locale: locale));
      _prefManager.saveString(
        PrefKeys.languageCode,
        locale.languageCode,
      );
    }
  }
  ''';

  static String getxController() => '''
  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import '../../../core/localization/app_strings.dart';
  import '../../../core/session_manager/pref_manager.dart';
  
  class AppSettingsController extends GetxController {
    final PrefManager _prefManager = Get.find<PrefManager>();
    final themeMode = ThemeMode.light.obs;
    final locale = const Locale('en', 'US').obs;
  
    @override
    void onInit() {
      super.onInit();
      loadFromPrefs();
    }
  
    Future<void> loadFromPrefs() async {
      try {
        final savedTheme = await _prefManager.getString(PrefKeys.themeMode);
        final savedLang = await _prefManager.getString(PrefKeys.languageCode);
  
        if (savedTheme != null) {
          themeMode.value =
              savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
          Get.changeThemeMode(themeMode.value);
        }
  
        if (savedLang != null &&
            AppStrings.supportedLocales
                .any((loc) => loc.languageCode == savedLang)) {
          final newLocale = Locale(savedLang);
          locale.value = newLocale;
          Get.updateLocale(newLocale);
        }
      } catch (_) {
        // Use defaults if preferences are unavailable.
      }
    }
  
    void toggleTheme(bool dark) {
      themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
      Get.changeThemeMode(themeMode.value);
      _prefManager.saveString(
        PrefKeys.themeMode,
        dark ? 'dark' : 'light',
      );
    }
  
    void changeLocale(Locale value) {
      locale.value = value;
      Get.updateLocale(value);
      _prefManager.saveString(
        PrefKeys.languageCode,
        value.languageCode,
      );
    }
  }
  ''';

  static String riverpodNotifier() => '''
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  import '../../../core/localization/app_strings.dart';
  import '../../../core/session_manager/pref_manager.dart';
  
  /// Immutable state class for app settings.
  class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en', 'US'),
  });

  /// Current theme mode (light/dark/system).
  final ThemeMode themeMode;
  
  /// Current locale for localization.
  final Locale locale;

  /// Whether dark mode is enabled.
  bool get isDarkMode => themeMode == ThemeMode.dark;

  /// Creates a copy with the given fields replaced.
  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettingsState &&
        other.themeMode == themeMode &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(themeMode, locale);
}

  /// State notifier for managing app-wide settings.
  /// 
  /// Manages theme mode and locale settings with optional persistence.
  class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
    AppSettingsNotifier(this._prefManager) : super(const AppSettingsState());
  
    final PrefManager _prefManager;
  
    Future<void> loadFromPrefs() async {
      try {
        final savedTheme = await _prefManager.getString(PrefKeys.themeMode);
        final savedLang = await _prefManager.getString(PrefKeys.languageCode);
  
        final themeMode =
            savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        var locale = const Locale('en', 'US');
  
        if (savedLang != null &&
            AppStrings.supportedLocales
                .any((loc) => loc.languageCode == savedLang)) {
          locale = Locale(savedLang);
        }
  
        state = state.copyWith(themeMode: themeMode, locale: locale);
      } catch (_) {
        // Defaults already set; ignore persistence errors.
      }
    }
  
    /// Toggle between light and dark theme.
    void toggleTheme(bool dark) {
      state = state.copyWith(
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      );
      _prefManager.saveString(
        PrefKeys.themeMode,
        dark ? 'dark' : 'light',
      );
    }

  /// Set the theme mode directly.
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

    /// Change the app locale.
    void changeLocale(Locale locale) {
      state = state.copyWith(locale: locale);
      _prefManager.saveString(
        PrefKeys.languageCode,
        locale.languageCode,
      );
    }

  /// Reset settings to defaults.
  void reset() {
    state = const AppSettingsState();
  }
}
''';

  static String riverpodProvider() => '''
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  
  import 'app_settings_notifier.dart';
  import '../../../core/di/providers.dart';
  
  final appSettingsProvider =
      StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
    return AppSettingsNotifier(ref.watch(prefManagerProvider));
  });
  ''';

  static String settingsScreen(StateManagement state) {
      final stateImport = switch (state) {
        StateManagement.bloc => "import 'app_settings_cubit.dart';\n"
            "import 'app_settings_state.dart';\n"
            "import 'package:flutter_bloc/flutter_bloc.dart';\n"
            "import '../../../core/di/injection.dart';\n",
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
    final title = state == StateManagement.getx
        ? "Text('settings'.tr)"
        : "Text(context.tr('settings'))";

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
      appBar: AppBar(title: $title),
      body: $body,
    );
  }
}
''';
  }

    static String _blocSettingsBody() => '''
  BlocProvider<AppSettingsCubit>.value(
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
    final dimensionAccess =
        state == StateManagement.getx ? 'Dimensions' : 'Dimensions(context)';
    final padding = state == StateManagement.getx
        ? 'Dimensions.allPadding(20)'
        : 'Dimensions(context).all(20)';
    final getxImport =
        state == StateManagement.getx ? "import 'package:get/get.dart';\n" : '';
    final themeText =
        state == StateManagement.getx ? "'theme'.tr" : "context.tr('theme')";
    final darkModeText = state == StateManagement.getx
        ? "'dark_mode'.tr"
        : "context.tr('dark_mode')";
    final languageText = state == StateManagement.getx
        ? "'language'.tr"
        : "context.tr('language')";
    return '''
import 'package:flutter/material.dart';
$getxImport

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
          $themeText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: ${dimensionAccess}.height(8)),
        CommonCheckbox(
          value: themeMode == ThemeMode.dark,
          label: $darkModeText,
          onChanged: (value) => onThemeChanged(value ?? false),
        ),
        SizedBox(height: ${dimensionAccess}.height(16)),
        Text(
          $languageText,
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
