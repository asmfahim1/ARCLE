import 'package:arcle/src/commands/gen_doc_command.dart';
import 'package:test/test.dart';

void main() {
  test('GenDocCommand parser defaults to interactive', () {
    final results = GenDocCommand.parser().parse([]);
    expect(results['interactive'], isTrue);
  });
}
