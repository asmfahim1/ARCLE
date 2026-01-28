import 'package:arcle/src/commands/build_command.dart';
import 'package:test/test.dart';

void main() {
  test('BuildCommand parser defaults to release mode', () {
    final results = BuildCommand.parser().parse([]);
    expect(results['mode'], 'release');
  });
}
