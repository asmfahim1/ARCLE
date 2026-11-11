import 'package:arcle/src/commands/agent_command.dart';
import 'package:arcle/src/commands/configure_ai_command.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigureAiCommand', () {
    test('parser supports help flag', () {
      final parser = ConfigureAiCommand.parser();
      expect(parser.commands.containsKey('configure-ai'), isFalse);
      final results = parser.parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('parser supports force and path options', () {
      final parser = ConfigureAiCommand.parser();
      final results = parser.parse(['--force', '--path', './test_project']);
      expect(results['force'], isTrue);
      expect(results['path'], './test_project');
    });
  });

  group('AgentCommand', () {
    test('parser supports all subcommands', () {
      final parser = AgentCommand.parser();
      expect(parser.commands.containsKey('add'), isTrue);
      expect(parser.commands.containsKey('remove'), isTrue);
      expect(parser.commands.containsKey('switch'), isTrue);
      expect(parser.commands.containsKey('list'), isTrue);
      expect(parser.commands.containsKey('validate'), isTrue);
    });

    test('add subcommand parses supported agents', () {
      final parser = AgentCommand.parser();
      final results = parser.parse(['add', 'codex']);
      expect(results.command?.name, 'add');
      expect(results.command?.rest.first, 'codex');
    });
  });
}
