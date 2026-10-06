import 'package:arcle/src/state_management.dart';
import 'package:arcle/src/templates/app_templates.dart';
import 'package:arcle/src/templates/core/constants_templates.dart';
import 'package:test/test.dart';

void main() {
  group('ConstantsTemplates', () {
    test('appConstants generates appName with project name', () {
      final code = ConstantsTemplates.appConstants(projectName: 'my_flutter_app');
      expect(code, contains("static const String appName = 'my_flutter_app';"));
    });
  });

  group('AppTemplates', () {
    test('app widget uses AppConstants.appName and imports constants.dart', () {
      final code = AppTemplates.app(StateManagement.bloc, projectName: 'task_app');
      expect(code, contains("import 'package:task_app/core/utils/constants.dart';"));
      expect(code, contains('title: AppConstants.appName'));
      expect(code, isNot(contains("title: 'Arcle Demo'")));
    });

    test('getx app widget uses AppConstants.appName and imports constants.dart', () {
      final code = AppTemplates.app(StateManagement.getx, projectName: 'task_app');
      expect(code, contains("import 'package:task_app/core/utils/constants.dart';"));
      expect(code, contains('title: AppConstants.appName'));
    });

    test('riverpod app widget uses AppConstants.appName and imports constants.dart', () {
      final code = AppTemplates.app(StateManagement.riverpod, projectName: 'task_app');
      expect(code, contains("import 'package:task_app/core/utils/constants.dart';"));
      expect(code, contains('title: AppConstants.appName'));
    });
  });
}
