import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';
import '../utils/history_writer.dart';
import '../utils/string_helpers.dart';

/// Handles `arcle history add` — appends a work-tracking entry to the
/// root `docs/HISTORY.md` and, when a `--feature` is given, to that
/// feature's `lib/features/<feature>/docs/HISTORY.md` as well.
///
/// This is the mechanism AI agents (Claude Code, Codex, Gemini) and
/// humans use to keep project/feature history up to date after doing
/// work, e.g.:
///
///   arcle history add --feature login --summary "Implemented login API" --agent claude
class HistoryCommand {
  HistoryCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final add =
        ArgParser()
          ..addOption('feature', abbr: 'F', help: 'Feature name (snake_case)')
          ..addOption(
            'summary',
            abbr: 's',
            help: 'One-line summary of the work done',
          )
          ..addOption(
            'agent',
            abbr: 'a',
            help: 'Who did the work (e.g. claude, codex, gemini, human)',
            defaultsTo: 'human',
          )
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Directory of an ARCLE Flutter project',
            defaultsTo: Directory.current.path,
          );

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('add', add);
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    if (cmd.command == null || cmd.command!.name != 'add') {
      ui.error('Unknown history command.');
      console.line(_usage());
      return ExitCode.usage.code;
    }

    return _runAdd(cmd.command!);
  }

  Future<int> _runAdd(ArgResults cmd) async {
    final ui = CliUi(console);
    final summary = (cmd['summary'] as String?)?.trim();
    if (summary == null || summary.isEmpty) {
      ui.error('Missing --summary.');
      ui.info(
        'Usage: arcle history add --summary "<what changed>" '
        '[--feature <name>] [--agent claude|codex|gemini|human]',
      );
      return ExitCode.usage.code;
    }

    final agent = (cmd['agent'] as String?)?.trim();
    final agentLabel = (agent == null || agent.isEmpty) ? 'human' : agent;
    final featureInput = (cmd['feature'] as String?)?.trim();
    final feature =
        (featureInput == null || featureInput.isEmpty)
            ? null
            : StringHelpers.snakeCase(featureInput);

    final targetDir = Directory(cmd['path'] as String);

    HistoryWriter.appendRoot(
      targetDir,
      summary: summary,
      agent: agentLabel,
      feature: feature ?? '-',
    );
    ui.itemUpdated('docs/HISTORY.md');

    if (feature != null) {
      final wrote = HistoryWriter.appendFeature(
        targetDir,
        feature: feature,
        summary: summary,
        agent: agentLabel,
      );
      if (wrote) {
        ui.itemUpdated('lib/features/$feature/docs/${feature}_history.md');
      } else {
        ui.warn(
          'lib/features/$feature/docs/${feature}_history.md not found; '
          'skipping feature history update.',
        );
        ui.info('Run "arcle feature $feature" first if this feature exists.');
      }
    }

    ui.success('History updated.');
    return ExitCode.success.code;
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle history add --summary "<text>" [options]',
      '',
      'Appends a work-tracking entry to docs/HISTORY.md and, when --feature',
      'is given, to lib/features/<feature>/docs/HISTORY.md as well.',
      '',
      'Options:',
      parser().usage,
      '',
      'Examples:',
      '  arcle history add --summary "Fixed login crash" --agent claude',
      '  arcle history add --feature login --summary "Implemented login API" --agent codex',
    ].join('\n');
  }
}
