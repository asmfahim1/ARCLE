import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class VerifyCommand {
  VerifyCommand(this.console);

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
        help: 'Directory of an ARCLE Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addFlag(
        'skip-analyze',
        help: 'Skip flutter analyze',
        negatable: false,
      )
      ..addFlag(
        'skip-test',
        help: 'Skip flutter test',
        negatable: false,
      )
      ..addFlag(
        'skip-codegen',
        help: 'Skip build_runner check for BLoC projects',
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

    ui.section('Project Verify');
    ui.step('PATH    ', targetDir.path);
    if (state != null) {
      ui.step('STATE   ', state.label);
    }

    var failed = false;

    if (cmd['skip-analyze'] != true) {
      failed = !await _runStep(
        ui,
        'ANALYZE ',
        'flutter',
        const ['analyze'],
        targetDir,
      ) ||
          failed;
    }

    if (cmd['skip-test'] != true) {
      failed = !await _runStep(
        ui,
        'TEST    ',
        'flutter',
        const ['test'],
        targetDir,
      ) ||
          failed;
    }

    if (state == StateManagement.bloc && cmd['skip-codegen'] != true) {
      failed = !await _runStep(
        ui,
        'CODEGEN ',
        'dart',
        const ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        targetDir,
      ) ||
          failed;
    }

    if (failed) {
      ui.error('Verification failed.');
      return ExitCode.software.code;
    }

    ui.success('Verification passed.');
    return ExitCode.success.code;
  }

  Future<bool> _runStep(
    CliUi ui,
    String label,
    String executable,
    List<String> args,
    Directory targetDir,
  ) async {
    ui.step(label, '$executable ${args.join(' ')}');
    try {
      final result = await Process.run(
        executable,
        args,
        workingDirectory: targetDir.path,
        runInShell: true,
      );
      if (result.exitCode != 0) {
        final stdout = result.stdout.toString().trim();
        final stderr = result.stderr.toString().trim();
        if (stdout.isNotEmpty) {
          ui.raw(stdout);
        }
        if (stderr.isNotEmpty) {
          ui.raw(stderr);
        }
        ui.error('$executable ${args.first} failed.');
        return false;
      }
      ui.success('$executable ${args.first} passed.');
      return true;
    } catch (error) {
      ui.error('Failed to run $executable: $error');
      return false;
    }
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle verify [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
