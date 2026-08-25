import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../templates/ci/github_actions_templates.dart';
import '../templates/ci/gitlab_ci_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/console.dart';

/// Handles `arcle ci add|remove|list` — generates CI/CD pipeline configs
/// for GitHub Actions and GitLab CI based on the target project.
class CiCommand {
  CiCommand(this.console);

  final Console console;

  static const _providers = ['github', 'gitlab'];

  static ArgParser parser() {
    final addParser =
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Directory of a Flutter project',
            defaultsTo: Directory.current.path,
          )
          ..addOption(
            'branch',
            help: 'Branch that triggers the pipeline',
            defaultsTo: 'main',
          )
          ..addFlag(
            'test',
            help: 'Run flutter test in the pipeline',
            defaultsTo: true,
          )
          ..addFlag(
            'coverage',
            help: 'Run flutter test --coverage instead of flutter test',
            negatable: false,
          )
          ..addOption(
            'build',
            help: 'Build an artifact in the pipeline',
            allowed: const ['none', 'apk', 'appbundle'],
            defaultsTo: 'none',
          )
          ..addFlag(
            'force',
            abbr: 'f',
            help: 'Overwrite an existing pipeline file',
            negatable: false,
          );

    final removeParser =
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Directory of a Flutter project',
            defaultsTo: Directory.current.path,
          )
          ..addFlag(
            'force',
            abbr: 'f',
            help: 'Skip confirmation prompt',
            negatable: false,
          );

    final listParser =
        ArgParser()..addOption(
          'path',
          abbr: 'p',
          help: 'Directory of a Flutter project',
          defaultsTo: Directory.current.path,
        );

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('add', addParser)
      ..addCommand('remove', removeParser)
      ..addCommand('list', listParser);
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true || cmd.command == null) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    switch (cmd.command!.name) {
      case 'add':
        return _runAdd(cmd.command!);
      case 'remove':
        return _runRemove(cmd.command!);
      case 'list':
        return _runList(cmd.command!);
      default:
        ui.error('Unknown ci subcommand: ${cmd.command!.name}');
        console.line(_usage());
        return ExitCode.usage.code;
    }
  }

  // ─── Add ─────────────────────────────────────────────────────────────────

  Future<int> _runAdd(ArgResults cmd) async {
    final ui = CliUi(console);
    final provider =
        cmd.rest.isNotEmpty ? cmd.rest.first.trim().toLowerCase() : null;

    if (provider == null || provider.isEmpty) {
      ui.error('Missing CI provider.');
      ui.info('Usage: arcle ci add <github|gitlab>');
      return ExitCode.usage.code;
    }

    if (!_providers.contains(provider)) {
      ui.error(
        'Unknown CI provider "$provider". Supported: ${_providers.join(', ')}.',
      );
      return ExitCode.usage.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    if (!targetDir.existsSync()) {
      ui.error('Project directory does not exist: ${targetDir.path}');
      return ExitCode.software.code;
    }

    final branch = cmd['branch'] as String;
    final runCoverage = cmd['coverage'] as bool;
    final runTest = (cmd['test'] as bool) || runCoverage;
    final build = cmd['build'] as String;
    final force = cmd['force'] as bool;

    ui.section('Add CI/CD Pipeline');
    ui.step('PATH    ', targetDir.path);
    ui.step('PROVIDER', provider);
    ui.step('BRANCH  ', branch);
    ui.step(
      'TEST    ',
      runCoverage
          ? 'flutter test --coverage'
          : (runTest ? 'flutter test' : 'skipped'),
    );
    ui.step('BUILD   ', build);

    final relativePath = _pipelinePath(provider);
    final file = File(_join(targetDir.path, relativePath));

    if (file.existsSync() && !force) {
      ui.warn('$relativePath already exists. Use --force to overwrite.');
      return ExitCode.success.code;
    }

    final content =
        provider == 'github'
            ? GithubActionsTemplates.workflow(
              branch: branch,
              runTest: runTest,
              runCoverage: runCoverage,
              build: build,
            )
            : GitlabCiTemplates.pipeline(
              branch: branch,
              runTest: runTest,
              runCoverage: runCoverage,
              build: build,
            );

    file.parent.createSync(recursive: true);
    file.writeAsStringSync(content);
    ui.itemCreated(relativePath);

    ui.success('CI/CD pipeline added for $provider.');
    ui.info(
      'Commit and push $relativePath — $provider will pick it up automatically.',
    );
    return ExitCode.success.code;
  }

  // ─── Remove ──────────────────────────────────────────────────────────────

  Future<int> _runRemove(ArgResults cmd) async {
    final ui = CliUi(console);
    final provider =
        cmd.rest.isNotEmpty ? cmd.rest.first.trim().toLowerCase() : null;

    if (provider == null || provider.isEmpty) {
      ui.error('Missing CI provider.');
      ui.info('Usage: arcle ci remove <github|gitlab>');
      return ExitCode.usage.code;
    }

    if (!_providers.contains(provider)) {
      ui.error(
        'Unknown CI provider "$provider". Supported: ${_providers.join(', ')}.',
      );
      return ExitCode.usage.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    final force = cmd['force'] as bool;
    final relativePath = _pipelinePath(provider);
    final file = File(_join(targetDir.path, relativePath));

    if (!file.existsSync()) {
      ui.info('No $provider pipeline found at $relativePath.');
      return ExitCode.success.code;
    }

    if (!force) {
      final answer = console.prompt('Remove $relativePath? [y/N]: ');
      if ((answer ?? '').trim().toLowerCase() != 'y') {
        ui.info('Cancelled.');
        return ExitCode.success.code;
      }
    }

    file.deleteSync();
    ui.raw('    ${console.color('-', ConsoleColor.red)} $relativePath');
    ui.success('$provider pipeline removed.');
    return ExitCode.success.code;
  }

  // ─── List ────────────────────────────────────────────────────────────────

  Future<int> _runList(ArgResults cmd) async {
    final ui = CliUi(console);
    final targetDir = Directory(cmd['path'] as String);

    ui.section('CI/CD Pipelines');
    for (final provider in _providers) {
      final relativePath = _pipelinePath(provider);
      final exists = File(_join(targetDir.path, relativePath)).existsSync();
      ui.step(
        provider.toUpperCase().padRight(8),
        exists ? '$relativePath (present)' : 'not configured',
      );
    }
    return ExitCode.success.code;
  }

  // ─── helpers ────────────────────────────────────────────────────────────

  String _pipelinePath(String provider) {
    return provider == 'github' ? '.github/workflows/ci.yml' : '.gitlab-ci.yml';
  }

  String _join(String base, String relative) {
    final norm = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$norm';
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle ci add <github|gitlab> [options]   Add a CI/CD pipeline',
      '  arcle ci remove <github|gitlab> [options] Remove a CI/CD pipeline',
      '  arcle ci list [options]                   List configured pipelines',
      '',
      'Options (add):',
      '  --branch      Branch that triggers the pipeline (default: main)',
      '  --test        Run flutter test (default: on)',
      '  --coverage    Run flutter test --coverage instead',
      '  --build       none | apk | appbundle (default: none)',
      '  -p, --path    Project directory (default: current)',
      '  -f, --force   Overwrite existing pipeline file',
      '',
      'Options (remove):',
      '  -p, --path    Project directory (default: current)',
      '  -f, --force   Skip confirmation prompt',
      '',
      'Examples:',
      '  arcle ci add github',
      '  arcle ci add gitlab --coverage --build apk',
      '  arcle ci add github --branch develop --build appbundle',
      '  arcle ci list',
      '  arcle ci remove gitlab',
    ].join('\n');
  }
}
