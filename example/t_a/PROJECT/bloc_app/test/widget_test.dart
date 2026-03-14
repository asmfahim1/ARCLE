import 'package:flutter_test/flutter_test.dart';

import 'package:bloc_app/app/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
