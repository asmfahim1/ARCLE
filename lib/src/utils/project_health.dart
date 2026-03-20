import 'dart:io';

import '../state_management.dart';

enum ProjectIssueSeverity { error, warning, info }

class ProjectHealthIssue {
  const ProjectHealthIssue({
    required this.severity,
    required this.code,
    required this.message,
    this.fixDescription,
  });

  final ProjectIssueSeverity severity;
  final String code;
  final String message;
  final String? fixDescription;

  bool get isFixable => fixDescription != null && fixDescription!.isNotEmpty;
}

class ProjectHealthReport {
  const ProjectHealthReport({
    required this.targetDir,
    required this.issues,
    required this.state,
  });

  final Directory targetDir;
  final List<ProjectHealthIssue> issues;
  final StateManagement? state;

  bool get hasErrors =>
      issues.any((issue) => issue.severity == ProjectIssueSeverity.error);

  bool get hasFixableIssues => issues.any((issue) => issue.isFixable);
}

class ProjectHealthValidator {
  Future<ProjectHealthReport> validate({
    required Directory targetDir,
    StateManagement? explicitState,
    bool includeEnvironment = true,
  }) async {
    final issues = <ProjectHealthIssue>[];

    if (!targetDir.existsSync()) {
      issues.add(
        const ProjectHealthIssue(
          severity: ProjectIssueSeverity.error,
          code: 'missing_project_dir',
          message: 'Project directory does not exist.',
        ),
      );
      return ProjectHealthReport(
        targetDir: targetDir,
        issues: issues,
        state: explicitState,
      );
    }

    if (includeEnvironment) {
      issues.addAll(await _validateEnvironment());
    }

    final pubspecFile = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      issues.add(
        const ProjectHealthIssue(
          severity: ProjectIssueSeverity.error,
          code: 'missing_pubspec',
          message: 'pubspec.yaml was not found.',
        ),
      );
      return ProjectHealthReport(
        targetDir: targetDir,
        issues: issues,
        state: explicitState,
      );
    }

    final pubspecContent = pubspecFile.readAsStringSync();
    final configFile = File(_join(targetDir.path, 'arcle.yaml'));
    final configState = _readConfigState(configFile);
    final state = explicitState ?? configState;

    if (!pubspecContent.contains(RegExp(r'^\s*flutter\s*:', multiLine: true))) {
      issues.add(
        const ProjectHealthIssue(
          severity: ProjectIssueSeverity.error,
          code: 'not_flutter_project',
          message: 'pubspec.yaml does not look like a Flutter project.',
        ),
      );
    }

    if (!configFile.existsSync()) {
      issues.add(
        const ProjectHealthIssue(
          severity: ProjectIssueSeverity.warning,
          code: 'missing_arcle_config',
          message: 'arcle.yaml was not found.',
          fixDescription: 'Write arcle.yaml for the detected project state.',
        ),
      );
    } else if (configState == null) {
      issues.add(
        const ProjectHealthIssue(
          severity: ProjectIssueSeverity.warning,
          code: 'invalid_arcle_config',
          message: 'arcle.yaml exists but could not be parsed.',
          fixDescription: 'Rewrite arcle.yaml with a valid state and timestamp.',
        ),
      );
    }

    if (explicitState != null &&
        configState != null &&
        explicitState != configState) {
      issues.add(
        ProjectHealthIssue(
          severity: ProjectIssueSeverity.warning,
          code: 'state_mismatch',
          message:
              'Configured state (${configState.label}) does not match the requested state (${explicitState.label}).',
        ),
      );
    }

    if (state == null) {
      issues.add(
        const ProjectHealthIssue(
          severity: ProjectIssueSeverity.error,
          code: 'missing_state',
          message:
              'State management could not be determined. Pass --state bloc|getx|riverpod.',
        ),
      );
      return ProjectHealthReport(
        targetDir: targetDir,
        issues: issues,
        state: null,
      );
    }

    issues.addAll(_validateStructure(targetDir));
    issues.addAll(_validateDependencies(pubspecContent, state));
    issues.addAll(_validateStateFiles(targetDir, state));

