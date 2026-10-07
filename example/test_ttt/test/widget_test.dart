import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../lib/app/app.dart';
import '../lib/features/settings/presentation/app_settings_controller.dart';

void main() {
  testWidgets('App builds', (tester) async {
    Get.put(AppSettingsController(), permanent: true);
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
