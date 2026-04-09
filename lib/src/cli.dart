import 'package:args/args.dart';
import 'package:io/io.dart';

import 'commands/add_command.dart';
import 'commands/build_command.dart';
import 'commands/create_command.dart';
import 'commands/delete_command.dart';
import 'commands/doctor_command.dart';
import 'commands/feature_command.dart';
import 'commands/auto_gen_di_command.dart';
import 'commands/gen_di_command.dart';
import 'commands/gen_doc_command.dart';
import 'commands/init_command.dart';
import 'commands/verify_command.dart';
import 'ui/cli_ui.dart';
import 'utils/console.dart';
import 'utils/command_suggester.dart';
import 'utils/first_run.dart';

class Cli {
  Future<int> run(List<String> args) async {
    final console = Console();
    final ui = CliUi(console);
    FirstRunTracker(ui).greetOnce();
    final parser = _buildParser();
    final normalizedArgs = _normalizeArgs(args);

    late ArgResults results;
    try {
      results = parser.parse(normalizedArgs);
    } on ArgParserException catch (e) {
      ui.error(e.message);
      console.line('');
      ui.info('Run ${console.bold('arcle --help')} for usage information.');
      return ExitCode.usage.code;
    }

    if (results['help'] == true || results.command == null) {
      console.line(_usage(parser));
      return ExitCode.success.code;
    }

    final cmd = results.command!;
    switch (cmd.name) {
      case 'create':
        return CreateCommand(console).run(cmd);
      case 'init':
        return InitCommand(console).run(cmd);
      case 'feature':
        return FeatureCommand(console).run(cmd);
      case 'doctor':
        return DoctorCommand(console).run(cmd);
      case 'auto-gen-di':
        return AutoGenDiCommand(console).run(cmd);
      case 'auto_gen_di':
        return AutoGenDiCommand(console).run(cmd);
      case 'gen-di':
        return GenDiCommand(console).run(cmd);
      case 'build':
        return BuildCommand(console).run(cmd);
      case 'gen-doc':
        return GenDocCommand(console).run(cmd);
      case 'verify':
        return VerifyCommand(console).run(cmd);
      case 'add':
        return AddCommand(console).run(cmd);
      case 'delete':
        return DeleteCommand(console).run(cmd);
      default:
        ui.error('Unknown command: ${cmd.name}');
        final suggestion =
            CommandSuggester().suggest(cmd.name!, _commandNames());
        if (suggestion != null) {
          ui.info('Did you mean: ${console.bold('arcle $suggestion')}?');
        }
        console.line('');
        ui.info(
            'Run ${console.bold('arcle --help')} to see available commands.');
        return ExitCode.usage.code;
    }
  }

  List<String> _normalizeArgs(List<String> args) {
    if (args.isEmpty) return args;

    final shortcutAliases = <String, List<String>>{
      '--b--r': ['build', 'apk', '--release'],
      '--b--d': ['build', 'apk', '--debug'],
      'br': ['build', 'apk', '--release'],
      'bd': ['build', 'apk', '--debug'],
    };
    final commandAliases = <String, String>{
      'new': 'create',
      'setup': 'init',
      'feat': 'feature',
      'health': 'doctor',
      'autodi': 'auto-gen-di',
      'di': 'gen-di',
      'b': 'build',
      'docs': 'gen-doc',
      'ver': 'verify',
      'del': 'delete',
    };

    final shortcutReplacement = shortcutAliases[args.first];
    if (shortcutReplacement != null) {
      return [...shortcutReplacement, ...args.skip(1)];
    }

    final commandReplacement = commandAliases[args.first];
    if (commandReplacement != null) {
      return _normalizeLocaleFlag(
        [commandReplacement, ...args.skip(1)],
      );
    }

    return _normalizeLocaleFlag(args);
  }

  /// Transforms `add loc --<code>` or `delete loc --<code>` by converting
  /// the `--<code>` locale flag into a plain positional arg and changing
  /// `loc` to the canonical `locale` subcommand name.
  ///
  /// Examples:
  ///   ['add', 'loc', '--my']        → ['add', 'locale', 'my']
  ///   ['delete', 'loc', '--fr']     → ['delete', 'locale', 'fr']
  ///   ['add', 'loc', '--force', '--my'] → ['add', 'locale', 'my', '--force']
  List<String> _normalizeLocaleFlag(List<String> args) {
    if (args.length < 2) return args;
    if (args[0] != 'add' && args[0] != 'delete') return args;
    if (args[1] != 'loc') return args;

    // Known option names that should NOT be treated as locale codes
    const knownOpts = {
      'force', 'f', 'path', 'p', 'state', 's', 'help', 'h',
      'interactive', 'i',
    };

    final newArgs = <String>[args[0], 'locale'];
    String? localeFound;

    for (final arg in args.skip(2)) {
      if (localeFound == null &&
          arg.startsWith('--') &&
          !arg.contains('=')) {
        final name = arg.substring(2);
        if (!knownOpts.contains(name) &&
            RegExp(r'^[a-zA-Z]{2,3}$').hasMatch(name)) {
          localeFound = name.toLowerCase();
          newArgs.add(localeFound); // positional locale code
          continue;
        }
      }
      newArgs.add(arg);
    }

    return newArgs;
  }

