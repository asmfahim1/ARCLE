import '../state_management.dart';
import 'console.dart';
import 'interactive_menu.dart';

/// Utility class for picking state management option interactively or from arguments.
class StatePicker {
  StatePicker(this.console);

  final Console console;

  /// Resolves the state management option from raw input or interactively.
  StateManagement? resolve(String? raw, {required bool interactive}) {
    if (raw != null && raw.trim().isNotEmpty) {
      final state = StateManagement.fromInput(raw);
      if (state != null) return state;
    }
    if (!interactive) return null;
    return _promptSelection();
  }

  StateManagement? _promptSelection() {
    console.line('');

    final index = InteractiveMenu.select(
      [
        '🧱  Clean Architecture + BLoC',
        '🌊  Clean Architecture + Riverpod',
        '⚡  Clean Architecture + GetX',
      ],
      prompt: 'Select a state management solution:',
    );

    if (index == null) return null;

    switch (index) {
      case 0:
        return StateManagement.bloc;
      case 1:
        return StateManagement.riverpod;
      case 2:
        return StateManagement.getx;
      default:
        return null;
    }
  }
}
