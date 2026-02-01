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
    return normalized == StateManagement.riverpod.id
        ? StateManagement.riverpod
        : null;
  }

  static StateManagement? fromInput(String input) {
    return fromId(input);
  }
}
