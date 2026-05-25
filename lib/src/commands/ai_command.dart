import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../templates/ai/agent_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class AiCommand {
  AiCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false);

    // init subcommand
    final initParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path)
      ..addOption(
        'state',
        abbr: 's',
        allowed: const ['bloc', 'getx', 'riverpod'],
        help: 'State management option (bloc, getx, riverpod)',
      )
      ..addFlag('force', abbr: 'f', negatable: false);
    parser.addCommand('init', initParser);

    // sync subcommand
    final syncParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('sync', syncParser);

    // validate subcommand
    final validateParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('validate', validateParser);

    // doctor subcommand
    final doctorParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('doctor', doctorParser);

    return parser;
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true || cmd.command == null) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    final sub = cmd.command!;
    switch (sub.name) {
      case 'init':
        return _runInit(ui, sub);
      case 'sync':
        return _runSync(ui, sub);
      case 'validate':
        return _runValidate(ui, sub);
      case 'doctor':
        return _runDoctor(ui, sub);
      default:
        ui.error('Unknown ai subcommand: ${sub.name}');
        return ExitCode.usage.code;
    }
  }

  Future<int> _runInit(CliUi ui, ArgResults cmd) async {
    final targetDir = Directory(cmd['path'] as String);
    final force = cmd['force'] as bool;

    // Resolve state
    final config = ArcleConfig.readFrom(targetDir);
    final stateInput = cmd['state'] as String?;

    StateManagement? state;
    if (stateInput != null && stateInput.trim().isNotEmpty) {
      state = StatePicker(console).resolve(stateInput, interactive: false);
    } else if (config?.state != null) {
      state = config!.state;
      ui.info('Detected state from arcle.yaml: ${state.label}');
    } else {
      state = StatePicker(console).resolve(null, interactive: true);
    }

    if (state == null) {
      ui.error('State management selection required.');
      return ExitCode.usage.code;
    }

    final projectName =
        targetDir.uri.pathSegments.where((s) => s.isNotEmpty).lastOrNull ??
            'my_app';

    ui.section('🤖 Initializing AI Configuration');
    ui.step('PROJECT ', projectName);
    ui.step('STATE   ', state.label);

    _writeAiFiles(ui, targetDir, projectName, state, force: force);

    ui.success('AI configuration initialized in .ai/');
    ui.info('Edit .ai/settings.yaml to customize AI behavior.');
    ui.info('Run "arcle agent add claude" to add Claude Code support.');
    return ExitCode.success.code;
  }

  Future<int> _runSync(CliUi ui, ArgResults cmd) async {
    final targetDir = Directory(cmd['path'] as String);
    final config = ArcleConfig.readFrom(targetDir);

    if (config == null) {
      ui.error(
        'arcle.yaml not found. Run "arcle init" or "arcle create" first.',
      );
      return ExitCode.software.code;
    }

    final aiSettingsFile = File(
      '${targetDir.path}${Platform.pathSeparator}.ai'
      '${Platform.pathSeparator}settings.yaml',
    );

    if (!aiSettingsFile.existsSync()) {
      ui.error('.ai/settings.yaml not found. Run "arcle ai init" first.');
      return ExitCode.software.code;
    }

    ui.section('🔄 Syncing AI Configuration');
    ui.step('STATE   ', config.state.label);

    // Update state_management.type in settings.yaml
    var content = aiSettingsFile.readAsStringSync();
    final statePattern = RegExp(r'type:\s*(bloc|getx|riverpod)');
    if (statePattern.hasMatch(content)) {
      content = content.replaceAll(
        statePattern,
        'type: ${config.state.id}',
      );
      aiSettingsFile.writeAsStringSync(content);
      ui.itemUpdated('.ai/settings.yaml');
    }

    ui.success('AI configuration synced from arcle.yaml.');
    return ExitCode.success.code;
  }

  Future<int> _runValidate(CliUi ui, ArgResults cmd) async {
    final targetDir = Directory(cmd['path'] as String);
    ui.section('✅ Validating AI Configuration');

    final requiredFiles = [
      '.ai/settings.yaml',
      '.ai/project-context.md',
      '.ai/architecture-rules.md',
      '.ai/coding-rules.md',
      '.ai/security-rules.md',
      '.ai/permissions.yaml',
    ];

    var passed = true;
    for (final rel in requiredFiles) {
      final norm = rel.replaceAll('/', Platform.pathSeparator);
      final file = File('${targetDir.path}${Platform.pathSeparator}$norm');
      if (file.existsSync()) {
        ui.success('$rel — OK');
      } else {
        passed = false;
        ui.warn('$rel — missing');
      }
    }

    if (passed) {
      ui.success('AI configuration is complete.');
    } else {
      ui.error('Some AI config files are missing. Run "arcle ai init".');
      return ExitCode.software.code;
    }
    return ExitCode.success.code;
  }

  Future<int> _runDoctor(CliUi ui, ArgResults cmd) async {
    final targetDir = Directory(cmd['path'] as String);
    ui.section('🏥 AI Configuration Doctor');

    var issues = 0;

    // Check arcle.yaml
    final config = ArcleConfig.readFrom(targetDir);
    if (config != null) {
      ui.success('arcle.yaml found (state: ${config.state.label})');
    } else {
      ui.warn('arcle.yaml not found — run "arcle init"');
      issues++;
    }

    // Check .ai/ dir
    final aiDir = Directory(
      '${targetDir.path}${Platform.pathSeparator}.ai',
    );
    if (aiDir.existsSync()) {
      ui.success('.ai/ directory found');
    } else {
      ui.error('.ai/ directory missing — run "arcle ai init"');
      issues++;
    }

    // Check agent directories
    for (final agent in ['claude', 'codex', 'gemini']) {
      final dir = Directory(
        '${targetDir.path}${Platform.pathSeparator}.$agent',
      );
      if (dir.existsSync()) {
        ui.success('.$agent/ agent configured');
      } else {
        ui.info(
          '.$agent/ not configured (optional) — run "arcle agent add $agent"',
        );
      }
    }

    if (issues == 0) {
      ui.success('AI doctor: no issues found.');
    } else {
      ui.error('AI doctor: $issues issue(s) found.');
      return ExitCode.software.code;
    }
    return ExitCode.success.code;
  }

  void _writeAiFiles(
    CliUi ui,
    Directory targetDir,
    String projectName,
    StateManagement state, {
    required bool force,
  }) {
    final aiFiles = {
      '.ai/settings.yaml': AgentTemplates.settingsYaml(state),
      '.ai/project-context.md': AgentTemplates.projectContext(
        projectName,
        state,
      ),
      '.ai/architecture-rules.md': AgentTemplates.architectureRules(state),
      '.ai/coding-rules.md': AgentTemplates.codingRules(state),
      '.ai/security-rules.md': AgentTemplates.securityRules(),
      '.ai/permissions.yaml': AgentTemplates.permissionsYaml(),
    };

    for (final entry in aiFiles.entries) {
      final norm = entry.key.replaceAll('/', Platform.pathSeparator);
      final file = File('${targetDir.path}${Platform.pathSeparator}$norm');
      file.parent.createSync(recursive: true);
      if (!file.existsSync() || force) {
        file.writeAsStringSync(entry.value);
        ui.itemCreated(entry.key);
      } else {
        ui.itemSkipped(entry.key);
      }
    }
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle ai <subcommand> [options]',
      '',
      'Subcommands:',
      '  init        Generate .ai/ configuration for the current project',
      '  sync        Sync .ai/settings.yaml from arcle.yaml',
      '  validate    Check all required .ai/ config files exist',
      '  doctor      Diagnose AI configuration health',
      '',
      'Examples:',
      '  arcle ai init',
      '  arcle ai init --state bloc',
      '  arcle ai sync',
      '  arcle ai validate',
      '  arcle ai doctor',
    ].join('\n');
  }
}
