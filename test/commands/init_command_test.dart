import 'package:arcle/src/commands/init_command.dart';
import 'package:test/test.dart';

void main() {
  test('InitCommand parser defaults to interactive', () {
    final results = InitCommand.parser().parse([]);
    expect(results['interactive'], isTrue);
  });
}
