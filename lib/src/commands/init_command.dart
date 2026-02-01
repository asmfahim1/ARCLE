import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/project_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class InitCommand {
  InitCommand(this.console);

  final Console console;

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
        help: 'Directory of an existing Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addOption('state-version',
          help:
              'Version constraint for the selected state package (default: any)')
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

    final state = StatePicker(console).resolve(
      cmd['state'] as String?,
      interactive: cmd['interactive'] as bool,
    );
    if (state == null) {
      ui.error('No state management selected.');
      ui.info('Run with --state bloc|getx|riverpod to be explicit.');
      return ExitCode.usage.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    final generator = ProjectGenerator(
      ui: ui,
      state: state,
      stateVersion: (cmd['state-version'] as String?)?.trim(),
      force: cmd['force'] as bool,
    );

    ui.section('🛠️  Initializing Clean Architecture');
    ui.step('PATH    ', targetDir.path);
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    await generator.scaffold(targetDir);
    ui.success('✨ Clean architecture scaffolded successfully!');
    ui.info(
        'Your project is now organized with data/domain/presentation layers.');
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
      '  arcle init [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
