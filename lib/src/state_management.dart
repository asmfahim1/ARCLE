enum StateManagement {
  bloc('bloc', 'BLoC'),
  getx('getx', 'GetX'),
  riverpod('riverpod', 'Riverpod');

  const StateManagement(this.id, this.label);

  final String id;
  final String label;
  int get option => index + 1;

  static StateManagement? fromId(String id) {
    for (final value in values) {
      if (value.id == id) return value;
    }
    return null;
  }

  static StateManagement? fromInput(String input) {
    final trimmed = input.trim().toLowerCase();
    final asNumber = int.tryParse(trimmed);
    if (asNumber != null && asNumber >= 1 && asNumber <= values.length) {
      return values[asNumber - 1];
    }
    return fromId(trimmed);
  }
}
