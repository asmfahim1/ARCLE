import 'package:arcle/src/commands/doctor_command.dart';
import 'package:test/test.dart';

void main() {
  group('DoctorCommand', () {
    test('parser supports fix flag', () {
      final results = DoctorCommand.parser().parse(['--fix']);
      expect(results['fix'], isTrue);
    });

    test('parser supports force flag', () {
      final results = DoctorCommand.parser().parse(['--force']);
      expect(results['force'], isTrue);
    });

    test('parser supports state option', () {
      final results = DoctorCommand.parser().parse(['--state', 'bloc']);
      expect(results['state'], 'bloc');
    });

    test('parser defaults interactive to true', () {
      final results = DoctorCommand.parser().parse([]);
      expect(results['interactive'], isTrue);
    });
  });
}
