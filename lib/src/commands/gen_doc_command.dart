import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/docs_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class GenDocCommand {
  GenDocCommand(this.console);

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
        help: 'Directory of an existing Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addFlag('force',
          abbr: 'f',
          help: 'Overwrite existing docs if they exist',
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
      ui.info('Run interactively or use --state 1|2|3 (bloc/getx/riverpod)');
      return ExitCode.usage.code;
    }

    final generator = DocsGenerator(
      ui: ui,
      state: state,
      force: cmd['force'] as bool,
    );
    ui.section('📚 Generating Documentation');
    ui.step('PATH    ', targetDir.path);
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    generator.generate(targetDir);
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
      '  arcle gen-doc [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
