import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../templates/core/localization_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

/// Handles `arcle add locale <code>` and `arcle add loc <code>`.
///
/// On first call it creates the full localization infrastructure
/// (dart files + assets/langs/ directory + pubspec update).
/// On subsequent calls it adds the new locale to the existing files.
class AddCommand {
  AddCommand(this.console);

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
        help: 'Overwrite existing localization files',
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
        return _runAddLocale(cmd.command!);
      default:
        ui.error('Unknown add subcommand: ${cmd.command!.name}');
        console.line(_usage());
        return ExitCode.usage.code;
    }
  }

  // ─── Add locale ──────────────────────────────────────────────────────────

  Future<int> _runAddLocale(ArgResults cmd) async {
    final ui = CliUi(console);
    final langCode = cmd.rest.isNotEmpty
        ? cmd.rest.first.trim().toLowerCase()
        : null;

    if (langCode == null || langCode.isEmpty) {
      ui.error('Missing locale code.');
      ui.info('Usage: arcle add locale <code>  (e.g. en, bn, fr, my)');
      return ExitCode.usage.code;
    }

    if (!RegExp(r'^[a-z]{2,3}$').hasMatch(langCode)) {
      ui.error(
        'Invalid locale code "$langCode". Use an ISO 639-1 two- or three-letter code.',
      );
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

    ui.section('Add Locale');
    ui.step('PATH    ', targetDir.path);
    ui.step('LOCALE  ', '$langCode  →  ${langCode}_$country');
    ui.step('STATE   ', state.label);

    final appStringsPath = _join(
      targetDir.path,
      'lib/core/localization/app_strings.dart',
    );
    final isFirstLocale = !File(appStringsPath).existsSync();

    if (isFirstLocale) {
      _createInfrastructure(
        targetDir: targetDir,
        state: state,
        langCode: langCode,
        country: country,
        force: force,
        ui: ui,
      );
    } else {
      _addLocaleToExisting(
        targetDir: targetDir,
        state: state,
        langCode: langCode,
        country: country,
        ui: ui,
      );
    }

    _createLocaleJson(targetDir, langCode, force, ui);
    _ensurePubspec(targetDir, ui);

    ui.success('Locale "$langCode" added.');
    if (isFirstLocale) {
      ui.info(
        'Register AppLocalizations.delegate in your MaterialApp localizationsDelegates.',
      );
    }
    return ExitCode.success.code;
  }

  // ─── Infrastructure creation (first locale) ───────────────────────────────

  void _createInfrastructure({
    required Directory targetDir,
    required StateManagement state,
    required String langCode,
    required String country,
    required bool force,
    required CliUi ui,
  }) {
    final locDir = Directory(
      _join(targetDir.path, 'lib/core/localization'),
    );
    if (!locDir.existsSync()) locDir.createSync(recursive: true);

    _writeFile(
      _join(targetDir.path, 'lib/core/localization/app_strings.dart'),
      LocalizationTemplates.initialAppStrings(state, langCode, country),
      targetDir,
      force,
      ui,
    );

    if (state == StateManagement.getx) {
      _writeFile(
        _join(
          targetDir.path,
          'lib/core/localization/getx_localization.dart',
        ),
        LocalizationTemplates.initialGetxLocalization(langCode, country),
        targetDir,
        force,
        ui,
      );
    }
  }

  // ─── Add locale to existing infrastructure ────────────────────────────────

  void _addLocaleToExisting({
    required Directory targetDir,
    required StateManagement state,
    required String langCode,
    required String country,
    required CliUi ui,
  }) {
    final appStringsFile = File(
      _join(targetDir.path, 'lib/core/localization/app_strings.dart'),
    );

    if (appStringsFile.existsSync()) {
      final original = appStringsFile.readAsStringSync();

      if (original.contains("Locale('$langCode',")) {
        ui.itemSkipped('lib/core/localization/app_strings.dart ($langCode already listed)');
      } else {
        var updated = _insertSupportedLocale(original, langCode, country);
        if (state != StateManagement.getx) {
          updated = _updateIsSupported(updated, langCode, add: true);
        }
        appStringsFile.writeAsStringSync(updated);
        ui.itemUpdated('lib/core/localization/app_strings.dart');
      }
    }

    if (state == StateManagement.getx) {
      final getxFile = File(
        _join(
          targetDir.path,
          'lib/core/localization/getx_localization.dart',
        ),
      );
      if (getxFile.existsSync()) {
        final localeKey = '${langCode}_$country';
        final original = getxFile.readAsStringSync();
        if (original.contains("'$localeKey':")) {
          ui.itemSkipped(
            'lib/core/localization/getx_localization.dart ($localeKey already there)',
          );
        } else {
          getxFile.writeAsStringSync(
            _addGetxLocaleSection(original, langCode, country),
          );
          ui.itemUpdated('lib/core/localization/getx_localization.dart');
        }
      }
    }
  }

  // ─── JSON file ────────────────────────────────────────────────────────────

  void _createLocaleJson(
    Directory targetDir,
    String langCode,
    bool force,
    CliUi ui,
  ) {
    final langsDir = Directory(_join(targetDir.path, 'assets/langs'));
    if (!langsDir.existsSync()) langsDir.createSync(recursive: true);

    _writeFile(
      _join(targetDir.path, 'assets/langs/$langCode.json'),
      LocalizationTemplates.localeJson(langCode),
      targetDir,
      force,
      ui,
    );
  }

  // ─── pubspec ──────────────────────────────────────────────────────────────

  void _ensurePubspec(Directory targetDir, CliUi ui) {
    final pubspecFile = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) return;

    final original = pubspecFile.readAsStringSync();
    var content = original;

    if (!RegExp(r'^\s*intl\s*:', multiLine: true).hasMatch(content)) {
      content = _addDep(content, 'intl', 'any');
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

  // ─── app_strings.dart modifiers ───────────────────────────────────────────

  String _insertSupportedLocale(
    String content,
    String langCode,
    String country,
  ) {
    final lines = content.split('\n');
    var inSupportedLocales = false;
    var insertBefore = -1;

    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('supportedLocales')) inSupportedLocales = true;
      if (inSupportedLocales && lines[i].trim() == '];') {
        insertBefore = i;
        break;
      }
    }

    if (insertBefore == -1) return content;
    lines.insert(insertBefore, "    Locale('$langCode', '$country'),");
    return lines.join('\n');
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

  // ─── getx_localization.dart modifiers ────────────────────────────────────

  String _addGetxLocaleSection(
    String content,
    String langCode,
    String country,
  ) {
    // Insert the new section before the closing `      };`
    final lines = content.split('\n');
    var insertBefore = -1;
    for (var i = lines.length - 1; i >= 0; i--) {
      if (lines[i].trim() == '};') {
        insertBefore = i;
        break;
      }
    }
    if (insertBefore == -1) return content;

    final section = [
      "        '${langCode}_$country': {",
      "          'welcome': 'Welcome',",
      "          'login_title': 'Login',",
      "          'login_hint': 'Use your demo credentials to continue.',",
      "          'email': 'Email',",
      "          'password': 'Password',",
      "          'login': 'Login',",
      "          'settings': 'Settings',",
      "          'user_list': 'User List',",
      "          'retry': 'Retry',",
      "          'theme': 'Theme',",
      "          'dark_mode': 'Dark mode',",
      "          'language': 'Language',",
      "          // arcle:keys_$langCode",
      "        },",
    ];

    lines.insertAll(insertBefore, section);
    return lines.join('\n');
  }

  // ─── pubspec helpers ──────────────────────────────────────────────────────

  String _addDep(String content, String name, String version) {
    final lines = content.split('\n');
    final idx = lines.indexWhere((l) => l.trim() == 'dependencies:');
    if (idx == -1) return content;
    if (lines.any((l) => l.trimLeft().startsWith('$name:'))) return content;
    final indent = _detectIndent(lines, idx);
    lines.insert(idx + 1, '$indent$name: $version');
    return lines.join('\n');
  }

  String _addSdkDep(String content, String name) {
    final lines = content.split('\n');
    final idx = lines.indexWhere((l) => l.trim() == 'dependencies:');
    if (idx == -1) return content;
    if (lines.any((l) => l.trimLeft().startsWith('$name:'))) return content;
    final indent = _detectIndent(lines, idx);
    lines.insert(idx + 1, '$indent$name:');
    lines.insert(idx + 2, '$indent  sdk: flutter');
    return lines.join('\n');
  }

  String _ensureLangsAsset(String content) {
    const path = 'assets/langs/';
    if (content.contains(path)) return content;
    final lines = content.split('\n');

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
        if (lines[i].isNotEmpty && !lines[i].startsWith(' ')) break;
        if (lines[i].trimLeft().startsWith('-')) insertAfter = i + 1;
      }
      lines.insert(insertAfter, '    - $path');
      return lines.join('\n');
    }

    final flutterIdx = lines.indexWhere(
      (l) => l.trim() == 'flutter:' && !l.startsWith(' '),
    );
    if (flutterIdx == -1) return content;
    lines.insertAll(flutterIdx + 1, ['  assets:', '    - $path']);
    return lines.join('\n');
  }

  String _detectIndent(List<String> lines, int sectionIdx) {
    for (var i = sectionIdx + 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      final leading = lines[i].length - lines[i].trimLeft().length;
      if (leading > 0) return lines[i].substring(0, leading);
      break;
    }
    return '  ';
  }

  // ─── file helper ─────────────────────────────────────────────────────────

  void _writeFile(
    String fullPath,
    String content,
    Directory targetDir,
    bool force,
    CliUi ui,
  ) {
    final file = File(fullPath);
    final display = _relative(targetDir.path, fullPath);
    if (file.existsSync() && !force) {
      ui.itemSkipped(display);
      return;
    }
    file.writeAsStringSync(content);
    ui.itemCreated(display);
  }

  String _join(String base, String relative) {
    final norm = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$norm';
  }

  String _relative(String base, String full) {
    final b = base.endsWith(Platform.pathSeparator)
        ? base
        : '$base${Platform.pathSeparator}';
    return full.startsWith(b) ? full.substring(b.length) : full;
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle add locale <code> [options]',
      '  arcle add loc <code>    [options]   (short form)',
      '  arcle add loc --<code>  [options]   (flag short form)',
      '',
      'Options:',
      '  -s, --state   bloc | getx | riverpod',
      '  -p, --path    Project directory (default: current)',
      '  -f, --force   Overwrite existing files',
      '',
      'Examples:',
      '  arcle add locale en',
      '  arcle add locale bn',
      '  arcle add locale my               # Myanmar/Burmese',
      '  arcle add loc --fr                # French (flag short form)',
    ].join('\n');
  }
}
