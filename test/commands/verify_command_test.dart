import 'package:arcle/src/commands/verify_command.dart';
import 'package:test/test.dart';

void main() {
  group('VerifyCommand', () {
    test('parser supports skip flags', () {
      final results = VerifyCommand.parser().parse([
        '--skip-analyze',
        '--skip-test',
        '--skip-codegen',
        '--include-boilerplate-tests',
      ]);
      expect(results['skip-analyze'], isTrue);
      expect(results['skip-test'], isTrue);
      expect(results['skip-codegen'], isTrue);
      expect(results['include-boilerplate-tests'], isTrue);
    });

    test('parser supports state option', () {
      final results = VerifyCommand.parser().parse(['--state', 'riverpod']);
      expect(results['state'], 'riverpod');
    });

    test('parser defaults interactive to true', () {
      final results = VerifyCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });
  });
}
