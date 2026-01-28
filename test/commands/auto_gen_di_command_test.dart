import 'package:arcle/src/commands/auto_gen_di_command.dart';
import 'package:test/test.dart';

void main() {
  test('AutoGenDiCommand parser defaults to interactive', () {
    final results = AutoGenDiCommand.parser().parse([]);
    expect(results['interactive'], isTrue);
  });
}
