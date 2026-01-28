import 'package:arcle/src/commands/gen_di_command.dart';
import 'package:test/test.dart';

void main() {
  test('GenDiCommand parser defaults to interactive', () {
    final results = GenDiCommand.parser().parse([]);
    expect(results['interactive'], isTrue);
  });
}
