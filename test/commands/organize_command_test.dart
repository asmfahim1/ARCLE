import 'package:arcle/src/commands/organize_command.dart';
import 'package:test/test.dart';

void main() {
  group('OrganizeCommand', () {
    test('parser has imports subcommand', () {
      final parser = OrganizeCommand.parser();
      expect(parser.commands.containsKey('imports'), isTrue);
    });

    test('imports supports path and check options', () {
      final result = OrganizeCommand.parser().parse([
        'imports',
        '--path',
        'example',
        '--check',
      ]);
      expect(result.command!['path'], 'example');
      expect(result.command!['check'], isTrue);
    });
  });
}
