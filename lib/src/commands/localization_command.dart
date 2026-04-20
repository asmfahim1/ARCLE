import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../templates/core/localization_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class LocalizationCommand {
  LocalizationCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final addParser = ArgParser()
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
        'force',
        abbr: 'f',
        help: 'Overwrite existing localization files',
        negatable: false,
      );

    final removeParser = ArgParser()
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Directory of an ARCLE Flutter project',
        defaultsTo: Directory.current.path,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Skip confirmation prompt',
        negatable: false,
      );

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('add', addParser)
      ..addCommand('remove', removeParser);
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
      default:
        ui.error('Unknown localization subcommand: ${cmd.command!.name}');
        console.line(_usage());
        return ExitCode.usage.code;
    }
  }

  // ─── Add ─────────────────────────────────────────────────────────────────

  Future<int> _runAdd(ArgResults cmd) async {
    final ui = CliUi(console);
    final targetDir = Directory(cmd['path'] as String);
    final force = cmd['force'] as bool;

    if (!targetDir.existsSync()) {
      ui.error('Project directory does not exist: ${targetDir.path}');
      return ExitCode.software.code;
    }

    final config = ArcleConfig.readFrom(targetDir);
    final stateInput = cmd['state'] as String?;

    StateManagement? state;
    if (stateInput != null && stateInput.trim().isNotEmpty) {
      state = StatePicker(console).resolve(stateInput, interactive: false);
    } else if (config?.state != null) {
      state = config!.state;
      ui.info(
        'Detected state management from ${ArcleConfig.filename}: ${state.label}.',
      );
    } else {
      state = StatePicker(console).resolve(null, interactive: true);
    }

    if (state == null) {
      ui.error('No state management selected.');
      ui.info('Run with --state bloc|getx|riverpod to be explicit.');
      return ExitCode.usage.code;
    }

    ui.section('Add Localization');
    ui.step('PATH    ', targetDir.path);
    ui.step('STATE   ', state.label);

    final appStringsFile = File(
      _join(targetDir.path, 'lib/core/localization/app_strings.dart'),
    );
    if (appStringsFile.existsSync() && !force) {
      ui.warn('Localization already exists. Use --force to overwrite.');
      return ExitCode.success.code;
    }

    _createJsonAssets(targetDir, ui, force);
    _createDartFiles(targetDir, state, ui, force);
    _updatePubspec(targetDir, ui);

    ui.success('Localization added successfully.');
    ui.info(
      'Register AppLocalizations.delegate in your MaterialApp localizationsDelegates.',
    );

    return ExitCode.success.code;
  }

  void _createJsonAssets(Directory targetDir, CliUi ui, bool force) {
    final langsDir = Directory(_join(targetDir.path, 'assets/langs'));
    if (!langsDir.existsSync()) {
      langsDir.createSync(recursive: true);
    }

    _writeFile(
      _join(targetDir.path, 'assets/langs/en.json'),
      LocalizationTemplates.enJson(),
      targetDir,
      ui,
      force,
    );
    _writeFile(
      _join(targetDir.path, 'assets/langs/bn.json'),
      LocalizationTemplates.bnJson(),
      targetDir,
      ui,
      force,
    );
  }

  void _createDartFiles(
    Directory targetDir,
    StateManagement state,
    CliUi ui,
    bool force,
  ) {
    final locDir = Directory(
      _join(targetDir.path, 'lib/core/localization'),
    );
    if (!locDir.existsSync()) {
      locDir.createSync(recursive: true);
    }

    _writeFile(
      _join(targetDir.path, 'lib/core/localization/app_strings.dart'),
      LocalizationTemplates.appStrings(state),
      targetDir,
      ui,
      force,
    );

    if (state == StateManagement.getx) {
      _writeFile(
        _join(
          targetDir.path,
          'lib/core/localization/getx_localization.dart',
        ),
        LocalizationTemplates.getxLocalization(),
        targetDir,
        ui,
        force,
      );
    }
  }

  void _writeFile(
    String fullPath,
    String content,
    Directory targetDir,
    CliUi ui,
    bool force,
  ) {
    final file = File(fullPath);
    final displayPath = _relative(targetDir.path, fullPath);
    if (file.existsSync() && !force) {
      ui.itemSkipped(displayPath);
      return;
    }
    file.writeAsStringSync(content);
    ui.itemCreated(displayPath);
  }

  void _updatePubspec(Directory targetDir, CliUi ui) {
    final pubspecFile = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      ui.warn('pubspec.yaml not found; skipping pubspec update.');
      return;
    }

    final original = pubspecFile.readAsStringSync();
    var content = original;

    if (!RegExp(r'^\s*intl\s*:', multiLine: true).hasMatch(content)) {
      content = _addDependency(content, 'intl', 'any');
    }
    if (!content.contains('flutter_localizations')) {
      content = _addSdkDep(content, 'flutter_localizations');
    }
    content = _ensureLangsAsset(content);

    if (content != original) {
      pubspecFile.writeAsStringSync(content);
      ui.itemUpdated('pubspec.yaml');
    }
  }

  // ─── Remove ──────────────────────────────────────────────────────────────

  Future<int> _runRemove(ArgResults cmd) async {
    final ui = CliUi(console);
    final targetDir = Directory(cmd['path'] as String);
    final force = cmd['force'] as bool;

    if (!targetDir.existsSync()) {
      ui.error('Project directory does not exist: ${targetDir.path}');
      return ExitCode.software.code;
    }

    ui.section('Remove Localization');
    ui.step('PATH    ', targetDir.path);

    final locDir = Directory(_join(targetDir.path, 'lib/core/localization'));
    final langsDir = Directory(_join(targetDir.path, 'assets/langs'));

    if (!locDir.existsSync() && !langsDir.existsSync()) {
      ui.info('No localization found in this project.');
      return ExitCode.success.code;
    }

    if (!force) {
      final answer = console.prompt(
        'Remove all localization files and asset entries? [y/N]: ',
      );
      if ((answer ?? '').trim().toLowerCase() != 'y') {
        ui.info('Cancelled.');
        return ExitCode.success.code;
      }
    }

    if (locDir.existsSync()) {
      locDir.deleteSync(recursive: true);
      ui.raw(
        '    ${console.color('-', ConsoleColor.red)} lib/core/localization/',
      );
    }

    if (langsDir.existsSync()) {
      langsDir.deleteSync(recursive: true);
      ui.raw(
        '    ${console.color('-', ConsoleColor.red)} assets/langs/',
      );
    }

    _removeLangsAsset(targetDir, ui);

    ui.success('Localization removed.');
    return ExitCode.success.code;
  }

  void _removeLangsAsset(Directory targetDir, CliUi ui) {
    final pubspecFile = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    final original = pubspecFile.readAsStringSync();
    final lines = original.split('\n');
    final filtered = lines.where((line) {
      final t = line.trim();
      return t != '- assets/langs/' && t != '-assets/langs/';
    }).toList();

    if (filtered.length < lines.length) {
      pubspecFile.writeAsStringSync(filtered.join('\n'));
      ui.itemUpdated('pubspec.yaml');
    }
  }

  // ─── pubspec helpers ──────────────────────────────────────────────────────

  String _addDependency(String content, String name, String version) {
    final lines = content.split('\n');
    final depIdx = lines.indexWhere((l) => l.trim() == 'dependencies:');
    if (depIdx == -1) return content;
    if (lines.any((l) => l.trimLeft().startsWith('$name:'))) return content;
    final indent = _detectIndent(lines, depIdx);
    lines.insert(depIdx + 1, '$indent$name: $version');
    return lines.join('\n');
  }

  String _addSdkDep(String content, String name) {
    final lines = content.split('\n');
    final depIdx = lines.indexWhere((l) => l.trim() == 'dependencies:');
    if (depIdx == -1) return content;
    if (lines.any((l) => l.trimLeft().startsWith('$name:'))) return content;
    final indent = _detectIndent(lines, depIdx);
    lines.insert(depIdx + 1, '$indent$name:');
    lines.insert(depIdx + 2, '$indent  sdk: flutter');
    return lines.join('\n');
  }

  String _ensureLangsAsset(String content) {
    const path = 'assets/langs/';
    if (content.contains(path)) return content;

    final lines = content.split('\n');

    // Try to append inside an existing assets: list
    var assetsIdx = -1;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].trimLeft().startsWith('assets:')) {
        assetsIdx = i;
        break;
      }
    }

    if (assetsIdx != -1) {
      var insertAfter = assetsIdx + 1;
      for (var i = assetsIdx + 1; i < lines.length; i++) {
        final l = lines[i];
        if (l.isNotEmpty && !l.startsWith(' ')) break;
        if (l.trimLeft().startsWith('-')) insertAfter = i + 1;
      }
      lines.insert(insertAfter, '    - $path');
      return lines.join('\n');
    }

    // No assets: section — add one under flutter:
    final flutterIdx = lines.indexWhere(
      (l) => l.trim() == 'flutter:' && !l.startsWith(' '),
    );
    if (flutterIdx == -1) return content;
    lines.insertAll(flutterIdx + 1, ['  assets:', '    - $path']);
    return lines.join('\n');
  }

  String _detectIndent(List<String> lines, int sectionIdx) {
    for (var i = sectionIdx + 1; i < lines.length; i++) {
      final l = lines[i];
      if (l.trim().isEmpty) continue;
      final leading = l.length - l.trimLeft().length;
      if (leading > 0) return l.substring(0, leading);
      break;
    }
    return '  ';
  }

  // ─── path helpers ─────────────────────────────────────────────────────────

  String _join(String base, String relative) {
    final norm = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$norm';
  }

  String _relative(String base, String full) {
    final b = base.endsWith(Platform.pathSeparator) ? base : '$base${Platform.pathSeparator}';
    return full.startsWith(b) ? full.substring(b.length) : full;
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle localization add [options]     Add localization to the project',
      '  arcle localization remove [options]  Remove localization from the project',
      '',
      'Options (add):',
      '  -s, --state    bloc | getx | riverpod',
      '  -p, --path     Project directory (default: current)',
      '  -f, --force    Overwrite existing files',
      '',
      'Options (remove):',
      '  -p, --path     Project directory (default: current)',
      '  -f, --force    Skip confirmation prompt',
      '',
      'Aliases: l10n',
    ].join('\n');
  }
}
