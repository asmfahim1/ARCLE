import 'package:flutter/material.dart';
import 'package:get/get.dart';


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
      padding: Dimensions.allPadding(20),
      children: [
        Text(
          'theme'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: Dimensions.height(8)),
        CommonCheckbox(
          value: themeMode == ThemeMode.dark,
          label: 'dark_mode'.tr,
          onChanged: (value) => onThemeChanged(value ?? false),
        ),
        SizedBox(height: Dimensions.height(16)),
        Text(
          'language'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: Dimensions.height(8)),
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
