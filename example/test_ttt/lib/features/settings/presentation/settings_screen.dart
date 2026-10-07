import 'package:flutter/material.dart';
import 'app_settings_controller.dart';
import 'package:get/get.dart';

import '../../../core/localization/app_strings.dart';
import 'settings_body.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: GetBuilder<AppSettingsController>(
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
      ),
    );
  }
}
