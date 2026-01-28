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
    if (!interactive) return null;

    final ui = CliUi(console);
    ui.showWelcome();
    ui.showStateMenu();
    final input = console.prompt(
      console.color(
        '  ➜ Enter choice (1-${StateManagement.values.length}): ',
        ConsoleColor.green,
      ),
    );
    if (input == null || input.trim().isEmpty) return null;
    return StateManagement.fromInput(input);
  }
}
