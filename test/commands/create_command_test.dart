import 'package:arcle/src/commands/create_command.dart';
import 'package:test/test.dart';

void main() {
  group('CreateCommand', () {
    test('parser defaults to interactive', () {
      final results = CreateCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });

    test('parser has no-flutter-create flag', () {
      final results = CreateCommand.parser().parse(['--no-flutter-create']);
      expect(results['no-flutter-create'], isTrue);
    });

    test('parser no-flutter-create defaults to false', () {
      final results = CreateCommand.parser().parse([]);
      expect(results['no-flutter-create'], isFalse);
    });

    test('parser supports state option', () {
      final results = CreateCommand.parser().parse(['--state', 'bloc']);
      expect(results['state'], 'bloc');
    });

    test('parser supports all state options', () {
      expect(
          CreateCommand.parser().parse(['--state', 'bloc'])['state'], 'bloc');
      expect(
          CreateCommand.parser().parse(['--state', 'getx'])['state'], 'getx');
      expect(CreateCommand.parser().parse(['--state', 'riverpod'])['state'],
          'riverpod');
    });

    test('parser rejects invalid state option', () {
      expect(
        () => CreateCommand.parser().parse(['--state', 'invalid']),
        throwsA(isA<FormatException>()),
      );
    });

    test('parser supports path option with default', () {
      final results = CreateCommand.parser().parse([]);
      expect(results['path'], isNotNull);
      expect(results['path'], isNotEmpty);
    });

    test('parser supports org option', () {
      final results = CreateCommand.parser().parse(['--org', 'com.example']);
      expect(results['org'], 'com.example');
    });

    test('parser supports state-version option', () {
      final results =
          CreateCommand.parser().parse(['--state-version', '^1.0.0']);
      expect(results['state-version'], '^1.0.0');
    });

    test('parser supports force flag', () {
      final results = CreateCommand.parser().parse(['--force']);
      expect(results['force'], isTrue);
    });

    test('parser supports help flag', () {
      final results = CreateCommand.parser().parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('parser supports short options', () {
      expect(CreateCommand.parser().parse(['-s', 'bloc'])['state'], 'bloc');
      expect(CreateCommand.parser().parse(['-f'])['force'], isTrue);
      expect(CreateCommand.parser().parse(['-h'])['help'], isTrue);
    });
  });
}
