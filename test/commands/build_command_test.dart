import 'package:arcle/src/commands/build_command.dart';
import 'package:test/test.dart';

void main() {
  group('BuildCommand', () {
    test('parser has apk subcommand', () {
      final parser = BuildCommand.parser();
      expect(parser.commands.containsKey('apk'), isTrue);
    });

    test('apk subcommand has release flag', () {
      final results = BuildCommand.parser().parse(['apk', '--release']);
      expect(results.command!['release'], isTrue);
    });

    test('apk subcommand has debug flag', () {
      final results = BuildCommand.parser().parse(['apk', '--debug']);
      expect(results.command!['debug'], isTrue);
    });

    test('apk subcommand defaults to no mode flags', () {
      final results = BuildCommand.parser().parse(['apk']);
      expect(results.command!['release'], isFalse);
      expect(results.command!['debug'], isFalse);
    });

    test('apk subcommand has interactive flag defaulting to true', () {
      final results = BuildCommand.parser().parse(['apk']);
      expect(results.command!['interactive'], isTrue);
    });

    test('apk subcommand has path option with default value', () {
      final results = BuildCommand.parser().parse(['apk']);
      expect(results.command!['path'], isNotNull);
    });

    test('parser has help flag', () {
      final parser = BuildCommand.parser();
      expect(parser.options.containsKey('help'), isTrue);
    });
  });
}
