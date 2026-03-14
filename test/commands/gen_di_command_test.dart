import 'package:arcle/src/commands/gen_di_command.dart';
import 'package:test/test.dart';

void main() {
  group('GenDiCommand', () {
    test('parser defaults to interactive', () {
      final results = GenDiCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });

    test('parser supports path option with default', () {
      final results = GenDiCommand.parser().parse([]);
      expect(results['path'], isNotNull);
      expect(results['path'], isNotEmpty);
    });

    test('parser supports custom path', () {
      final results = GenDiCommand.parser().parse(['--path', '/custom/path']);
      expect(results['path'], '/custom/path');
    });

    test('parser supports help flag', () {
      final results = GenDiCommand.parser().parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('parser supports short path option', () {
      final results = GenDiCommand.parser().parse(['-p', '/custom/path']);
      expect(results['path'], '/custom/path');
    });
  });
}
