import 'package:arcle/src/commands/feature_command.dart';
import 'package:test/test.dart';

void main() {
  group('FeatureCommand', () {
    test('parser supports create subcommand', () {
      final results = FeatureCommand.parser().parse(['create', 'demo']);
      expect(results.command?.name, 'create');
    });

    test('parser has create subcommand in commands', () {
      final parser = FeatureCommand.parser();
      expect(parser.commands.containsKey('create'), isTrue);
    });

    test('parser supports help flag', () {
      final results = FeatureCommand.parser().parse(['--help']);
      expect(results['help'], isTrue);
    });

    test('create subcommand supports state option', () {
      final results =
          FeatureCommand.parser().parse(['create', '--state', 'bloc', 'auth']);
      expect(results.command!['state'], 'bloc');
    });

    test('create subcommand supports all state options', () {
      expect(
        FeatureCommand.parser()
            .parse(['create', '--state', 'bloc', 'auth']).command!['state'],
        'bloc',
      );
      expect(
        FeatureCommand.parser()
            .parse(['create', '--state', 'getx', 'auth']).command!['state'],
        'getx',
      );
      expect(
        FeatureCommand.parser()
            .parse(['create', '--state', 'riverpod', 'auth']).command!['state'],
        'riverpod',
      );
    });

    test('create subcommand supports force flag', () {
      final results =
          FeatureCommand.parser().parse(['create', '--force', 'auth']);
      expect(results.command!['force'], isTrue);
    });

    test('create subcommand defaults force to false', () {
      final results = FeatureCommand.parser().parse(['create', 'auth']);
      expect(results.command!['force'], isFalse);
    });
  });
}
