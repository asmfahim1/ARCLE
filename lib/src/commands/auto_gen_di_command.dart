import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/project_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class AutoGenDiCommand {
  AutoGenDiCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption(
        'state',
        abbr: 's',
        allowed: const ['riverpod'],
        help: 'State management option (riverpod)',
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Directory of an existing Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addFlag('force',
          abbr: 'f',
          help: 'Overwrite existing DI files if they exist',
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

    final targetDir = Directory(cmd['path'] as String);
    final config = ArcleConfig.readFrom(targetDir);

    StateManagement? state = StatePicker(console).resolve(
      cmd['state'] as String?,
      interactive: cmd['interactive'] as bool,
    );
    state ??= config?.state;

    if (state == null) {
      ui.error('No state management selected.');
      ui.info('Run with --state riverpod to be explicit.');
      return ExitCode.usage.code;
    }

    if (state != StateManagement.riverpod) {
      ui.error('Only Riverpod is supported in this release.');
      ui.info(
        'Recreate the project with Riverpod or update ${ArcleConfig.filename}.',
      );
      return ExitCode.usage.code;
    }

    final generator = ProjectGenerator(
      ui: ui,
      state: state,
      stateVersion: null,
      force: cmd['force'] as bool,
    );

    ui.section('🔄 Auto-Generating Dependency Injection');
    ui.step('PATH    ', targetDir.path);
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    await generator.scaffoldDi(targetDir);
    generator.updateDependencies(targetDir);
    await generator.pubGet(targetDir);
    if (state == StateManagement.bloc) {
      await generator.buildRunner(targetDir);
    } else {
      ui.info('Build runner skipped (not required for ${state.label}).');
    }
    ui.success('✨ DI regenerated and fully updated!');
    ui.info('All injectable services are now wired up and ready.');
    return ExitCode.success.code;
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

  String _usage() {
    return [
      'Usage:',
      '  arcle auto-gen-di [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
