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
    final description = _extractYamlValue(content, 'description') ?? '';
    final safeName = _sanitizeFilePart(name);
    final safeVersion = _sanitizeFilePart(version.split('+').first);

    // Gather project information
    ui.step('SCAN    ', 'Analyzing project structure...');
    final features = _scanFeatures(base);
    final dependencies = _scanDependencies(content);
    final endpoints = _scanEndpoints(base);
    final generatedDate = DateTime.now().toString().split(' ')[0];

    ui.info(
        'Found ${features.length} features, ${dependencies.length} dependencies');

    if (format == 'word') {
      _generateWordDoc(base, writer, name, version, safeName, safeVersion,
          description: description,
          features: features,
          dependencies: dependencies,
          endpoints: endpoints,
          generatedDate: generatedDate);
    } else {
      _generatePdfDoc(base, writer, name, version, safeName, safeVersion,
          description: description,
          features: features,
          dependencies: dependencies,
          endpoints: endpoints,
          generatedDate: generatedDate);
    }
  }

  List<String> _scanFeatures(Directory base) {
    final features = <String>[];
    final featuresDir = Directory(_join(base.path, 'lib/features'));

    if (featuresDir.existsSync()) {
      for (final entity in featuresDir.listSync()) {
        if (entity is Directory) {
          final featureName = entity.path.split(Platform.pathSeparator).last;
          // Check for domain/presentation/data subdirs to confirm it's a feature
          final hasStructure =
              Directory(_join(entity.path, 'domain')).existsSync() ||
                  Directory(_join(entity.path, 'presentation')).existsSync() ||
                  Directory(_join(entity.path, 'data')).existsSync();
          if (hasStructure) {
            features.add(_formatFeatureName(featureName));
          }
        }
      }
    }

    return features;
  }

  String _formatFeatureName(String name) {
    // Convert snake_case to Title Case
    return name
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  List<String> _scanDependencies(String pubspecContent) {
    final deps = <String>[];
    final lines = pubspecContent.split('\n');
    var inDependencies = false;
    var inDevDependencies = false;

    for (final line in lines) {
      final trimmed = line.trim();

      if (trimmed == 'dependencies:') {
        inDependencies = true;
        inDevDependencies = false;
        continue;
      }
      if (trimmed == 'dev_dependencies:') {
        inDevDependencies = true;
        inDependencies = false;
        continue;
      }
      if (trimmed.isNotEmpty &&
          !trimmed.startsWith('#') &&
          !line.startsWith(' ') &&
          !line.startsWith('\t')) {
        inDependencies = false;
        inDevDependencies = false;
      }

      if (inDependencies && !inDevDependencies) {
        if (trimmed.contains(':') && !trimmed.startsWith('#')) {
          final depName = trimmed.split(':')[0].trim();
          if (depName.isNotEmpty &&
              !depName.startsWith('flutter') &&
              depName != 'sdk') {
            deps.add(depName);
          }
        }
      }
    }

    return deps;
  }

  List<String> _scanEndpoints(Directory base) {
    final endpoints = <String>[];

    // Look for remote data sources
    final sourcesPatterns = [
      'lib/core/api_client',
      'lib/features/*/data/sources',
    ];

    for (final pattern in sourcesPatterns) {
      if (pattern.contains('*')) {
        // Handle glob pattern for features
        final featuresDir = Directory(_join(base.path, 'lib/features'));
        if (featuresDir.existsSync()) {
          for (final feature in featuresDir.listSync()) {
            if (feature is Directory) {
              final sourcesDir = Directory(_join(feature.path, 'data/sources'));
              if (sourcesDir.existsSync()) {
                endpoints.addAll(_extractEndpointsFromDir(sourcesDir));
              }
            }
          }
        }
      } else {
        final dir = Directory(_join(base.path, pattern));
        if (dir.existsSync()) {
          endpoints.addAll(_extractEndpointsFromDir(dir));
        }
      }
    }

    return endpoints.toSet().toList(); // Remove duplicates
  }

  List<String> _extractEndpointsFromDir(Directory dir) {
    final endpoints = <String>[];
    final endpointPattern = RegExp(r'''['"]([/][a-zA-Z0-9_\-/{}]+)['"]''');

    for (final file in dir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        try {
          final content = file.readAsStringSync();
          final matches = endpointPattern.allMatches(content);
          for (final match in matches) {
            final endpoint = match.group(1);
            if (endpoint != null && endpoint.length > 1) {
              endpoints.add(endpoint);
            }
          }
        } catch (_) {
          // Skip unreadable files
        }
      }
    }

    return endpoints;
  }

  void _generateWordDoc(
    Directory base,
    FileWriter writer,
    String name,
    String version,
    String safeName,
    String safeVersion, {
    String description = '',
    List<String> features = const [],
    List<String> dependencies = const [],
    List<String> endpoints = const [],
    String generatedDate = '',
  }) {
    final filename = 'documentation/${safeName}_v$safeVersion.docx';
    final docxContent = DocsTemplates.projectDocWord(
      projectName: name,
      version: version,
      stateLabel: state.label,
      description: description,
      features: features,
      dependencies: dependencies,
      endpoints: endpoints,
      generatedDate: generatedDate,
    );

    // Write the Word XML content
    writer.write(base, filename, docxContent);
    ui.success('Word document generated: $filename');
    ui.info('Document path: ${_join(base.path, filename)}');
    ui.info('Open with Microsoft Word or compatible application.');
    _printDocSummary(features, dependencies, endpoints);
  }

  void _generatePdfDoc(
    Directory base,
    FileWriter writer,
    String name,
    String version,
    String safeName,
    String safeVersion, {
    String description = '',
    List<String> features = const [],
    List<String> dependencies = const [],
    List<String> endpoints = const [],
    String generatedDate = '',
  }) {
    final filename = 'documentation/${safeName}_v$safeVersion.tex';
    writer.write(
      base,
      filename,
      DocsTemplates.projectDocLatex(
        projectName: name,
        version: version,
        stateLabel: state.label,
        description: description,
        features: features,
        dependencies: dependencies,
        endpoints: endpoints,
        generatedDate: generatedDate,
      ),
    );
    ui.success('LaTeX document generated: $filename');
    ui.info('Document path: ${_join(base.path, filename)}');
    ui.info('Convert to PDF using: pdflatex $filename');
    _printDocSummary(features, dependencies, endpoints);
  }

  void _printDocSummary(
      List<String> features, List<String> deps, List<String> endpoints) {
    ui.section('📊 Documentation Summary');
    ui.info('• Features documented: ${features.length}');
    ui.info('• Dependencies listed: ${deps.length}');
    ui.info('• API endpoints found: ${endpoints.length}');
    ui.info('');
    ui.info('📋 Sections included:');
    ui.info('   • Executive Summary');
    ui.info('   • Technical Architecture');
    ui.info('   • UAT Acceptance Criteria');
    ui.info('   • Testing Strategy');
    ui.info('   • Security Considerations');
    ui.info('   • Troubleshooting Guide');
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
