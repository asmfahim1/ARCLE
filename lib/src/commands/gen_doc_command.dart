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
        allowed: const ['bloc', 'getx', 'riverpod'],
        help: 'State management option (bloc, getx, riverpod)',
      )
      ..addOption(
        'format',
        abbr: 'F',
        allowed: const ['word', 'pdf'],
        help: 'Document format: word (.docx) or pdf (.tex for LaTeX)',
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

    // Determine document format
    final formatInput = cmd['format'] as String?;
    final docFormat = _resolveFormat(formatInput, interactive, ui);
    if (docFormat == null) {
      ui.error('No document format selected.');
      ui.info('Run with --format word or --format pdf to be explicit.');
      return ExitCode.usage.code;
    }

    final generator = DocsGenerator(
      ui: ui,
      state: state,
      force: cmd['force'] as bool,
      format: docFormat,
    );
    ui.section('📚 Generating Documentation');
    ui.step('PATH    ', targetDir.path);
    ui.step('STATE   ', '${state.label} ${_stateIcon(state)}');
    ui.step(
        'FORMAT  ', docFormat == 'word' ? '📄 Word (.docx)' : '📑 PDF (.tex)');
    generator.generate(targetDir);
    return ExitCode.success.code;
  }

  String? _resolveFormat(String? input, bool interactive, CliUi ui) {
    if (input != null && input.trim().isNotEmpty) {
      final normalized = input.trim().toLowerCase();
      if (normalized == 'word' || normalized == 'pdf') {
        return normalized;
      }
    }

    if (!interactive) return null;

    ui.section('📄 Select Document Format');
    console.line('  1) 📄 Word  - Microsoft Word compatible (.docx XML)');
    console.line('  2) 📑 PDF   - LaTeX format (.tex) - convert to PDF');
    console.line('');

    for (var attempt = 0; attempt < 3; attempt++) {
      final choice = console.prompt('  Select format (1/2) [1]: ')?.trim();
      if (choice == null ||
          choice.isEmpty ||
          choice == '1' ||
          choice.toLowerCase() == 'word') {
        return 'word';
      }
      if (choice == '2' || choice.toLowerCase() == 'pdf') {
        return 'pdf';
      }
      ui.warn('Invalid selection. Please choose 1, 2, word, or pdf.');
    }
    return null;
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
