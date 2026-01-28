import 'dart:io';
import 'package:arcle/src/state_management.dart';
import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/project_generator.dart';
import '../ui/cli_ui.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class CreateCommand {
  CreateCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption(
        'state',
        abbr: 's',
        allowed: const ['1', '2', '3', 'bloc', 'getx', 'riverpod'],
        help: 'State management option number (1/2/3) or name',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Directory to create the project in',
        defaultsTo: Directory.current.path,
      )
      ..addOption('org',
          help: 'Organization identifier passed to flutter create')
      ..addOption('state-version',
          help:
              'Version constraint for the selected state package (default: any)')
      ..addFlag('no-flutter-create',
          help: 'Skip flutter create and only scaffold architecture',
          negatable: false)
      ..addFlag('force',
          abbr: 'f',
          help: 'Overwrite existing files if they exist',
          negatable: false)
      ..addFlag('interactive',
          abbr: 'i', help: 'Prompt for any missing values', defaultsTo: true);
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    if (cmd.rest.isEmpty) {
      ui.error('Missing project name.');
      ui.info('Usage: arcle create <project_name>');
      ui.info('Example: arcle create my_awesome_app');
      console.line('');
      return ExitCode.usage.code;
    }

    final state = StatePicker(console).resolve(
      cmd['state'] as String?,
      interactive: cmd['interactive'] as bool,
    );
    if (state == null) {
      ui.error('No state management selected.');
      ui.info('Run interactively or use --state 1|2|3 (bloc/getx/riverpod)');
      return ExitCode.usage.code;
    }

    final projectName = cmd.rest.first;
    ui.section('📦 Creating New Project');
    ui.step('PROJECT ', projectName);
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    final basePath = Directory(cmd['path'] as String);
    final targetDir =
        Directory('${basePath.path}${Platform.pathSeparator}$projectName');

    final generator = ProjectGenerator(
      ui: ui,
      state: state,
      stateVersion: (cmd['state-version'] as String?)?.trim(),
      force: cmd['force'] as bool,
      overwriteMain: true,
      overwriteWidgetTest: true,
    );

    if (cmd['no-flutter-create'] == true) {
      ui.warn('Skipping flutter create (scaffolding only).');
      await generator.scaffold(targetDir);
      await generator.pubGet(targetDir);
      if (state == StateManagement.bloc) {
        await generator.buildRunner(targetDir);
      }
      return ExitCode.success.code;
    }

    final org = (cmd['org'] as String?)?.trim();
    final code = await generator.flutterCreate(projectName, basePath, org: org);
    if (code != ExitCode.success.code) {
      return code;
    }

    await generator.scaffold(targetDir);
    await generator.pubGet(targetDir);
    if (state == StateManagement.bloc) {
      await generator.buildRunner(targetDir);
    } else {
      ui.info('Build runner skipped (not required for ${state.label}).');
    }
    ui.success('🎉 Project "$projectName" created successfully!');
    ui.nextSteps([
      'cd $projectName',
      'flutter run                    ← Launch your app',
      'arcle feature login            ← Add your first feature',
      'code .                         ← Open in VS Code',
    ], projectPath: targetDir.path);
    return ExitCode.success.code;
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle create <project_name> [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }

  String _stateIcon(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '🧱';
      case StateManagement.getx:
        return '⚡';
      case StateManagement.riverpod:
        return '🌊';
    }
  }
}
