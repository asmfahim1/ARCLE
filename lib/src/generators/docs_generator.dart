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
    required this.format,
  });

  final CliUi ui;
  final StateManagement state;
  final bool force;
  final String format; // 'word' or 'pdf'

  void generate(Directory base) {
    final writer = FileWriter(
      force: force,
      onWrite: (path) => ui.itemCreated(path),
      onSkip: (_) {},
    );

    final pubspec = File(_join(base.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      ui.warn('pubspec.yaml not found; writing a basic markdown doc.');
      const relativePath = 'documentation/PROJECT_DOC.md';
      writer.write(
        base,
        relativePath,
        DocsTemplates.projectDocMarkdown(
          projectName: 'project',
          version: '0.0.0',
          stateLabel: state.label,
        ),
      );
      ui.info('Document path: ${_join(base.path, relativePath)}');
      ui.success('Documentation generated successfully!');
      return;
    }

    final content = pubspec.readAsStringSync();
    final name = _extractYamlValue(content, 'name') ?? 'project';
    final version = _extractYamlValue(content, 'version') ?? '0.0.0';
    final safeName = _sanitizeFilePart(name);
    final safeVersion = _sanitizeFilePart(version.split('+').first);

    if (format == 'word') {
      _generateWordDoc(base, writer, name, version, safeName, safeVersion);
    } else {
      _generatePdfDoc(base, writer, name, version, safeName, safeVersion);
    }
  }

  void _generateWordDoc(
    Directory base,
    FileWriter writer,
    String name,
    String version,
    String safeName,
    String safeVersion,
  ) {
    final filename = 'documentation/${safeName}_v$safeVersion.docx';
    final docxContent = DocsTemplates.projectDocWord(
      projectName: name,
      version: version,
      stateLabel: state.label,
    );

    // Write the Word XML content
    writer.write(base, filename, docxContent);
    ui.success('Word document generated: $filename');
    ui.info('Document path: ${_join(base.path, filename)}');
    ui.info('Open with Microsoft Word or compatible application.');
  }

  void _generatePdfDoc(
    Directory base,
    FileWriter writer,
    String name,
    String version,
    String safeName,
    String safeVersion,
  ) {
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
    ui.success('LaTeX document generated: $filename');
    ui.info('Document path: ${_join(base.path, filename)}');
    ui.info('Convert to PDF using: pdflatex $filename');
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
