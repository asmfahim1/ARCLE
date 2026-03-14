import 'package:arcle/src/commands/gen_doc_command.dart';
import 'package:test/test.dart';

void main() {
  group('GenDocCommand', () {
    test('parser defaults to interactive', () {
      final results = GenDocCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });

    test('parser supports path option with default', () {
      final results = GenDocCommand.parser().parse([]);
      expect(results['path'], isNotNull);
      expect(results['path'], isNotEmpty);
    });

    test('parser supports custom path', () {
      final results = GenDocCommand.parser().parse(['--path', '/custom/path']);
      expect(results['path'], '/custom/path');
    });

    test('parser supports format option', () {
      final results = GenDocCommand.parser().parse(['--format', 'pdf']);
      expect(results['format'], 'pdf');
    });

    test('parser supports all format options', () {
      expect(
          GenDocCommand.parser().parse(['--format', 'word'])['format'], 'word');
      expect(
          GenDocCommand.parser().parse(['--format', 'pdf'])['format'], 'pdf');
    });

    test('parser supports help flag', () {
      final results = GenDocCommand.parser().parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('parser supports short options', () {
      final results =
          GenDocCommand.parser().parse(['-p', '/custom/path', '-F', 'word']);
      expect(results['path'], '/custom/path');
      expect(results['format'], 'word');
    });

    test('parser supports force flag', () {
      final results = GenDocCommand.parser().parse(['--force']);
      expect(results['force'], isTrue);
    });

    test('parser supports state option', () {
      final results = GenDocCommand.parser().parse(['--state', 'bloc']);
      expect(results['state'], 'bloc');
    });
  });
}
