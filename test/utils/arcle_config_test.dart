import 'dart:io';
import 'package:arcle/src/utils/arcle_config.dart';
import 'package:arcle/src/state_management.dart';
import 'package:test/test.dart';

void main() {
  group('ArcleConfig', () {
    test('toYaml generates correct YAML format', () {
      final config = ArcleConfig(
        state: StateManagement.bloc,
        createdAt: DateTime(2026, 3, 14, 10, 0, 0),
      );

      final yaml = config.toYaml();

      expect(yaml, contains('state: bloc'));
      expect(yaml, contains('state_option: 1'));
      expect(yaml, contains('created_at: 2026-03-14T10:00:00.000'));
    });

    test('toYaml works for all state management options', () {
      for (final state in StateManagement.values) {
        final config = ArcleConfig(
          state: state,
          createdAt: DateTime(2026, 3, 14),
        );

        final yaml = config.toYaml();

        expect(yaml, contains('state: ${state.id}'));
        expect(yaml, contains('state_option: ${state.option}'));
      }
    });

    test('readFrom returns null for non-existent file', () {
      final tempDir = Directory.systemTemp.createTempSync('arcle_test_');

      try {
        final config = ArcleConfig.readFrom(tempDir);
        expect(config, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('readFrom correctly parses valid YAML', () {
      final tempDir = Directory.systemTemp.createTempSync('arcle_test_');

      try {
        final configFile =
            File('${tempDir.path}${Platform.pathSeparator}arcle.yaml');
        configFile.writeAsStringSync('''state: bloc
state_option: 1
created_at: 2026-03-14T10:00:00.000
''');

        final config = ArcleConfig.readFrom(tempDir);

        expect(config, isNotNull);
        expect(config?.state, StateManagement.bloc);
        expect(config?.createdAt.year, 2026);
        expect(config?.createdAt.month, 3);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('readFrom returns null for invalid YAML', () {
      final tempDir = Directory.systemTemp.createTempSync('arcle_test_');

      try {
        final configFile =
            File('${tempDir.path}${Platform.pathSeparator}arcle.yaml');
        configFile.writeAsStringSync('invalid: data\n');

        final config = ArcleConfig.readFrom(tempDir);

        expect(config, isNull);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('readFrom skips commented lines', () {
      final tempDir = Directory.systemTemp.createTempSync('arcle_test_');

      try {
        final configFile =
            File('${tempDir.path}${Platform.pathSeparator}arcle.yaml');
        configFile.writeAsStringSync('''# This is a comment
state: getx
state_option: 2
# Another comment
created_at: 2026-03-14T10:00:00.000
''');

        final config = ArcleConfig.readFrom(tempDir);

        expect(config, isNotNull);
        expect(config?.state, StateManagement.getx);
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('filename constant is correct', () {
      expect(ArcleConfig.filename, 'arcle.yaml');
    });
  });
}