  ArgParser _buildParser() {
    final parser = ArgParser()..addFlag('help', abbr: 'h', negatable: false);
    parser.addCommand('create', CreateCommand.parser());
    parser.addCommand('init', InitCommand.parser());
    parser.addCommand('feature', FeatureCommand.parser());
    parser.addCommand('doctor', DoctorCommand.parser());
    parser.addCommand('auto-gen-di', AutoGenDiCommand.parser());
    parser.addCommand('auto_gen_di', AutoGenDiCommand.parser());
    parser.addCommand('gen-di', GenDiCommand.parser());
    parser.addCommand('build', BuildCommand.parser());
    parser.addCommand('gen-doc', GenDocCommand.parser());
    parser.addCommand('verify', VerifyCommand.parser());
    parser.addCommand('add', AddCommand.parser());
    parser.addCommand('delete', DeleteCommand.parser());
    return parser;
  }

  List<String> _commandNames() {
    return [
      'create', 'new',
      'init', 'setup',
      'feature', 'feat',
      'doctor', 'health',
      'auto-gen-di', 'auto_gen_di', 'autodi',
      'gen-di', 'di',
      'build', 'b', 'br', 'bd',
      'gen-doc', 'docs',
      'verify', 'ver',
      'add',
      'delete', 'del',
    ];
  }

  String _usage(ArgParser parser) {
    return [
      '',
      '  \u2554\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2557',
      '  \u2551   \ud83d\ude80  ARCLE - Flutter Clean Architecture CLI              \u2551',
      '  \u2551    Build production-ready Flutter apps with ease         \u2551',
      '  \u255a\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u2550\u255d',
      '',
      '  USAGE',
      '    arcle <command> [options]',
      '',
      '  COMMANDS',
      '    \ud83d\udce6  create <name>    Create a new Flutter project + clean architecture',
      '         alias: new',
      '    \ud83d\udee0\ufe0f  init             Scaffold clean architecture in existing project',
      '         alias: setup',
      '    \u2728  feature <name>   Generate a feature (data/domain/presentation)',
      '         alias: feat',
      '    \ud83e\ude7a  doctor           Validate project health and safe repairs',
      '         alias: health',
      '    \ud83d\udd04  auto-gen-di      Regenerate DI + run build_runner',
      '         alias: autodi',
      '    \ud83d\udd27  gen-di           Regenerate core DI files only',
      '         alias: di',
      '    \ud83d\udd28  build            Build APK (debug or release)',
      '         alias: b',
      '    \ud83d\udcda  gen-doc          Generate architecture documentation',
      '         alias: docs',
      '    \u2705  verify           Run analyze/test/codegen verification',
      '         alias: ver',
      '    \ud83c\udf10  add locale       Add a locale to the project',
      '         short: add loc --<code>',
      '    \ud83d\uddd1\ufe0f  delete locale    Remove a locale from the project',
      '         alias: del  |  short: del loc --<code>',
      '',
      '  STATE MANAGEMENT OPTIONS',
      '    🧱  BLoC       Business Logic Component, predictable state',
      '    ⚡  GetX       Lightweight, reactive, no boilerplate',
      '    🌊  Riverpod   Type-safe, no context needed',
      '',
      '  GLOBAL OPTIONS',
      parser.usage,
      '',
      '  EXAMPLES',
      '    arcle create my_app --state bloc',
      '    arcle feature payments --state bloc',
      '    arcle add locale en              # Add English locale',
      '    arcle add locale my              # Add Myanmar locale',
      '    arcle add loc --fr               # Short form (French)',
      '    arcle delete locale bn           # Remove Bengali locale',
      '    arcle del loc --my               # Short form remove',
      '    arcle build apk --release        # Build release APK',
      '    arcle br                         # Shortcut for build apk --release',
      '    arcle verify --full              # Run all structural checks',
      '',
      '  \ud83d\udca1 TIP: Use --state bloc|getx|riverpod in CI/CD for explicit configuration',
      '',
    ].join('\n');
  }
}
