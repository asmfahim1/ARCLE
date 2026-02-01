enum StateManagement {
  bloc('bloc', 'BLoC'),
  getx('getx', 'GetX'),
  riverpod('riverpod', 'Riverpod');

  const StateManagement(this.id, this.label);

  final String id;
  final String label;
  int get option => index + 1;

  static StateManagement? fromId(String id) {
    final normalized = id.trim().toLowerCase();
    for (final state in StateManagement.values) {
      if (state.id == normalized) return state;
    }
    return null;
  }

  static StateManagement? fromInput(String input) {
    return fromId(input);
  }

  static StateManagement? fromOption(int option) {
    final index = option - 1;
    if (index >= 0 && index < StateManagement.values.length) {
      return StateManagement.values[index];
    }
    return null;
  }
}
