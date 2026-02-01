import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';

class BuildCommand {
  BuildCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final apkParser = ArgParser()
      ..addFlag('release',
          abbr: 'r', help: 'Build in release mode', negatable: false)
      ..addFlag('debug',
          abbr: 'd', help: 'Build in debug mode', negatable: false)
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Directory of a Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addFlag('interactive',
          abbr: 'i', help: 'Prompt for any missing values', defaultsTo: true);

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('apk', apkParser);
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    // Check if 'apk' subcommand is used
    if (cmd.command == null || cmd.command!.name != 'apk') {
      ui.error('Missing build target.');
      ui.info('Usage: arcle build apk [--release | --debug]');
      return ExitCode.usage.code;
    }

    final apkCmd = cmd.command!;
    final interactive = apkCmd['interactive'] as bool;
    final isRelease = apkCmd['release'] as bool;
    final isDebug = apkCmd['debug'] as bool;

    String mode;
    if (isRelease && isDebug) {
      ui.error('Cannot specify both --release and --debug.');
      return ExitCode.usage.code;
    } else if (isRelease) {
      mode = 'release';
    } else if (isDebug) {
      mode = 'debug';
    } else {
      // Prompt for mode if neither flag is provided
      final promptedMode = _promptMode(ui, interactive);
      if (promptedMode == null) {
        ui.error('No build mode selected.');
        ui.info('Use --release or --debug flag.');
        return ExitCode.usage.code;
      }
      mode = promptedMode;
    }

    final targetDir = Directory(apkCmd['path'] as String);

    ui.section('Building APK');
    ui.step('MODE    ', mode == 'release' ? 'Release' : 'Debug');
    ui.step('PROJECT ', targetDir.path);
    ui.info('ARCLE is building APK in $mode mode...');
    ui.info('This may take a few minutes...');

    final args = ['build', 'apk', '--$mode'];
    final result = await Process.run(
      'flutter',
      args,
      workingDirectory: targetDir.path,
      runInShell: true,
    );

    // Only show output if there are errors
    if (result.exitCode != 0) {
      if (result.stdout.toString().trim().isNotEmpty) {
        ui.raw(result.stdout.toString().trim());
      }
      if (result.stderr.toString().trim().isNotEmpty) {
        ui.raw(result.stderr.toString().trim());
      }
      ui.error('Build failed. Check the output above for errors.');
      return result.exitCode;
    }

    ui.success('APK built successfully!');
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
      '  arcle build apk [options]',
      '',
      'Options:',
      '  -r, --release    Build in release mode',
      '  -d, --debug      Build in debug mode',
      '  -p, --path       Directory of a Flutter project',
      '  -i, --interactive  Prompt for any missing values (default: true)',
      '',
      'Examples:',
      '  arcle build apk              # Interactive mode selection',
      '  arcle build apk --release    # Build release APK',
      '  arcle build apk --debug      # Build debug APK',
    ].join('\n');
  }
}
