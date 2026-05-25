import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../templates/ai/agent_templates.dart';
import '../templates/core/analysis_templates.dart';
import '../templates/core/dimensions_templates.dart';
import '../templates/scripts/scripts_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class UpgradeCommand {
  UpgradeCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addOption('path', abbr: 'p', defaultsTo: Directory.current.path)
      ..addOption(
        'state',
        abbr: 's',
        allowed: const ['bloc', 'getx', 'riverpod'],
        help: 'State management option (bloc, getx, riverpod)',
      )
      ..addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Overwrite existing files',
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

    ui.section('⬆️  Upgrading ARCLE Project to v2.0.0');
    ui.step('PROJECT ', projectName);
    ui.step('STATE   ', state.label);
    ui.step('PATH    ', targetDir.path);

    // Step 1: Update SDK constraint in pubspec.yaml
    _upgradeSdkConstraint(ui, targetDir);

    // Step 2: Update analysis_options.yaml
    _upgradeAnalysisOptions(ui, targetDir, force: force);

    // Step 3: Update dimensions.dart
    _upgradeDimensions(ui, targetDir, force: force);

    // Step 4: Generate .ai/ configuration
    _generateAiConfig(ui, targetDir, projectName, state, force: force);

    // Step 5: Generate scripts/
    _generateScripts(ui, targetDir, force: force);

    console.line('');
    ui.success('✅ Upgrade to v2.0.0 complete!');
    ui.info('Next steps:');
    ui.raw('  • Review .ai/settings.yaml and customize for your workflow');
    ui.raw('  • Run "arcle agent add claude" to add Claude Code support');
    ui.raw('  • Run "flutter pub get" to install any new dependencies');
    return ExitCode.success.code;
  }

  void _upgradeSdkConstraint(CliUi ui, Directory targetDir) {
    final pubspecFile = File(
      '${targetDir.path}${Platform.pathSeparator}pubspec.yaml',
    );
    if (!pubspecFile.existsSync()) {
      ui.warn('pubspec.yaml not found — skipping SDK constraint upgrade.');
      return;
    }

    final content = pubspecFile.readAsStringSync();
    final patterns = [
      RegExp(
        r'''sdk:\s*["']?>=?3\.\d+\.\d+\s*<?\s*\d+\.\d+\.\d+["']?''',
      ),
      RegExp(r'''sdk:\s*["']?\^3\.\d+\.\d+["']?'''),
    ];

    var updated = content;
    for (final pattern in patterns) {
      if (pattern.hasMatch(updated)) {
        updated = updated.replaceAll(pattern, 'sdk: ">=3.7.0 <4.0.0"');
        break;
      }
    }

    if (updated == content) {
      ui.info(
        'SDK constraint already up to date or not found in pubspec.yaml.',
      );
      return;
    }

    pubspecFile.writeAsStringSync(updated);
    ui.itemUpdated('pubspec.yaml (SDK constraint → >=3.7.0 <4.0.0)');
  }

  void _upgradeAnalysisOptions(
    CliUi ui,
    Directory targetDir, {
    required bool force,
  }) {
    final file = File(
      '${targetDir.path}${Platform.pathSeparator}analysis_options.yaml',
    );
    if (!file.existsSync() || force) {
      file.writeAsStringSync(AnalysisTemplates.analysisOptions());
      ui.itemUpdated('analysis_options.yaml');
    } else {
      ui.itemSkipped(
        'analysis_options.yaml (already exists — use --force to overwrite)',
      );
    }
  }

  void _upgradeDimensions(
    CliUi ui,
    Directory targetDir, {
    required bool force,
  }) {
    final file = File(
      '${targetDir.path}${Platform.pathSeparator}lib'
      '${Platform.pathSeparator}core'
      '${Platform.pathSeparator}utils'
      '${Platform.pathSeparator}dimensions.dart',
    );
    if (!file.existsSync() || force) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(DimensionsTemplates.dimensions());
      ui.itemUpdated('lib/core/utils/dimensions.dart');
    } else {
      ui.itemSkipped(
        'lib/core/utils/dimensions.dart (use --force to overwrite)',
      );
    }
  }

  void _generateAiConfig(
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

  void _generateScripts(
    CliUi ui,
    Directory targetDir, {
    required bool force,
  }) {
    final scripts = {
      'scripts/setup.sh': ScriptsTemplates.setupSh(),
      'scripts/setup.ps1': ScriptsTemplates.setupPs1(),
      'scripts/doctor.sh': ScriptsTemplates.doctorSh(),
      'scripts/doctor.ps1': ScriptsTemplates.doctorPs1(),
    };

    for (final entry in scripts.entries) {
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
      '  arcle upgrade [options]',
      '',
      'Upgrades an existing ARCLE project to v2.0.0.',
      '',
      'Actions performed:',
      '  • Updates pubspec.yaml SDK constraint to >=3.7.0 <4.0.0',
      '  • Refreshes analysis_options.yaml with stricter rules',
      '  • Updates lib/core/utils/dimensions.dart to universal approach',
      '  • Generates .ai/ directory with AI agent configuration',
      '  • Generates scripts/ with setup and doctor scripts',
      '',
      'Options:',
      parser().usage,
      '',
      'Examples:',
      '  arcle upgrade',
      '  arcle upgrade --state bloc',
      '  arcle upgrade --force',
    ].join('\n');
  }
}
