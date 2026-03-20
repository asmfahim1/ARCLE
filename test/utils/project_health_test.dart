import 'dart:io';

import 'package:arcle/src/state_management.dart';
import 'package:arcle/src/utils/project_health.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectHealthValidator', () {
    test('reports missing arcle config and dependencies', () async {
      final tempDir = Directory.systemTemp.createTempSync('arcle_health_');
      try {
        File('${tempDir.path}${Platform.pathSeparator}pubspec.yaml')
            .writeAsStringSync('''
name: sample
dependencies:
  flutter:
    sdk: flutter
flutter:
  uses-material-design: true
''');
        Directory(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}route_handler',
        ).createSync(recursive: true);
        Directory(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}features',
        ).createSync(recursive: true);
        File(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}route_handler${Platform.pathSeparator}app_routes.dart',
        ).writeAsStringSync('');
        File(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}route_handler${Platform.pathSeparator}app_router.dart',
        ).writeAsStringSync('');

        final report = await ProjectHealthValidator().validate(
          targetDir: tempDir,
          explicitState: StateManagement.bloc,
          includeEnvironment: false,
        );

        expect(report.state, StateManagement.bloc);
        expect(
          report.issues.any((issue) => issue.code == 'missing_arcle_config'),
          isTrue,
        );
        expect(
          report.issues.any((issue) => issue.code == 'missing_dep_dio'),
          isTrue,
        );
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('passes a healthy minimal riverpod project', () async {
      final tempDir = Directory.systemTemp.createTempSync('arcle_health_');
      try {
        File('${tempDir.path}${Platform.pathSeparator}pubspec.yaml')
            .writeAsStringSync('''
name: sample
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  permission_handler: ^11.3.0
  dartz: ^0.10.1
  flutter_local_notifications: 18.0.1
  timezone: ^0.9.4
  google_fonts: any
  flutter_svg: any
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: any
  equatable: any
flutter:
  uses-material-design: true
''');
        File('${tempDir.path}${Platform.pathSeparator}arcle.yaml')
            .writeAsStringSync('''
state: riverpod
state_option: 3
created_at: 2026-03-20T10:00:00.000
''');
        Directory(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}di',
        ).createSync(recursive: true);
        Directory(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}route_handler',
        ).createSync(recursive: true);
        Directory(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}features',
        ).createSync(recursive: true);
        File(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}di${Platform.pathSeparator}app_di.dart',
        ).writeAsStringSync('');
        File(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}di${Platform.pathSeparator}providers.dart',
        ).writeAsStringSync('');
        File(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}route_handler${Platform.pathSeparator}app_routes.dart',
        ).writeAsStringSync('');
        File(
          '${tempDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}route_handler${Platform.pathSeparator}app_router.dart',
        ).writeAsStringSync('');

        final report = await ProjectHealthValidator().validate(
          targetDir: tempDir,
          includeEnvironment: false,
        );

        expect(report.issues, isEmpty);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
