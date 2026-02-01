import '../state_management.dart';
import '../ui/cli_ui.dart';
import 'console.dart';

class StatePicker {
  StatePicker(this.console);

  final Console console;

  StateManagement? resolve(String? raw, {required bool interactive}) {
    if (raw != null && raw.trim().isNotEmpty) {
      return StateManagement.fromInput(raw);
    }
    if (interactive) {
      final ui = CliUi(console);
      ui.info('Riverpod is the only supported state management. Using Riverpod.');
    }
    return StateManagement.riverpod;
  }
}
