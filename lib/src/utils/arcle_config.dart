import 'dart:io';

import '../state_management.dart';

class ArcleConfig {
  ArcleConfig({
    required this.state,
    required this.createdAt,
  });

  final StateManagement state;
  final DateTime createdAt;

  static const filename = 'arcle.yaml';

  String toYaml() {
    return [
      'state: ${state.id}',
      'state_option: ${state.option}',
      'created_at: ${createdAt.toIso8601String()}',
    ].join('\n');
  }

  static ArcleConfig? readFrom(Directory dir) {
    final file = File('${dir.path}${Platform.pathSeparator}$filename');
    if (!file.existsSync()) return null;
    final data = _parseKeyValues(file.readAsStringSync());
    final state = StateManagement.fromInput(data['state'] ?? '');
    final createdAt = DateTime.tryParse(data['created_at'] ?? '');
    if (state == null || createdAt == null) return null;
    return ArcleConfig(state: state, createdAt: createdAt);
  }

  static Map<String, String> _parseKeyValues(String input) {
    final map = <String, String>{};
    for (final line in input.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final split = trimmed.split(':');
      if (split.length < 2) continue;
      final key = split.first.trim();
      final value = trimmed.substring(trimmed.indexOf(':') + 1).trim();
      map[key] = value;
    }
    return map;
  }
}
