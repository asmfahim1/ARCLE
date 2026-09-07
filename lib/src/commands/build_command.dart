import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';

class BuildCommand {
  BuildCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final apkParser =
        ArgParser()
          ..addFlag(
            'release',
            abbr: 'r',
            help: 'Build in release mode',
            negatable: false,
          )
          ..addFlag(
            'debug',
            abbr: 'd',
            help: 'Build in debug mode',
            negatable: false,
          )
          ..addOption(
            'env',
            help: 'Build environment passed as --dart-define=FLAVOR',
            allowed: const ['prod', 'stag', 'local'],
          )
          ..addOption(
            'version-name',
            help: 'Override Flutter build-name / Android versionName',
          )
          ..addOption(
            'version-code',
            help: 'Override Flutter build-number / Android versionCode',
          )
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Directory of a Flutter project',
            defaultsTo: Directory.current.path,
          )
          ..addFlag(
            'interactive',
            abbr: 'i',
            help: 'Prompt for any missing values',
            defaultsTo: true,
          );

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
    final env = apkCmd['env'] as String?;
    final versionName = (apkCmd['version-name'] as String?)?.trim();
    final versionCode = (apkCmd['version-code'] as String?)?.trim();

    List<String> modes;
    if (isRelease && isDebug) {
      ui.error('Cannot specify both --release and --debug.');
      return ExitCode.usage.code;
    } else if (isRelease) {
      modes = ['release'];
    } else if (isDebug) {
      modes = ['debug'];
    } else {
      // Prompt for mode if neither flag is provided
      final promptedModes = _promptModes(ui, interactive);
      if (promptedModes == null) {
        ui.error('No build mode selected.');
        ui.info('Use --release or --debug flag.');
        return ExitCode.usage.code;
      }
      modes = promptedModes;
    }

    final targetDir = Directory(apkCmd['path'] as String);
    if (versionCode != null &&
        versionCode.isNotEmpty &&
        int.tryParse(versionCode) == null) {
      ui.error('--version-code must be an integer.');
      return ExitCode.usage.code;
    }
    var selectedVersionName = versionName;
    var selectedVersionCode = versionCode;
    if (selectedVersionName == null &&
        selectedVersionCode == null &&
        interactive) {
      final version = _promptVersion(ui, targetDir);
      if (version == null) {
        ui.error('No version selected.');
        return ExitCode.usage.code;
      }
      selectedVersionName = version.$1;
      selectedVersionCode = version.$2;
    }
    if ((selectedVersionName != null && selectedVersionName.isNotEmpty) ||
        (selectedVersionCode != null && selectedVersionCode.isNotEmpty)) {
      final updated = _updatePubspecVersion(
        targetDir,
        ui,
        versionName: selectedVersionName,
        versionCode: selectedVersionCode,
      );
      if (!updated) {
        return ExitCode.software.code;
      }
    }
    for (final mode in modes) {
      final buildEnv = env ?? (mode == 'release' ? 'prod' : 'stag');
      if (!_updatePersistentEnv(targetDir, ui, buildEnv)) {
        return ExitCode.software.code;
      }
      ui.section('Building APK');
      ui.step('MODE    ', mode == 'release' ? 'Release' : 'Debug');
      ui.step('PROJECT ', targetDir.path);
      ui.step('ENV     ', buildEnv);
      if (selectedVersionName != null && selectedVersionName.isNotEmpty) {
        ui.step('VERNAME ', selectedVersionName);
      }
      if (selectedVersionCode != null && selectedVersionCode.isNotEmpty) {
        ui.step('VERCODE ', selectedVersionCode);
      }
      ui.info('ARCLE is building APK in $mode mode...');
      ui.info('This may take a few minutes...');

      final args = [
        'build',
        'apk',
        '--$mode',
        '--dart-define=FLAVOR=$buildEnv',
      ];
      final result = await Process.run(
        'flutter',
        args,
        workingDirectory: targetDir.path,
        runInShell: true,
      );
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
      _renameApk(targetDir, mode, ui, env: buildEnv);
    }
    return ExitCode.success.code;
  }

  List<String>? _promptModes(CliUi ui, bool interactive) {
    if (!interactive) return null;
    ui.section('🎯 Select Build Mode');
    ui.raw('  1) Build APK in debug (env = stag)');
    ui.raw('  2) Build APK for release (env = prod)');
    ui.raw('  3) Build APK for both (debug = stag, release = prod)');
    ui.raw('');
    for (var attempt = 0; attempt < 3; attempt++) {
      final input = console.prompt('  Select option (1/2/3) [2]: ')?.trim();
      if (input == null || input.isEmpty || input == '2') return ['release'];
      if (input == '1' || input.toLowerCase() == 'debug') return ['debug'];
      if (input == '3' || input.toLowerCase() == 'both') {
        return ['debug', 'release'];
      }
      ui.warn('Invalid selection. Please choose 1, 2, or 3.');
    }
    return null;
  }

  (String, String?)? _promptVersion(CliUi ui, Directory targetDir) {
    final pubspec = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) return null;
    final current = _extractYamlValue(pubspec.readAsStringSync(), 'version');
    if (current == null || current.isEmpty) return null;
    final parts = current.split('+');
    final currentName = parts.first.trim();
    final currentCode = parts.length > 1 ? parts[1].trim() : null;
    ui.section('Select Version');
    ui.raw('  1) Current version ($current)');
    ui.raw('  2) Type your custom version name');
    for (var attempt = 0; attempt < 3; attempt++) {
      final choice = console.prompt('  Select option (1/2) [1]: ')?.trim();
      if (choice == null || choice.isEmpty || choice == '1') {
        return (currentName, currentCode);
      }
      if (choice == '2') {
        final custom =
            console.prompt('  Type your custom version name: ')?.trim();
        if (custom == null || custom.isEmpty) {
          ui.warn('Version name cannot be empty.');
          continue;
        }
        final customParts = custom.split('+');
        final name = customParts.first.trim();
        final code =
            customParts.length > 1 ? customParts[1].trim() : currentCode;
        if (name.isEmpty || (code != null && int.tryParse(code) == null)) {
          ui.warn(
            'Use a valid version name and optional numeric version code.',
          );
          continue;
        }
        return (name, code);
      }
      ui.warn('Invalid selection. Please choose 1 or 2.');
    }
    return null;
  }

  void _renameApk(Directory targetDir, String mode, CliUi ui, {String? env}) {
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
        'Could not read name/version from pubspec.yaml; skipping rename.',
      );
      return;
    }

    final safeName = _sanitizeFilePart(name);
    final safeVersion = _sanitizeFilePart(version.split('+').first);
    final safeEnv = env == null || env.isEmpty ? null : _sanitizeFilePart(env);
    final newName =
        safeEnv == null
            ? '${safeName}_V$safeVersion.apk'
            : '${safeName}_${safeEnv}_V$safeVersion.apk';
    final newPath = _join(apkFile.parent.path, newName);
    final targetFile = File(newPath);
    if (targetFile.existsSync()) {
      targetFile.deleteSync();
    }
    final renamed = apkFile.renameSync(newPath);
    ui.success('APK renamed to ${renamed.path}');
  }

  bool _updatePubspecVersion(
    Directory targetDir,
    CliUi ui, {
    String? versionName,
    String? versionCode,
  }) {
    final pubspec = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) {
      ui.error('pubspec.yaml not found; cannot persist version changes.');
      return false;
    }

    final content = pubspec.readAsStringSync();
    final currentVersion = _extractYamlValue(content, 'version');
    if (currentVersion == null || currentVersion.isEmpty) {
      ui.error('Could not read version from pubspec.yaml.');
      return false;
    }

    final parts = currentVersion.split('+');
    final currentName = parts.first.trim();
    final currentCode = parts.length > 1 ? parts[1].trim() : null;
    final nextName =
        (versionName != null && versionName.isNotEmpty)
            ? versionName
            : currentName;
    final nextCode =
        (versionCode != null && versionCode.isNotEmpty)
            ? versionCode
            : currentCode;
    final nextVersion =
        nextCode == null || nextCode.isEmpty ? nextName : '$nextName+$nextCode';

    final pattern = RegExp(r'^version\s*:\s*.+$', multiLine: true);
    if (!pattern.hasMatch(content)) {
      ui.error('pubspec.yaml has no version field to update.');
      return false;
    }

    final updated = content.replaceFirst(pattern, 'version: $nextVersion');
    if (updated == content) {
      ui.step('VERSION ', 'pubspec.yaml already set to $nextVersion');
      return true;
    }

    pubspec.writeAsStringSync(updated);
    ui.step('VERSION ', 'pubspec.yaml -> $nextVersion');
    return true;
  }

  bool _updatePersistentEnv(Directory targetDir, CliUi ui, String env) {
    final envFactory = File(
      _join(targetDir.path, 'lib/core/env/env_factory.dart'),
    );
    if (!envFactory.existsSync()) {
      ui.error(
        'lib/core/env/env_factory.dart not found; cannot persist environment.',
      );
      return false;
    }

    final content = envFactory.readAsStringSync();
    final defaultValuePattern = RegExp(r"defaultValue:\s*'(prod|stag|local)'");
    if (!defaultValuePattern.hasMatch(content)) {
      ui.error(
        'Could not find FLAVOR defaultValue in lib/core/env/env_factory.dart.',
      );
      return false;
    }

    final updated = content.replaceFirst(
      defaultValuePattern,
      "defaultValue: '$env'",
    );
    if (updated == content) {
      ui.step('ENVFILE ', 'env_factory.dart already defaults to $env');
      return true;
    }

    envFactory.writeAsStringSync(updated);
    ui.step('ENVFILE ', 'env_factory.dart -> default $env');
    return true;
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
      '      --env        Build environment: prod, stag, or local',
      '      --version-name  Override Android versionName',
      '      --version-code  Override Android versionCode',
      '  -p, --path       Directory of a Flutter project',
      '  -i, --interactive  Prompt for any missing values (default: true)',
      '',
      'Examples:',
      '  arcle build apk              # Interactive mode and version selection',
      '  arcle build apk --release    # Build release APK',
      '  arcle build apk --debug      # Build debug APK',
      '  arcle build apk --release --env prod --version-name 1.2.0 --version-code 12',
    ].join('\n');
  }
}
