import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/project_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/project_health.dart';
import '../utils/state_picker.dart';

class DoctorCommand {
  DoctorCommand(this.console, {ProjectHealthValidator? validator})
      : validator = validator ?? ProjectHealthValidator();

  final Console console;
  final ProjectHealthValidator validator;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption(
        'state',
        abbr: 's',
        allowed: const ['bloc', 'getx', 'riverpod'],
        help: 'State management option (bloc, getx, riverpod)',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Directory of an ARCLE Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addFlag(
        'fix',
        help: 'Apply safe ARCLE-owned repairs when possible',
        negatable: false,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite ARCLE-managed files during --fix',
        negatable: false,
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Prompt for any missing values',
        defaultsTo: true,
      );
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    final config = ArcleConfig.readFrom(targetDir);
    final stateInput = cmd['state'] as String?;
    final interactive = cmd['interactive'] as bool;

    StateManagement? state;
    if (stateInput != null && stateInput.trim().isNotEmpty) {
      state = StatePicker(console).resolve(stateInput, interactive: false);
    } else if (config?.state != null) {
      state = config!.state;
      ui.info(
        'Detected state management from ${ArcleConfig.filename}: ${state.label}.',
      );
    } else {
      state = StatePicker(console).resolve(null, interactive: interactive);
    }

    ui.section('Project Doctor');
    ui.step('PATH    ', targetDir.path);
    if (state != null) {
      ui.step('STATE   ', state.label);
    }

    final report = await validator.validate(
      targetDir: targetDir,
      explicitState: state,
    );

    _printIssues(ui, report);

    if (cmd['fix'] == true) {
      final fixed = await _applyFixes(
        ui: ui,
        targetDir: targetDir,
        state: report.state,
        force: cmd['force'] as bool,
      );
      if (fixed > 0) {
        ui.info('Re-running validation after fixes...');
        final rerun = await validator.validate(
          targetDir: targetDir,
          explicitState: report.state,
        );
        _printIssues(ui, rerun);
        if (!rerun.hasErrors) {
          ui.success('Doctor finished with safe repairs applied.');
          return ExitCode.success.code;
        }
        return ExitCode.software.code;
      }
      ui.info('No automatic repairs were applicable.');
    }

    if (report.issues.isEmpty) {
      ui.success('No issues found.');
      return ExitCode.success.code;
    }

    return report.hasErrors ? ExitCode.software.code : ExitCode.success.code;
  }

  void _printIssues(CliUi ui, ProjectHealthReport report) {
    if (report.issues.isEmpty) {
      ui.success('Project health looks good.');
      return;
    }

    for (final issue in report.issues) {
      switch (issue.severity) {
        case ProjectIssueSeverity.error:
          ui.error(issue.message);
          break;
        case ProjectIssueSeverity.warning:
          ui.warn(issue.message);
          break;
        case ProjectIssueSeverity.info:
          ui.info(issue.message);
          break;
      }
      if (issue.fixDescription != null) {
        ui.info('Fix available: ${issue.fixDescription}');
      }
    }
  }

  Future<int> _applyFixes({
    required CliUi ui,
    required Directory targetDir,
    required StateManagement? state,
    required bool force,
  }) async {
    if (state == null) {
      ui.warn('Skipping repairs because state management is unknown.');
      return 0;
    }

    var actions = 0;
    final generator = ProjectGenerator(
      ui: ui,
      state: state,
      stateVersion: null,
      force: force,
    );

    ui.section('Applying Safe Fixes');
    generator.updateDependencies(targetDir);
    actions += 1;

    _writeConfig(targetDir, state, force, ui);
    actions += 1;

    await generator.scaffoldDi(targetDir);
    actions += 1;

    return actions;
  }

  void _writeConfig(
    Directory targetDir,
    StateManagement state,
    bool force,
    CliUi ui,
  ) {
    final file = File(
      '${targetDir.path}${Platform.pathSeparator}${ArcleConfig.filename}',
    );
    if (file.existsSync() && !force) {
      final existing = ArcleConfig.readFrom(targetDir);
      if (existing != null) {
        return;
      }
    }

    final config = ArcleConfig(
      state: state,
      createdAt: DateTime.now(),
    ).toYaml();
    file.writeAsStringSync(config);
    ui.itemUpdated(ArcleConfig.filename);
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle doctor [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
