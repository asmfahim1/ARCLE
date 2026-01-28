import 'package:arcle/src/commands/create_command.dart';
import 'package:test/test.dart';

void main() {
  test('CreateCommand parser defaults to interactive', () {
    final results = CreateCommand.parser().parse([]);
    expect(results['interactive'], isTrue);
  });
}
