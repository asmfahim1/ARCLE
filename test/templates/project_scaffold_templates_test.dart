import 'package:arcle/src/generators/state/common_project_files.dart';
import 'package:arcle/src/state_management.dart';
import 'package:arcle/src/templates/app_templates.dart';
import 'package:arcle/src/templates/core/route_templates.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectScaffoldTemplates', () {
    test(
      'buildCommonProjectFiles registers .env, .env.example, and common_retry_widget',
      () {
        final files = buildCommonProjectFiles(StateManagement.bloc);
        expect(files.containsKey('.env'), isTrue);
        expect(files.containsKey('.env.example'), isTrue);
        expect(
          files.containsKey('lib/core/common_widgets/common_retry_widget.dart'),
          isTrue,
        );
        expect(files['.env'], contains('FLAVOR=stag'));
        expect(
          files['.env.example'],
          contains('PROD_API_BASE_URL=https://api.example.com'),
        );
      },
    );

    test(
      'bootstrap comments out restoreInitialRoute across all state managements',
      () {
        for (final state in StateManagement.values) {
          final code = AppTemplates.bootstrap(state);
          expect(
            code,
            contains(
              '// To restore the last visited screen across app restarts, uncomment:',
            ),
          );
          expect(
            code,
            contains('// await AppRouteStorage.restoreInitialRoute();'),
          );
          expect(
            code,
            contains(
              '// import \'core/route_handler/app_route_observer.dart\';',
            ),
          );
          expect(
            code,
            isNot(contains('\n  await AppRouteStorage.restoreInitialRoute();')),
          );
        }
      },
    );

    test('app comments out navigatorObservers across all state managements', () {
      for (final state in StateManagement.values) {
        final code = AppTemplates.app(state, projectName: 'test_app');
        expect(
          code,
          contains(
            '// To observe routes or track route changes, uncomment the line below:',
          ),
        );
        expect(code, contains('// navigatorObservers: [appRouteObserver],'));
        expect(
          code,
          isNot(
            contains('\n            navigatorObservers: [appRouteObserver],'),
          ),
        );
      }
    });

    test(
      'route observer template provides clear documentation for developers',
      () {
        final code = RouteTemplates.observer();
        expect(
          code,
          contains(
            'Handles persistent storage of the user\'s last visited route.',
          ),
        );
        expect(
          code,
          contains(
            'Route observer that saves each navigated route to [AppRouteStorage].',
          ),
        );
      },
    );
  });
}