    return ProjectHealthReport(
      targetDir: targetDir,
      issues: issues,
      state: state,
    );
  }

  Future<List<ProjectHealthIssue>> _validateEnvironment() async {
    final issues = <ProjectHealthIssue>[];

    Future<void> checkTool(String tool) async {
      try {
        final result = await Process.run(
          tool,
          ['--version'],
          runInShell: true,
        );
        if (result.exitCode != 0) {
          issues.add(
            ProjectHealthIssue(
              severity: ProjectIssueSeverity.error,
              code: 'missing_$tool',
              message: '$tool is not available on PATH.',
            ),
          );
        }
      } catch (_) {
        issues.add(
          ProjectHealthIssue(
            severity: ProjectIssueSeverity.error,
            code: 'missing_$tool',
            message: '$tool is not available on PATH.',
          ),
        );
      }
    }

    await checkTool('dart');
    await checkTool('flutter');
    return issues;
  }

  List<ProjectHealthIssue> _validateStructure(Directory targetDir) {
    final issues = <ProjectHealthIssue>[];
    final requiredPaths = [
      'lib',
      'lib/core',
      'lib/features',
      'lib/core/route_handler/app_routes.dart',
      'lib/core/route_handler/app_router.dart',
    ];

    for (final relativePath in requiredPaths) {
      final entityType = FileSystemEntity.typeSync(_join(
        targetDir.path,
        relativePath,
      ));
      if (entityType == FileSystemEntityType.notFound) {
        issues.add(
          ProjectHealthIssue(
            severity: ProjectIssueSeverity.warning,
            code: 'missing_${_issueSafe(relativePath)}',
            message: 'Missing expected ARCLE path: $relativePath',
          ),
        );
      }
    }

    return issues;
  }

  List<ProjectHealthIssue> _validateDependencies(
    String pubspecContent,
    StateManagement state,
  ) {
    final issues = <ProjectHealthIssue>[];
    final requiredDependencies = <String>[
      'dio',
      'shared_preferences',
      'permission_handler',
      'dartz',
      'flutter_local_notifications',
      'timezone',
      'google_fonts',
      'flutter_svg',
      'flutter_localizations',
    ];

    switch (state) {
      case StateManagement.bloc:
        requiredDependencies.addAll(
          ['get_it', 'injectable', 'equatable', 'flutter_bloc'],
        );
        break;
      case StateManagement.getx:
        requiredDependencies.add('get');
        break;
      case StateManagement.riverpod:
        requiredDependencies.addAll(['flutter_riverpod', 'equatable']);
        break;
    }

    for (final dependency in requiredDependencies) {
      final exists = RegExp(
        '^\\s*$dependency\\s*:',
        multiLine: true,
      ).hasMatch(pubspecContent);
      if (!exists) {
        issues.add(
          ProjectHealthIssue(
            severity: ProjectIssueSeverity.warning,
            code: 'missing_dep_$dependency',
            message: 'Missing required dependency: $dependency',
            fixDescription: 'Update pubspec.yaml with ARCLE dependencies.',
          ),
        );
      }
    }

    if (state == StateManagement.bloc) {
      for (final dependency in ['build_runner', 'injectable_generator']) {
        final exists = RegExp(
          '^\\s*$dependency\\s*:',
          multiLine: true,
        ).hasMatch(pubspecContent);
        if (!exists) {
          issues.add(
            ProjectHealthIssue(
              severity: ProjectIssueSeverity.warning,
              code: 'missing_dev_dep_$dependency',
              message: 'Missing required dev dependency: $dependency',
              fixDescription:
                  'Update pubspec.yaml dev_dependencies for BLoC codegen.',
            ),
          );
        }
      }
    }

    return issues;
  }

  List<ProjectHealthIssue> _validateStateFiles(
    Directory targetDir,
    StateManagement state,
  ) {
    final issues = <ProjectHealthIssue>[];
    final requiredFiles = <String>[
      'lib/core/di/app_di.dart',
    ];

    switch (state) {
      case StateManagement.bloc:
        requiredFiles.addAll([
          'lib/core/di/injection.dart',
          'lib/core/di/injectable_module.dart',
          'lib/core/di/injection.config.dart',
          'lib/core/di/bloc_providers.dart',
        ]);
        break;
      case StateManagement.getx:
        break;
      case StateManagement.riverpod:
        requiredFiles.add('lib/core/di/providers.dart');
        break;
    }

    for (final relativePath in requiredFiles) {
      final file = File(_join(targetDir.path, relativePath));
      if (!file.existsSync()) {
        issues.add(
          ProjectHealthIssue(
            severity: ProjectIssueSeverity.warning,
            code: 'missing_${_issueSafe(relativePath)}',
            message: 'Missing expected ARCLE file: $relativePath',
            fixDescription: relativePath.startsWith('lib/core/di/')
                ? 'Regenerate ARCLE DI files.'
                : null,
          ),
        );
      }
    }

    return issues;
  }

  StateManagement? _readConfigState(File configFile) {
    if (!configFile.existsSync()) return null;
    final content = configFile.readAsStringSync();
    final match = RegExp(r'^\s*state\s*:\s*(.+)\s*$', multiLine: true)
        .firstMatch(content);
    if (match == null) return null;
    return StateManagement.fromInput(match.group(1)!.trim());
  }

  String _issueSafe(String value) {
    return value.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
  }

  String _join(String base, String relative) {
    final normalized = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$normalized';
  }
}
