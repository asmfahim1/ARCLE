import 'dart:io';

import '../state_management.dart';
import '../ui/cli_ui.dart';
import 'console.dart';

/// Utility class for picking state management option interactively or from arguments.
class StatePicker {
  StatePicker(this.console);

  final Console console;

  /// Resolves the state management option from raw input or interactively.
  ///
  /// If [raw] is provided and valid, returns the corresponding [StateManagement].
  /// If [interactive] is true and no valid input is provided, prompts the user.
  /// Returns null if no valid selection is made.
  StateManagement? resolve(String? raw, {required bool interactive}) {
    // If a valid state was passed via --state flag, use it
    if (raw != null && raw.trim().isNotEmpty) {
      final state = StateManagement.fromInput(raw);
      if (state != null) return state;
    }

    // If not interactive, return null (will show error)
    if (!interactive) {
      return null;
    }

    // Interactive mode: prompt user to select state management
    return _promptSelection();
  }

  StateManagement? _promptSelection() {
    final ui = CliUi(console);

    console.line('');
    ui.info('Select a state management solution:');
    console.line('');

    for (final state in StateManagement.values) {
      final icon = _getIcon(state);
      final description = _getDescription(state);
      console.line('  ${state.option}. $icon ${state.label} - $description');
    }

    console.line('');
    stdout.write('  Enter your choice (1-${StateManagement.values.length}): ');

    final input = stdin.readLineSync()?.trim();
    if (input == null || input.isEmpty) {
      return null;
    }

    // Try parsing as number first
    final number = int.tryParse(input);
    if (number != null) {
      return StateManagement.fromOption(number);
    }

    // Try parsing as name
    return StateManagement.fromInput(input);
  }

  String _getIcon(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '🧱';
      case StateManagement.getx:
        return '⚡';
      case StateManagement.riverpod:
        return '🌊';
    }
  }

  String _getDescription(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return 'Event-driven, scalable, with GetIt DI';
      case StateManagement.getx:
        return 'Simple, reactive, all-in-one solution';
      case StateManagement.riverpod:
        return 'Type-safe, testable, compile-time safe';
    }
  }
}
