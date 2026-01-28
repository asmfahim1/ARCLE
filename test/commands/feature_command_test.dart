import 'package:arcle/src/commands/feature_command.dart';
import 'package:test/test.dart';

void main() {
  test('FeatureCommand parser supports create subcommand', () {
    final results = FeatureCommand.parser().parse(['create', 'demo']);
    expect(results.command?.name, 'create');
  });
}
