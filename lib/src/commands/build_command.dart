import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';

class BuildCommand {
  BuildCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption(
        'mode',
        abbr: 'm',
        help: 'Build mode: debug or release',
        allowed: ['debug', 'release'],
      )
      ..addFlag('interactive',
          abbr: 'i', help: 'Prompt for any missing values', defaultsTo: true)
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Directory of a Flutter project',
        defaultsTo: Directory.current.path,
      );
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    final interactive = cmd['interactive'] as bool;
    var mode = (cmd['mode'] as String?)?.trim().toLowerCase();
    mode ??= _promptMode(ui, interactive);
    if (mode == null || mode.isEmpty) {
      ui.error('No build mode selected.');
      ui.info('Use --mode debug or --mode release');
      return ExitCode.usage.code;
    }
    if (mode != 'debug' && mode != 'release') {
      ui.error('Invalid build mode: $mode');
      ui.info('Valid options: debug, release');
      return ExitCode.usage.code;
    }
    final targetDir = Directory(cmd['path'] as String);

    final args = ['build', 'apk', '--$mode'];
    ui.section('🔨 Building APK');
    ui.step('MODE    ', mode == 'release' ? '🚀 Release' : '🔧 Debug');
    ui.step('COMMAND ', 'flutter ${args.join(' ')}');
    ui.info('This may take a few minutes...');

    final result = await Process.run(
      'flutter',
      args,
      workingDirectory: targetDir.path,
      runInShell: true,
    );

    if (result.stdout.toString().trim().isNotEmpty) {
      ui.raw(result.stdout.toString().trim());
    }
    if (result.stderr.toString().trim().isNotEmpty) {
      ui.raw(result.stderr.toString().trim());
    }

    if (result.exitCode != 0) {
      ui.error('Build failed. Check the output above for errors.');
      return result.exitCode;
    }

    ui.success('🚀 APK built successfully!');
    _renameApk(targetDir, mode, ui);
    return ExitCode.success.code;
  }

  String? _promptMode(CliUi ui, bool interactive) {
    if (!interactive) return null;
    ui.section('🎯 Select Build Mode');
    ui.raw('  1) 🔧 Debug   - Fast builds, includes debug symbols');
    ui.raw('  2) 🚀 Release - Optimized, ready for distribution');
    ui.raw('');
    for (var attempt = 0; attempt < 3; attempt++) {
      final input = console.prompt('  Select mode (1/2) [2]: ')?.trim();
      if (input == null || input.isEmpty) return 'release';
      if (input == '1' || input.toLowerCase() == 'debug') return 'debug';
      if (input == '2' || input.toLowerCase() == 'release') return 'release';
      ui.warn('Invalid selection. Please choose 1, 2, debug, or release.');
    }
    return null;
  }

  void _renameApk(Directory targetDir, String mode, CliUi ui) {
    final apkFile = _findApkFile(targetDir, mode);
    if (apkFile == null) {
      ui.warn('APK not found at expected output locations; skipping rename.');
      return;
    }

    final pubspec = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      ui.warn('pubspec.yaml not found; skipping APK rename.');
      return;
    }

    final content = pubspec.readAsStringSync();
    final name = _extractYamlValue(content, 'name');
    final version = _extractYamlValue(content, 'version');
    if (name == null || version == null) {
      ui.warn(
          'Could not read name/version from pubspec.yaml; skipping rename.');
      return;
    }

    final safeName = _sanitizeFilePart(name);
    final safeVersion = _sanitizeFilePart(version.split('+').first);
    final newName = '${safeName}_v$safeVersion.apk';
    final newPath = _join(apkFile.parent.path, newName);
    final targetFile = File(newPath);
    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }
    final renamed = apkFile.renameSync(newPath);
    ui.success('APK renamed to ${renamed.path}');
  }

  File? _findApkFile(Directory targetDir, String mode) {
    final candidates = [
      _join(targetDir.path, 'build/app/outputs/flutter-apk/app-$mode.apk'),
      _join(targetDir.path, 'build/app/outputs/apk/$mode/app-$mode.apk'),
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) return file;
    }
    return null;
  }

  String? _extractYamlValue(String content, String key) {
    final regex = RegExp('^$key\\s*:\\s*(.+)\$', multiLine: true);
    final match = regex.firstMatch(content);
    if (match == null) return null;
    var value = match.group(1)!.trim();
    final commentIndex = value.indexOf('#');
    if (commentIndex >= 0) {
      value = value.substring(0, commentIndex).trim();
    }
    if ((value.startsWith("'") && value.endsWith("'")) ||
        (value.startsWith('"') && value.endsWith('"'))) {
      value = value.substring(1, value.length - 1);
    }
    return value.trim();
  }

  String _sanitizeFilePart(String value) {
    final replaced = value.replaceAll(RegExp(r'\s+'), '_');
    return replaced.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
  }

  String _join(String base, String relative) {
    final normalized = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$normalized';
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle build [options]',
      '',
      'Options:',
      parser().usage,
    ].join('\n');
  }
}
