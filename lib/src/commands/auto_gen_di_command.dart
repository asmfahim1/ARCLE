import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../generators/project_generator.dart';
import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

/// Auto-generates Dependency Injection (DI) and completes the setup.
///
/// This command performs a full DI regeneration workflow:
/// 1. Generates/updates DI files
/// 2. Updates project dependencies (pubspec.yaml)
/// 3. Runs `pub get` to fetch dependencies
/// 4. Runs build_runner for BLoC code generation (if using BLoC)
///
/// Use this command when you:
/// - Want a complete one-shot setup after modifying DI
/// - Add/remove service dependencies frequently
/// - Need everything wired up and ready immediately
/// - Are setting up a new project with DI
///
/// For manual control over build steps or quick DI updates only,
/// use `gen-di` instead.
class AutoGenDiCommand {
  AutoGenDiCommand(this.console);

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
      ui.section('ℹ️  DI Regeneration Not Required');
      ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
      ui.success('${state.label} does not require code generation for DI.');
      ui.info('Your providers are already set up and ready to use.');
      ui.info('If you need to regenerate DI files, use: arcle gen-di');
      return ExitCode.success.code;
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
      'Description:',
      '  Auto-generate DI files AND complete the entire setup in one command.',
      '  Workflow: DI generation → pub get → build_runner (for BLoC)',
      '',
      'When to use:',
      '  • You want everything done automatically in a single step',
      '  • After modifying service dependencies',
      '  • Setting up a fresh project with DI scaffolding',
      '  • Using BLoC state management (needs build_runner)',
      '  • You want maximum convenience without manual steps',
      '',
      'Alias: arcle autodi',
      '',
      'Related: arcle gen-di (for DI-only generation without build steps)',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
