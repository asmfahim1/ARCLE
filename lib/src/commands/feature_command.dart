import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/feature_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/command_suggester.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class FeatureCommand {
  FeatureCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final create = ArgParser()
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
          help: 'Overwrite existing files if they exist',
          negatable: false)
      ..addFlag('interactive',
          abbr: 'i', help: 'Prompt for any missing values', defaultsTo: true);

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('create', create);
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    if (cmd.command == null) {
      if (cmd.rest.length > 1) {
        final unknown = cmd.rest.first;
        ui.error('Unknown feature command: $unknown');
        final suggestion =
            CommandSuggester().suggest(unknown, const ['create']);
        if (suggestion != null) {
          ui.info('Did you mean: arcle feature $suggestion ?');
        }
        console.line(_usage());
        return ExitCode.usage.code;
      }
      return _runCreate(cmd);
    }

    switch (cmd.command!.name) {
      case 'create':
        return _runCreate(cmd.command!);
      default:
        ui.error('Unknown feature command.');
        console.line(_usage());
        return ExitCode.usage.code;
    }
  }

  Future<int> _runCreate(ArgResults cmd) async {
    final ui = CliUi(console);
    var featureName = cmd.rest.isNotEmpty ? cmd.rest.first : null;
    if (featureName == null || featureName.trim().isEmpty) {
      if (_readBoolOption(cmd, 'interactive', true)) {
        featureName = console.prompt('Feature name: ');
      }
      if (featureName == null || featureName.trim().isEmpty) {
        ui.error('Missing feature name.');
        console.line(_usage());
        return ExitCode.usage.code;
      }
    }

    final targetDir =
        Directory(_readStringOption(cmd, 'path') ?? Directory.current.path);
    final config = ArcleConfig.readFrom(targetDir);

    final stateInput = _readStringOption(cmd, 'state');
    final interactive = _readBoolOption(cmd, 'interactive', true);

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

    final generator = FeatureGenerator(
      ui: ui,
      state: state,
      force: _readBoolOption(cmd, 'force', false),
    );
    ui.section('✨ Creating Feature Module');
    ui.step('FEATURE ', featureName.trim());
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    generator.createFeature(targetDir, featureName.trim());
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

  bool _readBoolOption(ArgResults cmd, String name, bool fallback) {
    if (!cmd.options.contains(name)) return fallback;
    return cmd[name] as bool? ?? fallback;
  }

  String? _readStringOption(ArgResults cmd, String name) {
    if (!cmd.options.contains(name)) return null;
    return cmd[name] as String?;
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle feature create <feature_name> [options]',
      '  arcle feature <feature_name> [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
