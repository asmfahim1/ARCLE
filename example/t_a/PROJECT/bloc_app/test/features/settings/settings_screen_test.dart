import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bloc_app/core/session_manager/pref_manager.dart';
import 'package:bloc_app/features/settings/presentation/app_settings_cubit.dart';
import 'package:bloc_app/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets('Settings screen renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final prefManager = PrefManager(prefs);
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AppSettingsCubit(prefManager),
        child: const MaterialApp(home: SettingsScreen(), locale: Locale('en')),
      ),
    );
    expect(find.text('Settings'), findsOneWidget);
  });
}
