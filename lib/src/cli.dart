import 'package:args/args.dart';
import 'package:io/io.dart';

import 'commands/build_command.dart';
import 'commands/create_command.dart';
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
    };

    final shortcutReplacement = shortcutAliases[args.first];
    if (shortcutReplacement != null) {
      return [...shortcutReplacement, ...args.skip(1)];
    }

    final commandReplacement = commandAliases[args.first];
    if (commandReplacement != null) {
      return [commandReplacement, ...args.skip(1)];
    }

    return args;
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
    return parser;
  }

  List<String> _commandNames() {
    return [
      'create',
      'new',
      'init',
      'setup',
      'feature',
      'feat',
      'doctor',
      'health',
      'auto-gen-di',
      'auto_gen_di',
      'autodi',
      'gen-di',
      'di',
      'build',
      'b',
      'br',
      'bd',
      'gen-doc',
      'docs',
      'verify',
      'ver',
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
      '    arcle create my_app --state BLoc/Getx/Riverpod',
      '    arcle feature payments --state BLoc/Getx/Riverpod',
      '    arcle build apk --release            # Build release APK',
      '    arcle new my_app                     # Shortcut alias for create',
      '    arcle feat payments                  # Shortcut alias for feature',
      '    arcle br                             # Shortcut for build apk --release',
      '    arcle bd                             # Shortcut for build apk --debug',
      '',
      '  \ud83d\udca1 TIP: Use --state BLoc/Getx/Riverpod in CI/CD for explicit configuration',
      '',
    ].join('\n');
  }
}
