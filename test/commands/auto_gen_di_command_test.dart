import 'package:arcle/src/commands/auto_gen_di_command.dart';
import 'package:test/test.dart';

void main() {
  group('AutoGenDiCommand', () {
    test('parser defaults to interactive', () {
      final results = AutoGenDiCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });

    test('parser supports path option with default', () {
      final results = AutoGenDiCommand.parser().parse([]);
      expect(results['path'], isNotNull);
      expect(results['path'], isNotEmpty);
    });

    test('parser supports custom path', () {
      final results =
          AutoGenDiCommand.parser().parse(['--path', '/custom/path']);
      expect(results['path'], '/custom/path');
    });

    test('parser supports help flag', () {
      final results = AutoGenDiCommand.parser().parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('parser supports short path option', () {
      final results = AutoGenDiCommand.parser().parse(['-p', '/custom/path']);
      expect(results['path'], '/custom/path');
    });
  });
}
