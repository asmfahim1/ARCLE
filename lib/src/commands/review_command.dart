import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';

class ReviewCommand {
  ReviewCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addFlag(
        'skip-analyze',
        help: 'Skip dart analyze',
        negatable: false,
      )
      ..addFlag(
        'skip-format',
        help: 'Skip dart format check',
        negatable: false,
      )
      ..addFlag(
        'skip-missing-tests',
        help: 'Skip missing-tests scan',
        negatable: false,
      )
      ..addFlag(
        'test',
        help: 'Run flutter test (opt-in)',
        negatable: false,
      )
      ..addFlag(
        'coverage',
        help: 'Run flutter test --coverage and report percentage (implies --test)',
        negatable: false,
      )
      ..addFlag(
        'ai',
        help: 'Run AI-assisted review using the configured agent',
        negatable: false,
      )
      ..addFlag(
        'staged',
        help: 'Diff only staged changes (git diff --staged); default: all uncommitted',
        negatable: false,
      )
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Project directory',
        defaultsTo: Directory.current.path,
      );
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);

    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    final staged = cmd['staged'] as bool;
    final runTest = (cmd['test'] as bool) || (cmd['coverage'] as bool);
    final runCoverage = cmd['coverage'] as bool;
    final runAi = cmd['ai'] as bool;

    if (!targetDir.existsSync()) {
      ui.error('Directory not found: ${targetDir.path}');
      return ExitCode.usage.code;
    }

    ui.section('Pre-Commit Review');
    ui.step('PATH    ', targetDir.path);
    console.line('');

    var passed = 0;
    var failed = 0;
    var warnings = 0;

    // ── dart analyze ─────────────────────────────────────────────────────────
    if (cmd['skip-analyze'] != true) {
      final ok = await _runCheck(
        ui, 'ANALYZE ', 'dart', const ['analyze'], targetDir,
      );
      ok ? passed++ : failed++;
    }

    // ── dart format ──────────────────────────────────────────────────────────
    if (cmd['skip-format'] != true) {
      final ok = await _runCheck(
        ui,
        'FORMAT  ',
        'dart',
        const ['format', '--output=none', '--set-exit-if-changed', '.'],
        targetDir,
      );
      ok ? passed++ : failed++;
    }

    // ── missing-tests scan ───────────────────────────────────────────────────
    if (cmd['skip-missing-tests'] != true) {
      final w = _runMissingTestsScan(ui, targetDir, staged: staged);
      warnings += w;
      if (w == 0) passed++;
    }

    // ── flutter test ─────────────────────────────────────────────────────────
    if (runTest) {
      final testArgs =
          runCoverage ? const ['test', '--coverage'] : const ['test'];
      final ok = await _runCheck(
        ui,
        runCoverage ? 'COVERAGE' : 'TEST    ',
        'flutter',
        testArgs,
        targetDir,
      );
      ok ? passed++ : failed++;
      if (runCoverage && ok) _reportCoverage(ui, targetDir);
    }

    // ── AI review ────────────────────────────────────────────────────────────
    if (runAi) {
      await _runAiReview(ui, targetDir, staged: staged);
    }

    // ── summary ──────────────────────────────────────────────────────────────
    console.line('');
    console.line('  ─────────────────────────────────────────────────');
    final parts = <String>[];
    if (passed > 0) parts.add('$passed passed');
    if (failed > 0) parts.add('$failed failed');
    if (warnings > 0) parts.add('$warnings warning(s)');
    console.line('  ${parts.join(', ')}');
    console.line('');

    if (failed > 0) {
      ui.error('Review failed — fix issues before committing.');
      return ExitCode.software.code;
    }
    if (warnings > 0) {
      ui.warn('Review passed with warnings. Consider adding missing tests.');
    } else {
      ui.success('Review passed. Ready to commit.');
    }
    return ExitCode.success.code;
  }

  Future<bool> _runCheck(
    CliUi ui,
    String label,
    String executable,
    List<String> args,
    Directory dir,
  ) async {
    ui.step(label, '$executable ${args.join(' ')}');
    try {
      final result = await Process.run(
        executable,
        args,
        workingDirectory: dir.path,
        runInShell: true,
      );
      if (result.exitCode != 0) {
        final out = result.stdout.toString().trim();
        final err = result.stderr.toString().trim();
        if (out.isNotEmpty) ui.raw(out);
        if (err.isNotEmpty) ui.raw(err);
        ui.error('$executable ${args.first} failed.');
        return false;
      }
      ui.success('$executable ${args.first} passed.');
      return true;
    } catch (e) {
      ui.error('Could not run $executable: $e');
      return false;
    }
  }

  int _runMissingTestsScan(
    CliUi ui,
    Directory dir, {
    required bool staged,
  }) {
    ui.step(
        'TESTS   ', 'Scanning changed files for missing test counterparts...');

    final changedFiles = _getChangedDartFiles(dir, staged: staged);
    if (changedFiles == null) {
      ui.warn(
          'Not a git repository or git not available — skipping scan.');
      return 0;
    }

    if (changedFiles.isEmpty) {
      ui.success('No changed lib/ files to check.');
      return 0;
    }

    final missing = <String>[];
    for (final relPath in changedFiles) {
      final testPath = _toTestPath(relPath);
      if (testPath == null) continue;
      final testFile = File(
        '${dir.path}${Platform.pathSeparator}'
        '${testPath.replaceAll('/', Platform.pathSeparator)}',
      );
      if (!testFile.existsSync()) missing.add(relPath);
    }

    if (missing.isEmpty) {
      ui.success('All changed files have test counterparts.');
      return 0;
    }

    ui.warn('${missing.length} changed file(s) have no test counterpart:');
    for (final f in missing) {
      console.line('    └ $f');
    }
    return missing.length;
  }

  List<String>? _getChangedDartFiles(Directory dir, {required bool staged}) {
    try {
      final args = staged
          ? ['diff', '--staged', '--name-only']
          : ['diff', 'HEAD', '--name-only'];
      final result = Process.runSync(
        'git',
        args,
        workingDirectory: dir.path,
        runInShell: true,
      );
      if (result.exitCode != 0) return null;
      return result.stdout
          .toString()
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.startsWith('lib/') && l.endsWith('.dart'))
          .toList();
    } catch (_) {
      return null;
    }
  }

  String? _toTestPath(String libPath) {
    if (!libPath.startsWith('lib/')) return null;
    final withoutLib = libPath.substring('lib/'.length);
    final withoutExt = withoutLib.endsWith('.dart')
        ? withoutLib.substring(0, withoutLib.length - 5)
        : withoutLib;
    return 'test/${withoutExt}_test.dart';
  }

  void _reportCoverage(CliUi ui, Directory dir) {
    final lcov = File(
      '${dir.path}${Platform.pathSeparator}'
      'coverage${Platform.pathSeparator}lcov.info',
    );
    if (!lcov.existsSync()) return;
    try {
      final lines = lcov.readAsLinesSync();
      var found = 0;
      var hit = 0;
      for (final line in lines) {
        if (line.startsWith('LF:')) found += int.parse(line.substring(3));
        if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
      }
      if (found == 0) return;
      final pct = ((hit / found) * 100).toStringAsFixed(1);
      ui.info('Coverage: $pct% ($hit/$found lines)');
    } catch (_) {}
  }

  Future<void> _runAiReview(
    CliUi ui,
    Directory dir, {
    required bool staged,
  }) async {
    ui.step('AI      ', 'Running AI-assisted review...');

    final agent = _detectAgent(dir);
    if (agent == null) {
      ui.warn('No AI agent configured. Run arcle configure-ai first.');
      return;
    }

    final diff = _getDiff(dir, staged: staged);
    if (diff == null || diff.trim().isEmpty) {
      ui.warn('No diff found — nothing to review.');
      return;
    }

    const prompt =
        'You are a senior Flutter developer. Review the following code diff '
        'for this Clean Architecture Flutter project. Check for: bugs, logic '
        'errors, missing error handling, architecture violations, naming '
        'inconsistencies, and test coverage gaps. Be concise and actionable.'
        '\n\nDiff:\n\n';

    try {
      final result = await Process.run(
        agent,
        ['-p', '$prompt$diff'],
        workingDirectory: dir.path,
        runInShell: true,
      );
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          console.line('');
          console.line(
              '  ── AI Review ($agent) ──────────────────────────────');
          for (final line in output.split('\n')) {
            console.line('  $line');
          }
          console.line('');
        }
      } else {
        ui.warn(
            '$agent returned non-zero exit — check that it is installed and authenticated.');
      }
    } catch (_) {
      ui.warn(
          'Could not run $agent — make sure it is installed and on your PATH.');
    }
  }

  String? _detectAgent(Directory dir) {
    final candidates = {
      '.claude': 'claude',
      '.codex': 'codex',
      '.gemini': 'gemini',
    };
    for (final entry in candidates.entries) {
      final agentDir = Directory(
          '${dir.path}${Platform.pathSeparator}${entry.key}');
      if (agentDir.existsSync()) return entry.value;
    }
    return null;
  }

  String? _getDiff(Directory dir, {required bool staged}) {
    try {
      final args = staged ? ['diff', '--staged'] : ['diff', 'HEAD'];
      final result = Process.runSync(
        'git',
        args,
        workingDirectory: dir.path,
        runInShell: true,
      );
      if (result.exitCode != 0) return null;
      final diff = result.stdout.toString();
      if (diff.length > 8000) {
        return '${diff.substring(0, 8000)}\n...(truncated)';
      }
      return diff;
    } catch (_) {
      return null;
    }
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle review  [options]',
      '  arcle audit   [options]',
      '  arcle -r      [options]',
      '',
      'Pre-commit quality gate: analyze, format, missing-tests scan.',
      'Use --test to also run flutter test, --ai for AI-assisted diff review.',
      '',
      'Options:',
      parser().usage,
      '',
      'Examples:',
      '  arcle review                  # analyze + format + missing-tests (fast)',
      '  arcle review --test           # also run flutter test',
      '  arcle review --coverage       # flutter test --coverage + report %',
      '  arcle review --ai             # AI-assisted diff review',
      '  arcle review --ai --staged    # review only staged changes',
      '  arcle -r                      # shortcut',
    ].join('\n');
  }
}
