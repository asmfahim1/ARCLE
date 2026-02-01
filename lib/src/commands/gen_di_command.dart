import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/project_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class GenDiCommand {
  GenDiCommand(this.console);

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

    if (state == null) {
      ui.error('No state management selected.');
      ui.info('Run with --state bloc|getx|riverpod to be explicit.');
      return ExitCode.usage.code;
    }

    // For GetX and Riverpod, show a friendly message - no code generation needed
    if (state != StateManagement.bloc) {
      ui.section('ℹ️  DI Generation Not Required');
      ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
      ui.success('${state.label} does not require code generation for DI.');
      ui.info('Your providers are already set up and ready to use.');
      ui.info('No files need to be deleted or regenerated.');
      return ExitCode.success.code;
    }

    final generator = ProjectGenerator(
      ui: ui,
      state: state,
      stateVersion: null,
      force: cmd['force'] as bool,
    );

    ui.section('🔧 Generating Dependency Injection');
    ui.step('PATH    ', targetDir.path);
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    await generator.scaffoldDi(targetDir);
    ui.success('✨ DI files generated successfully!');
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
      '  arcle gen-di [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
