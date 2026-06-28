import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../templates/ai/agent_templates.dart';
import '../templates/ai/claude_templates.dart';
import '../templates/ai/codex_templates.dart';
import '../templates/ai/gemini_templates.dart';
import '../templates/scripts/scripts_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/interactive_menu.dart';
import '../utils/state_picker.dart';

class ConfigureAiCommand {
  ConfigureAiCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to the Flutter project (defaults to current directory)',
        defaultsTo: Directory.current.path,
      )
      ..addFlag(
        'force',
        abbr: 'f',
        help: 'Overwrite existing AI config files',
        negatable: false,
      );
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);

    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    final force = cmd['force'] as bool;

    final pubspec =
        File('${targetDir.path}${Platform.pathSeparator}pubspec.yaml');
    if (!pubspec.existsSync()) {
      ui.error('No pubspec.yaml found. Run from a Flutter project directory.');
      ui.info('Usage: arcle configure-ai [--path <project_dir>]');
      return ExitCode.usage.code;
    }

    ui.section('AI Agent Configuration');

    final projectName = _readProjectName(pubspec);

    final config = ArcleConfig.readFrom(targetDir);
    var state = config?.state;
    if (state != null) {
      ui.info('Detected state management: ${state.label} (from arcle.yaml)');
    } else {
      ui.info('No arcle.yaml found. Please select your state management:');
      state = StatePicker(console).resolve(null, interactive: true);
      if (state == null) {
        ui.error('No state management selected. Aborting.');
        return ExitCode.usage.code;
      }
    }

    final aiDir =
        Directory('${targetDir.path}${Platform.pathSeparator}.ai');
    if (aiDir.existsSync() && !force) {
      ui.warn('.ai/ already exists. Use --force to overwrite.');
      console.line('');
    }

    console.line('');
    final agentIndex = InteractiveMenu.select(
      [
        'Claude Code   (.claude/ + .ai/)',
        'OpenAI Codex  (.codex/ + .ai/)',
        'Google Gemini (.gemini/ + .ai/)',
        'All three agents',
        'Skip',
      ],
      prompt: 'Select an AI agent to configure:',
    );

    if (agentIndex == null || agentIndex == 4) {
      ui.info('AI configuration skipped.');
      return ExitCode.success.code;
    }

    ui.section('Writing AI Config Files');
    ui.step('PROJECT ', projectName);
    ui.step('STATE   ', state.label);

    final writeClaude = agentIndex == 0 || agentIndex == 3;
    final writeCodex = agentIndex == 1 || agentIndex == 3;
    final writeGemini = agentIndex == 2 || agentIndex == 3;

    final files = <String, String>{
      '.ai/settings.yaml': AgentTemplates.settingsYaml(state),
      '.ai/project-context.md':
          AgentTemplates.projectContext(projectName, state),
      '.ai/architecture-rules.md': AgentTemplates.architectureRules(state),
      '.ai/coding-rules.md': AgentTemplates.codingRules(state),
      '.ai/security-rules.md': AgentTemplates.securityRules(),
      '.ai/permissions.yaml': AgentTemplates.permissionsYaml(),
      'scripts/setup.sh': ScriptsTemplates.setupSh(),
      'scripts/setup.ps1': ScriptsTemplates.setupPs1(),
      'scripts/doctor.sh': ScriptsTemplates.doctorSh(),
      'scripts/doctor.ps1': ScriptsTemplates.doctorPs1(),
    };

    if (writeClaude) {
      files['.claude/CLAUDE.md'] =
          ClaudeTemplates.claudeMd(projectName, state);
      files['.claude/settings.json'] = ClaudeTemplates.claudeSettings();
    }
    if (writeCodex) {
      files['.codex/instructions.md'] =
          CodexTemplates.instructionsMd(projectName, state);
      files['.codex/settings.json'] = CodexTemplates.codexSettings(state);
    }
    if (writeGemini) {
      files['.gemini/GEMINI.md'] =
          GeminiTemplates.geminiMd(projectName, state);
      files['.gemini/settings.json'] = GeminiTemplates.geminiSettings(state);
    }

    _writeFiles(targetDir, files, force: force, ui: ui);

    ui.success('AI configuration complete!');
    console.line('');
    ui.info('Run arcle review --ai to use AI-powered code review.');
    return ExitCode.success.code;
  }

  void _writeFiles(
    Directory targetDir,
    Map<String, String> files, {
    required bool force,
    required CliUi ui,
  }) {
    for (final entry in files.entries) {
      final relativePath =
          entry.key.replaceAll('/', Platform.pathSeparator);
      final file = File(
          '${targetDir.path}${Platform.pathSeparator}$relativePath');
      if (file.existsSync() && !force) {
        ui.itemSkipped(entry.key);
        continue;
      }
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
      ui.itemCreated(entry.key);
    }
  }

  String _readProjectName(File pubspec) {
    try {
      for (final line in pubspec.readAsLinesSync()) {
        final trimmed = line.trim();
        if (trimmed.startsWith('name:')) {
          return trimmed.substring(5).trim();
        }
      }
    } catch (_) {}
    return 'my_app';
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle configure-ai [options]',
      '  arcle agent-init   [options]',
      '',
      'Configure AI agent context files for this Flutter project.',
      'Writes .ai/, .claude/, .codex/, or .gemini/ based on your selection.',
      '',
      'Options:',
      parser().usage,
      '',
      'Examples:',
      '  arcle configure-ai              # interactive wizard (run from project root)',
      '  arcle configure-ai --force      # overwrite existing config',
      '  arcle configure-ai --path ./my_app',
    ].join('\n');
  }
}
