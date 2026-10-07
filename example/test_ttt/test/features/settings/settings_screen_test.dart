  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:get/get.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  
  import '../../../lib/core/session_manager/pref_manager.dart';
  import '../../../lib/features/settings/presentation/app_settings_controller.dart';
  import '../../../lib/features/settings/presentation/settings_screen.dart';
  
  void main() {
    testWidgets('Settings screen renders', (tester) async {
      SharedPreferences.setMockInitialValues({});
      Get.put(PrefManager(), permanent: true);
      Get.put(AppSettingsController(), permanent: true);
      await tester.pumpWidget(
        const MaterialApp(
        home: SettingsScreen(),
        locale: Locale('en'),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
