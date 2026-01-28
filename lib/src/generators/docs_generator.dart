import 'dart:io';

import '../state_management.dart';
import '../templates/docs_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/file_writer.dart';

class DocsGenerator {
  DocsGenerator({
    required this.ui,
    required this.state,
    required this.force,
  });

  final CliUi ui;
  final StateManagement state;
  final bool force;

  void generate(Directory base) {
    final writer = FileWriter(
      force: force,
      onWrite: (path) => ui.itemCreated(path),
      onSkip: (_) {},
    );

    final pubspec = File(_join(base.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      ui.warn('pubspec.yaml not found; writing a basic markdown doc.');
      writer.write(
        base,
        'documentation/PROJECT_DOC.md',
        DocsTemplates.projectDocMarkdown(
          projectName: 'project',
          version: '0.0.0',
          stateLabel: state.label,
        ),
      );
      ui.success('📚 Documentation generated successfully!');
      return;
    }

    final content = pubspec.readAsStringSync();
    final name = _extractYamlValue(content, 'name') ?? 'project';
    final version = _extractYamlValue(content, 'version') ?? '0.0.0';
    final safeName = _sanitizeFilePart(name);
    final safeVersion = _sanitizeFilePart(version.split('+').first);
    final filename = 'documentation/${safeName}_v$safeVersion.tex';

    writer.write(
      base,
      filename,
      DocsTemplates.projectDocLatex(
        projectName: name,
        version: version,
        stateLabel: state.label,
      ),
    );
    ui.success('📚 Documentation generated: $filename');
    ui.info('Open the .tex file in a LaTeX editor or convert to PDF.');
  }

  String? _extractYamlValue(String content, String key) {
    final regex = RegExp('^$key\\s*:\\s*(.+)\$', multiLine: true);
    final match = regex.firstMatch(content);
    if (match == null) return null;
    var value = match.group(1)!.trim();
    final commentIndex = value.indexOf('#');
    if (commentIndex >= 0) {
      value = value.substring(0, commentIndex).trim();
    }
    if ((value.startsWith("'") && value.endsWith("'")) ||
        (value.startsWith('"') && value.endsWith('"'))) {
      value = value.substring(1, value.length - 1);
    }
    return value.trim();
  }

  String _sanitizeFilePart(String value) {
    final replaced = value.replaceAll(RegExp(r'\s+'), '_');
    return replaced.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
  }

  String _join(String base, String relative) {
    final normalized = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$normalized';
  }
}
