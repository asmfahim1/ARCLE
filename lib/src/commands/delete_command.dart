import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../templates/core/localization_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

/// Handles `arcle delete locale <code>` and `arcle del locale <code>`.
class DeleteCommand {
  DeleteCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final localeParser = ArgParser()
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
        help: 'Skip confirmation prompt',
        negatable: false,
      );

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('locale', localeParser)
      ..addCommand('loc', localeParser); // short alias
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true || cmd.command == null) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    switch (cmd.command!.name) {
      case 'locale':
      case 'loc':
        return _runDeleteLocale(cmd.command!);
      default:
        ui.error('Unknown delete subcommand: ${cmd.command!.name}');
        console.line(_usage());
        return ExitCode.usage.code;
    }
  }

  // ─── Delete locale ────────────────────────────────────────────────────────

  Future<int> _runDeleteLocale(ArgResults cmd) async {
    final ui = CliUi(console);
    final langCode = cmd.rest.isNotEmpty
        ? cmd.rest.first.trim().toLowerCase()
        : null;

    if (langCode == null || langCode.isEmpty) {
      ui.error('Missing locale code.');
      ui.info('Usage: arcle delete locale <code>  (e.g. en, bn, my)');
      return ExitCode.usage.code;
    }

    if (!RegExp(r'^[a-z]{2,3}$').hasMatch(langCode)) {
      ui.error('Invalid locale code "$langCode".');
      return ExitCode.usage.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    if (!targetDir.existsSync()) {
      ui.error('Project directory does not exist: ${targetDir.path}');
      return ExitCode.software.code;
    }

    final config = ArcleConfig.readFrom(targetDir);
    final stateInput = cmd['state'] as String?;
    final force = cmd['force'] as bool;

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
      ui.error('No state management selected. Use --state bloc|getx|riverpod.');
      return ExitCode.usage.code;
    }

    final country = LocalizationTemplates.countryCode(langCode);
    final jsonFile = File(_join(targetDir.path, 'assets/langs/$langCode.json'));
    final appStringsFile = File(
      _join(targetDir.path, 'lib/core/localization/app_strings.dart'),
    );

    if (!jsonFile.existsSync() && !appStringsFile.existsSync()) {
      ui.info('Locale "$langCode" is not present in this project.');
      return ExitCode.success.code;
    }

    ui.section('Delete Locale');
    ui.step('PATH    ', targetDir.path);
    ui.step('LOCALE  ', '$langCode  →  ${langCode}_$country');

    if (!force) {
      final answer = console.prompt(
        'Remove locale "$langCode" from the project? [y/N]: ',
      );
      if ((answer ?? '').trim().toLowerCase() != 'y') {
        ui.info('Cancelled.');
        return ExitCode.success.code;
      }
    }

    // 1. Remove JSON file
    if (jsonFile.existsSync()) {
      jsonFile.deleteSync();
      ui.raw(
        '    ${console.color('-', ConsoleColor.red)} assets/langs/$langCode.json',
      );
    } else {
      ui.warn('assets/langs/$langCode.json not found — skipped.');
    }

    // 2. Update app_strings.dart
    if (appStringsFile.existsSync()) {
      var content = appStringsFile.readAsStringSync();
      if (content.contains("Locale('$langCode',")) {
        content = _removeSupportedLocale(content, langCode);
        if (state != StateManagement.getx) {
          content = _updateIsSupported(content, langCode, add: false);
        }
        appStringsFile.writeAsStringSync(content);
        ui.itemUpdated('lib/core/localization/app_strings.dart');
      }
    }

    // 3. Update getx_localization.dart
    if (state == StateManagement.getx) {
      final getxFile = File(
        _join(
          targetDir.path,
          'lib/core/localization/getx_localization.dart',
        ),
      );
      if (getxFile.existsSync()) {
        final original = getxFile.readAsStringSync();
        final updated = _removeGetxLocaleSection(original, langCode, country);
        if (updated != original) {
          getxFile.writeAsStringSync(updated);
          ui.itemUpdated('lib/core/localization/getx_localization.dart');
        }
      }
    }

    // 4. If assets/langs/ is now empty, remove pubspec entry
    final langsDir = Directory(_join(targetDir.path, 'assets/langs'));
    if (langsDir.existsSync()) {
      final remaining =
          langsDir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
      if (remaining.isEmpty) {
        _removeLangsAsset(targetDir, ui);
      }
    }

    ui.success('Locale "$langCode" removed.');
    return ExitCode.success.code;
  }

  // ─── app_strings.dart modifiers ───────────────────────────────────────────

  String _removeSupportedLocale(String content, String langCode) {
    final lines = content.split('\n');
    return lines
        .where((l) => !l.contains("Locale('$langCode',"))
        .join('\n');
  }

  String _updateIsSupported(
    String content,
    String langCode, {
    required bool add,
  }) {
    final lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].contains('.contains(locale.languageCode)')) continue;

      final listMatch = RegExp(r'\[([^\]]*)\]').firstMatch(lines[i]);
      if (listMatch == null) continue;

      final codes = listMatch
          .group(1)!
          .split(',')
          .map((s) => s.trim().replaceAll("'", ''))
          .where((s) => s.isNotEmpty)
          .toList();

      if (add && !codes.contains(langCode)) {
        codes.add(langCode);
      } else if (!add) {
        codes.remove(langCode);
      }

      final newList = codes.map((c) => "'$c'").join(', ');
      lines[i] = lines[i].replaceFirst(listMatch.group(0)!, '[$newList]');
      break;
    }
    return lines.join('\n');
  }

  // ─── getx_localization.dart modifier ─────────────────────────────────────

  /// Removes the `'<lang>_<COUNTRY>': { ... },` section from getx_localization.
  String _removeGetxLocaleSection(
    String content,
    String langCode,
    String country,
  ) {
    final localeKey = '${langCode}_$country';
    final lines = content.split('\n');
    final result = <String>[];
    var inSection = false;
    var braceCount = 0;

    for (final line in lines) {
      final trimmed = line.trim();

      if (!inSection) {
        if (trimmed.startsWith("'$localeKey':")) {
          inSection = true;
          braceCount = '{'.allMatches(trimmed).length -
              '}'.allMatches(trimmed).length;
          continue; // skip this line (don't add to result)
        }
        result.add(line);
      } else {
        braceCount += '{'.allMatches(trimmed).length;
        braceCount -= '}'.allMatches(trimmed).length;
        if (braceCount <= 0) {
          inSection = false; // skip closing line too
        }
        // don't add to result while inside the section
      }
    }

    return result.join('\n');
  }

  // ─── pubspec helper ───────────────────────────────────────────────────────

  void _removeLangsAsset(Directory targetDir, CliUi ui) {
    final pubspecFile = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    final original = pubspecFile.readAsStringSync();
    final lines = original.split('\n');
    final filtered = lines.where((l) {
      final t = l.trim();
      return t != '- assets/langs/' && t != '-assets/langs/';
    }).toList();

    if (filtered.length < lines.length) {
      pubspecFile.writeAsStringSync(filtered.join('\n'));
      ui.itemUpdated('pubspec.yaml (removed assets/langs/ entry)');
    }
  }

  // ─── path helpers ─────────────────────────────────────────────────────────

  String _join(String base, String relative) {
    final norm = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$norm';
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle delete locale <code> [options]',
      '  arcle delete loc <code>    [options]   (short form)',
      '  arcle delete loc --<code>  [options]   (flag short form)',
      '  arcle del    locale <code> [options]   (del alias)',
      '',
      'Options:',
      '  -s, --state   bloc | getx | riverpod',
      '  -p, --path    Project directory (default: current)',
      '  -f, --force   Skip confirmation prompt',
      '',
      'Examples:',
      '  arcle delete locale en',
      '  arcle del locale bn',
      '  arcle del loc --my',
    ].join('\n');
  }
}
