import 'dart:io';

class ReportWriter {
  static void write(Directory project, String command, List<String> lines) {
    final docs = Directory(_join(project.path, 'docs'));
    docs.createSync(recursive: true);
    final report = File(_join(docs.path, 'report.md'));
    final buffer =
        StringBuffer()
          ..writeln('# ARCLE ${command.capitalize()} Report')
          ..writeln()
          ..writeln('Generated: ${DateTime.now().toIso8601String()}')
          ..writeln()
          ..writeln('## Results')
          ..writeln();
    for (final line in lines) {
      buffer.writeln('- $line');
    }
    report.writeAsStringSync(buffer.toString());
  }

  static String _join(String base, String relative) {
    return '$base${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}';
  }
}

extension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
