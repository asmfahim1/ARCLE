import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';

/// Supported agent names
const _supportedAgents = ['claude', 'codex', 'gemini', 'custom'];

class AgentCommand {
  AgentCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final parser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false);

    // add subcommand
    final addParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('add', addParser);

    // remove subcommand
    final removeParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('remove', removeParser);

    // switch subcommand
    final switchParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('switch', switchParser);

    // list subcommand
    final listParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('list', listParser);

    // validate subcommand
    final validateParser = ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path);
    parser.addCommand('validate', validateParser);

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
      case 'add':
        return _runAdd(ui, sub);
      case 'remove':
        return _runRemove(ui, sub);
      case 'switch':
        return _runSwitch(ui, sub);
      case 'list':
        return _runList(ui, sub);
      case 'validate':
        return _runValidate(ui, sub);
      default:
        ui.error('Unknown agent subcommand: ${sub.name}');
        return ExitCode.usage.code;
    }
  }

  Future<int> _runAdd(CliUi ui, ArgResults cmd) async {
    if (cmd.rest.isEmpty) {
      ui.error('Missing agent name.');
      ui.info('Usage: arcle agent add <agent>');
      ui.info('Supported agents: ${_supportedAgents.join(', ')}');
      return ExitCode.usage.code;
    }

    final agentName = cmd.rest.first.toLowerCase();
    final targetDir = Directory(cmd['path'] as String);

    if (!_isValidAgent(agentName)) {
      ui.error('Unknown agent: $agentName');
      ui.info('Supported agents: ${_supportedAgents.join(', ')}');
      return ExitCode.usage.code;
    }

    ui.section('🤖 Adding AI Agent');
    ui.step('AGENT   ', agentName);

    _generateAgentConfig(ui, targetDir, agentName);

    ui.success('Agent "$agentName" configured.');
    ui.info(
      'Review the generated files in .'
      '${Platform.pathSeparator}${_agentDir(agentName)}'
      '${Platform.pathSeparator}',
    );
    return ExitCode.success.code;
  }

  Future<int> _runRemove(CliUi ui, ArgResults cmd) async {
    if (cmd.rest.isEmpty) {
      ui.error('Missing agent name.');
      ui.info('Usage: arcle agent remove <agent>');
      return ExitCode.usage.code;
    }

    final agentName = cmd.rest.first.toLowerCase();
    final targetDir = Directory(cmd['path'] as String);
    final agentDir = Directory(
      '${targetDir.path}${Platform.pathSeparator}.$agentName',
    );

    if (!agentDir.existsSync()) {
      ui.warn(
        'Agent directory .$agentName/ not found — nothing to remove.',
      );
      return ExitCode.success.code;
    }

    ui.section('🗑️  Removing AI Agent');
    ui.step('AGENT   ', agentName);
    agentDir.deleteSync(recursive: true);
    ui.success('Agent "$agentName" removed.');
    return ExitCode.success.code;
  }

  Future<int> _runSwitch(CliUi ui, ArgResults cmd) async {
    if (cmd.rest.isEmpty) {
      ui.error('Missing agent name.');
      ui.info('Usage: arcle agent switch <agent>');
      return ExitCode.usage.code;
    }

    final agentName = cmd.rest.first.toLowerCase();
    final targetDir = Directory(cmd['path'] as String);
    final settingsFile = File(
      '${targetDir.path}${Platform.pathSeparator}.ai'
      '${Platform.pathSeparator}settings.yaml',
    );

    if (!settingsFile.existsSync()) {
      ui.error('.ai/settings.yaml not found. Run "arcle ai init" first.');
      return ExitCode.software.code;
    }

    if (!_isValidAgent(agentName)) {
      ui.error('Unknown agent: $agentName');
      ui.info('Supported agents: ${_supportedAgents.join(', ')}');
      return ExitCode.usage.code;
    }

    ui.section('🔄 Switching Active Agent');
    ui.step('AGENT   ', agentName);

    var content = settingsFile.readAsStringSync();
    // Update or add active_agent field
    if (content.contains('active_agent:')) {
      content = content.replaceAll(
        RegExp(r'active_agent:.*'),
        'active_agent: $agentName',
      );
    } else {
      content += '\nactive_agent: $agentName\n';
    }
    settingsFile.writeAsStringSync(content);
    ui.success('Active agent set to "$agentName".');
    return ExitCode.success.code;
  }

  Future<int> _runList(CliUi ui, ArgResults cmd) async {
    final targetDir = Directory(cmd['path'] as String);
    ui.section('🤖 Configured AI Agents');

    var found = false;
    for (final agent in _supportedAgents) {
      final dir = Directory(
        '${targetDir.path}${Platform.pathSeparator}.$agent',
      );
      if (dir.existsSync()) {
        ui.success('$agent — configured (.$agent/)');
        found = true;
      }
    }

    if (!found) {
      ui.info('No agents configured yet.');
      ui.info('Run "arcle agent add <agent>" to add one.');
    }

    return ExitCode.success.code;
  }

  Future<int> _runValidate(CliUi ui, ArgResults cmd) async {
    final targetDir = Directory(cmd['path'] as String);
    ui.section('✅ Validating Agent Configurations');

    final aiDir = Directory(
      '${targetDir.path}${Platform.pathSeparator}.ai',
    );
    if (!aiDir.existsSync()) {
      ui.error('.ai/ directory not found. Run "arcle ai init" first.');
      return ExitCode.software.code;
    }

    var passed = true;
    final requiredAiFiles = [
      '.ai/settings.yaml',
      '.ai/project-context.md',
      '.ai/architecture-rules.md',
      '.ai/coding-rules.md',
      '.ai/security-rules.md',
      '.ai/permissions.yaml',
    ];

    for (final rel in requiredAiFiles) {
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
      ui.success('All agent configurations are valid.');
    } else {
      ui.error('Some configuration files are missing. Run "arcle ai init".');
      return ExitCode.software.code;
    }
    return ExitCode.success.code;
  }

  void _generateAgentConfig(
    CliUi ui,
    Directory targetDir,
    String agentName,
  ) {
    switch (agentName) {
      case 'claude':
        _writeFile(
          ui,
          targetDir,
          '.claude/CLAUDE.md',
          _claudePlaceholder(),
        );
        _writeFile(
          ui,
          targetDir,
          '.claude/settings.json',
          _claudeSettingsPlaceholder(),
        );
        break;
      case 'codex':
        _writeFile(
          ui,
          targetDir,
          '.codex/instructions.md',
          _codexPlaceholder(),
        );
        _writeFile(
          ui,
          targetDir,
          '.codex/settings.json',
          _codexSettingsPlaceholder(),
        );
        break;
      case 'gemini':
        _writeFile(
          ui,
          targetDir,
          '.gemini/GEMINI.md',
          _geminiPlaceholder(),
        );
        _writeFile(
          ui,
          targetDir,
          '.gemini/settings.json',
          _geminiSettingsPlaceholder(),
        );
        break;
      case 'custom':
        _writeFile(
          ui,
          targetDir,
          '.custom-agent/instructions.md',
          _customPlaceholder(),
        );
        _writeFile(
          ui,
          targetDir,
          '.custom-agent/settings.json',
          _customSettingsPlaceholder(),
        );
        break;
    }
  }

  void _writeFile(
    CliUi ui,
    Directory base,
    String relative,
    String content,
  ) {
    final norm = relative.replaceAll('/', Platform.pathSeparator);
    final file = File('${base.path}${Platform.pathSeparator}$norm');
    file.parent.createSync(recursive: true);
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      ui.itemCreated(relative);
    } else {
      ui.itemSkipped(relative);
    }
  }

  String _agentDir(String agent) => switch (agent) {
        'claude' => '.claude',
        'codex' => '.codex',
        'gemini' => '.gemini',
        _ => '.custom-agent',
      };

  bool _isValidAgent(String name) => _supportedAgents.contains(name);

  String _claudePlaceholder() => '''# CLAUDE.md
# This file was generated by arcle agent add claude.
# Customize it to provide Claude Code with project-specific instructions.
# See .ai/project-context.md and .ai/coding-rules.md for the full project rules.

Read .ai/project-context.md for architecture overview.
Read .ai/coding-rules.md for coding standards.
Read .ai/security-rules.md for security requirements.
''';

  String _claudeSettingsPlaceholder() => '''{
  "permissions": {
    "allow": [
      "Read(**)",
      "Edit(**)",
      "Write(**)",
      "Bash(flutter analyze)",
      "Bash(flutter pub get)",
      "Bash(dart format .)",
      "Bash(flutter test)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force)"
    ]
  }
}
''';

  String _codexPlaceholder() => '''# Codex Instructions
# Generated by arcle agent add codex.
# See .ai/ directory for full architecture and coding rules.

Read .ai/project-context.md, .ai/coding-rules.md, and .ai/security-rules.md.
''';

  String _codexSettingsPlaceholder() => '''{
  "model": "gpt-4o",
  "context_files": [
    ".ai/settings.yaml",
    ".ai/project-context.md",
    ".ai/architecture-rules.md",
    ".ai/coding-rules.md",
    ".ai/security-rules.md"
  ]
}
''';

  String _geminiPlaceholder() => '''# GEMINI.md
# Generated by arcle agent add gemini.
# See .ai/ directory for full architecture and coding rules.

Read .ai/project-context.md, .ai/coding-rules.md, and .ai/security-rules.md.
''';

  String _geminiSettingsPlaceholder() => '''{
  "model": "gemini-2.0-flash",
  "context_files": [
    ".ai/settings.yaml",
    ".ai/project-context.md",
    ".ai/coding-rules.md",
    ".ai/security-rules.md"
  ]
}
''';

  String _customPlaceholder() => '''# Custom Agent Instructions
# Generated by arcle agent add custom.
# Edit this file to provide your custom AI agent with project instructions.
# See .ai/ directory for architecture and coding rules.
''';

  String _customSettingsPlaceholder() => '''{
  "endpoint": "https://your-custom-agent-endpoint.com/v1",
  "model": "your-model-name",
  "context_files": [
    ".ai/settings.yaml",
    ".ai/project-context.md",
    ".ai/coding-rules.md",
    ".ai/security-rules.md"
  ]
}
''';

  String _usage() {
    return [
      'Usage:',
      '  arcle agent <subcommand> [options]',
      '',
      'Subcommands:',
      '  add <agent>      Add an AI agent (claude, codex, gemini, custom)',
      '  remove <agent>   Remove an AI agent configuration',
      '  switch <agent>   Set the active AI agent in .ai/settings.yaml',
      '  list             List all configured AI agents',
      '  validate         Validate agent configuration files',
      '',
      'Examples:',
      '  arcle agent add claude',
      '  arcle agent add gemini',
      '  arcle agent list',
      '  arcle agent switch claude',
      '  arcle agent validate',
    ].join('\n');
  }
}
