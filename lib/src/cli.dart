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

    late ArgResults results;
    try {
      results = parser.parse(args);
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
      'init',
      'feature',
      'doctor',
      'auto-gen-di',
      'auto_gen_di',
      'gen-di',
      'build',
      'gen-doc',
      'verify',
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
      '    \ud83d\udee0\ufe0f  init             Scaffold clean architecture in existing project',
      '    \u2728  feature <name>   Generate a feature (data/domain/presentation)',
      '    \ud83e\ude7a  doctor           Validate project health and safe repairs',
      '    \ud83d\udd04  auto-gen-di      Regenerate DI + run build_runner',
      '    \ud83d\udd27  gen-di           Regenerate core DI files only',
      '    \ud83d\udd28  build            Build APK (debug or release)',
      '    \ud83d\udcda  gen-doc          Generate architecture documentation',
      '    \u2705  verify           Run analyze/test/codegen verification',
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
      '    arcle build --mode release           # Build release APK',
      '',
      '  \ud83d\udca1 TIP: Use --state BLoc/Getx/Riverpod in CI/CD for explicit configuration',
      '',
    ].join('\n');
  }
}
