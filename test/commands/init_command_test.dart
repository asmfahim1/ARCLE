import 'package:arcle/src/commands/init_command.dart';
import 'package:test/test.dart';

void main() {
  group('InitCommand', () {
    test('parser defaults to interactive', () {
      final results = InitCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });

    test('parser supports state option', () {
      final results = InitCommand.parser().parse(['--state', 'bloc']);
      expect(results['state'], 'bloc');
    });

    test('parser supports all state options', () {
      expect(InitCommand.parser().parse(['--state', 'bloc'])['state'], 'bloc');
      expect(InitCommand.parser().parse(['--state', 'getx'])['state'], 'getx');
      expect(InitCommand.parser().parse(['--state', 'riverpod'])['state'],
          'riverpod');
    });

    test('parser rejects invalid state option', () {
      expect(
        () => InitCommand.parser().parse(['--state', 'invalid']),
        throwsA(isA<FormatException>()),
      );
    });

    test('parser supports path option', () {
      final results = InitCommand.parser().parse(['--path', '/some/path']);
      expect(results['path'], '/some/path');
    });

    test('parser supports force flag', () {
      final results = InitCommand.parser().parse(['--force']);
      expect(results['force'], isTrue);
    });

    test('parser supports help flag', () {
      final results = InitCommand.parser().parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('parser supports short options', () {
      expect(InitCommand.parser().parse(['-s', 'bloc'])['state'], 'bloc');
      expect(InitCommand.parser().parse(['-f'])['force'], isTrue);
      expect(InitCommand.parser().parse(['-h'])['help'], isTrue);
    });

    test('parser defaults path to current directory', () {
      final results = InitCommand.parser().parse([]);
      expect(results['path'], isNotNull);
      expect(results['path'], isNotEmpty);
    });

    test('parser has help flag by default', () {
      final parser = InitCommand.parser();
      expect(parser.options.containsKey('help'), isTrue);
    });
  });
}
