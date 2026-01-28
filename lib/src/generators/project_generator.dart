import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:arcle/src/templates/core/di_templates.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/file_writer.dart';
import 'state/state_project_files.dart';

class ProjectGenerator {
  ProjectGenerator({
    required this.ui,
    required this.state,
    required this.stateVersion,
    required this.force,
    this.overwriteMain = false,
    this.overwriteWidgetTest = false,
  });

  final CliUi ui;
  final StateManagement state;
  final String? stateVersion;
  final bool force;
  final bool overwriteMain;
  final bool overwriteWidgetTest;

  Console get console => ui.console;

  Future<int> flutterCreate(String name, Directory baseDir,
      {String? org}) async {
    ui.step('FLUTTER ', 'Creating Flutter project...');
    final args = ['create', name];
    if (org != null && org.isNotEmpty) {
      args.addAll(['--org', org]);
    }

    final result = await Process.run(
      'flutter',
      args,
      workingDirectory: baseDir.path,
      runInShell: true,
    );

    if (result.stdout.toString().trim().isNotEmpty) {
      ui.raw(result.stdout.toString().trim());
    }
    if (result.stderr.toString().trim().isNotEmpty) {
      ui.raw(result.stderr.toString().trim());
    }

    if (result.exitCode != 0) {
      ui.error(
          'Flutter create failed. Please ensure:');
      ui.raw('       • Flutter is installed and on PATH');
      ui.raw('       • Run "flutter doctor" to diagnose');
      return result.exitCode;
    }

    ui.success('Flutter project initialized.');
    return ExitCode.success.code;
  }

  Future<int> pubGet(Directory targetDir) async {
    ui.step('DEPS    ', 'Installing dependencies...');
    final result = await Process.run(
      'flutter',
      ['pub', 'get'],
      workingDirectory: targetDir.path,
      runInShell: true,
    );

    if (result.stdout.toString().trim().isNotEmpty) {
      ui.raw(result.stdout.toString().trim());
    }
    if (result.stderr.toString().trim().isNotEmpty) {
      ui.raw(result.stderr.toString().trim());
    }
    if (result.exitCode != 0) {
      ui.error('Failed to install dependencies. Run "flutter pub get" manually.');
      return result.exitCode;
    }
    ui.success('All dependencies installed.');
    return result.exitCode;
  }

  Future<int> buildRunner(Directory targetDir) async {
    ui.step('CODEGEN ', 'Running code generation...');
    final process = await Process.start(
      'dart',
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
      workingDirectory: targetDir.path,
      runInShell: true,
    );

    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();

    const progressSteps = [30, 60, 90];
    const progressMessages = [
      'Analyzing dependencies...',
      'Generating injection code...',
      'Writing output files...',
    ];
    var progressIndex = 0;
    ui.progress(
      'CODEGEN',
      progressSteps[progressIndex],
      message: progressMessages[progressIndex],
    );

    Timer? timer;
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (progressIndex >= progressSteps.length - 1) {
        timer?.cancel();
        return;
      }
      progressIndex += 1;
      ui.progress(
        'CODEGEN',
        progressSteps[progressIndex],
        message: progressMessages[progressIndex],
      );
    });

    final exitCode = await process.exitCode;
    timer.cancel();
    ui.progress('CODEGEN', 100, message: 'Complete!');

    final stdoutContent = await stdoutFuture;
    final stderrContent = await stderrFuture;
    if (stdoutContent.trim().isNotEmpty) {
      ui.raw(stdoutContent.trim());
    }
    if (stderrContent.trim().isNotEmpty) {
      ui.raw(stderrContent.trim());
    }
    if (exitCode != 0) {
      ui.error('Code generation failed. Check build_runner output above.');
      return exitCode;
    }
    ui.success('⚡ Code generation complete - DI is wired up!');
    return exitCode;
  }

  Future<void> scaffold(Directory targetDir) async {
    ui.step('SCAFFOLD', 'Setting up clean architecture...');
    console.line('');

    if (!targetDir.existsSync()) {
      ui.error('Target directory does not exist: ${targetDir.path}');
      return;
    }

    final writer = FileWriter(
      force: force,
      onWrite: (path) => ui.itemCreated(path),
      onSkip: (path) => ui.itemSkipped(path),
    );

    final files = _buildFiles();
    for (final entry in files.entries) {
      if (overwriteMain && entry.key == 'lib/main.dart') {
        final file = File(_join(targetDir.path, entry.key));
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(entry.value);
        ui.itemCreated(entry.key);
        continue;
      }
      if (overwriteWidgetTest && entry.key == 'test/widget_test.dart') {
        final file = File(_join(targetDir.path, entry.key));
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(entry.value);
        ui.itemCreated(entry.key);
        continue;
      }
      writer.write(targetDir, entry.key, entry.value);
    }

    _updatePubspec(targetDir);
    _updateDevDependencies(targetDir);
    _writeConfig(targetDir);
    console.line('');
    ui.success('🏗️  Architecture scaffold complete!');
  }

  void updateDependencies(Directory targetDir) {
    _updatePubspec(targetDir);
    _updateDevDependencies(targetDir);
  }

  Future<void> scaffoldDi(Directory targetDir) async {
    ui.step('DI      ', 'Updating dependency injection files...');
    console.line('');
    final writer = FileWriter(
      force: force,
      onWrite: (path) => ui.itemUpdated(path),
      onSkip: (_) {},
    );

    writer.write(
      targetDir,
      'lib/core/di/app_di.dart',
      DiTemplates.di(state),
    );
    if (state == StateManagement.riverpod) {
      writer.write(
        targetDir,
        'lib/core/di/providers.dart',
        DiTemplates.riverpodProviders(),
      );
    }
    if (state == StateManagement.bloc) {
      writer.write(
        targetDir,
        'lib/core/di/injection.dart',
        DiTemplates.blocInjection(),
      );
      writer.write(
        targetDir,
        'lib/core/di/injectable_module.dart',
        DiTemplates.blocInjectableModule(),
      );
      writer.write(
        targetDir,
        'lib/core/di/injection.config.dart',
        DiTemplates.blocInjectionConfig(),
      );
    }
    console.line('');
    ui.success('DI files updated.');
  }

  Map<String, String> _buildFiles() {
    return buildProjectFiles(state);
  }

  void _writeConfig(Directory base) {
    final configFile =
        File('${base.path}${Platform.pathSeparator}${ArcleConfig.filename}');
    if (configFile.existsSync() && !force) return;
    final config =
        ArcleConfig(state: state, createdAt: DateTime.now()).toYaml();
    configFile.writeAsStringSync(config);
    ui.itemCreated(ArcleConfig.filename);
  }

  void _updatePubspec(Directory base) {
    final pubspecFile = File(_join(base.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      ui.warn('pubspec.yaml not found; skipping dependency update.');
      return;
    }

    final content = pubspecFile.readAsStringSync();
    if (!content.contains('dependencies:')) {
      ui.warn('pubspec.yaml has no dependencies section; skipping.');
      return;
    }

    var updated = content;
    for (final dep in _dependencies()) {
      updated = _addDependency(updated, dep.name, dep.version);
    }
    updated = _ensureAssets(updated);

    if (updated == content) {
      ui.info('Dependencies already present.');
      return;
    }

    pubspecFile.writeAsStringSync(updated);
    ui.itemUpdated('pubspec.yaml dependencies');
  }

  void _updateDevDependencies(Directory base) {
    if (state != StateManagement.bloc) return;
    final pubspecFile = File(_join(base.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      return;
    }
    final content = pubspecFile.readAsStringSync();
    if (!content.contains('dev_dependencies:')) {
      return;
    }

    var updated = content;
    updated = _addDevDependency(updated, 'build_runner', 'any');
    updated = _addDevDependency(updated, 'injectable_generator', 'any');

    if (updated == content) {
      return;
    }
    pubspecFile.writeAsStringSync(updated);
    ui.itemUpdated('pubspec.yaml dev_dependencies');
  }

  List<_Dependency> _dependencies() {
    final version =
        (stateVersion == null || stateVersion!.isEmpty) ? 'any' : stateVersion!;
    final deps = <_Dependency>[
      _Dependency('dio', '^5.4.0'),
      _Dependency('shared_preferences', '^2.2.2'),
      _Dependency('permission_handler', '^11.3.0'),
      _Dependency('dartz', '^0.10.1'),
      _Dependency('flutter_local_notifications', '18.0.1'),
      _Dependency('timezone', '^0.9.4'),
      _Dependency('google_fonts', 'any'),
      _Dependency('flutter_svg', 'any'),
      _Dependency.sdk('flutter_localizations'),
    ];
    switch (state) {
      case StateManagement.bloc:
        deps.add(_Dependency('get_it', 'any'));
        deps.add(_Dependency('injectable', 'any'));
        deps.add(_Dependency('equatable', 'any'));
        deps.add(_Dependency('flutter_bloc', version));
      case StateManagement.getx:
        deps.add(_Dependency('get', version));
      case StateManagement.riverpod:
        deps.add(_Dependency('flutter_riverpod', version));
    }
    return deps;
  }

  String _addDependency(String content, String name, String version) {
    final lines = content.split('\n');
    final depIndex = lines.indexWhere((line) => line.trim() == 'dependencies:');
    if (depIndex == -1) return content;

    final already = lines.any((line) => line.trimLeft().startsWith('$name:'));
    if (already) return content;

    final indent = _detectIndent(lines, depIndex);
    if (version == 'sdk:flutter') {
      lines.insert(depIndex + 1, '$indent$name:');
      lines.insert(depIndex + 2, '$indent  sdk: flutter');
      return lines.join('\n');
    }
    lines.insert(depIndex + 1, '$indent$name: $version');
    return lines.join('\n');
  }

  String _addDevDependency(String content, String name, String version) {
    final lines = content.split('\n');
    final depIndex =
        lines.indexWhere((line) => line.trim() == 'dev_dependencies:');
    if (depIndex == -1) return content;

    final already = lines.any((line) => line.trimLeft().startsWith('$name:'));
    if (already) return content;

    final indent = _detectIndent(lines, depIndex);
    lines.insert(depIndex + 1, '$indent$name: $version');
    return lines.join('\n');
  }

  String _detectIndent(List<String> lines, int depIndex) {
    for (var i = depIndex + 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) continue;
      final leading = line.length - line.trimLeft().length;
      if (leading > 0) return line.substring(0, leading);
      break;
    }
    return '  ';
  }

  String _join(String base, String relative) {
    final normalized = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$normalized';
  }

  String _ensureAssets(String content) {
    final lines = content.split('\n');
    final flutterIndex = lines.indexWhere(
      (line) => line.trim() == 'flutter:' && !line.startsWith(' '),
    );
    if (flutterIndex == -1) return content;

    // Remove default commented assets block to avoid misplaced assets
    final cleaned = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('# To add assets') ||
          trimmed == '# assets:' ||
          trimmed.startsWith('#   - images/')) {
        continue;
      }
      cleaned.add(line);
    }

    final assetsPaths = [
      'assets/images/',
      'assets/icons/',
      'assets/langs/',
    ];

    final updatedLines = <String>[...cleaned];
    final updatedFlutterIndex = updatedLines.indexWhere(
      (line) => line.trim() == 'flutter:' && !line.startsWith(' '),
    );
    if (updatedFlutterIndex == -1) return content;

    var assetsIndex = -1;
    for (var i = updatedFlutterIndex + 1; i < updatedLines.length; i++) {
      final line = updatedLines[i];
      if (line.isNotEmpty && !line.startsWith(' ')) break;
      if (line.trimLeft().startsWith('assets:')) {
        assetsIndex = i;
        break;
      }
    }

    const flutterIndent = '  ';
    const assetIndent = '    ';

    if (assetsIndex == -1) {
      var insertIndex = updatedFlutterIndex + 1;
      for (var i = updatedFlutterIndex + 1; i < updatedLines.length; i++) {
        final line = updatedLines[i];
        if (line.isNotEmpty && !line.startsWith(' ')) break;
        if (line.trimLeft().startsWith('uses-material-design:')) {
          insertIndex = i + 1;
          break;
        }
      }

      updatedLines.insertAll(insertIndex, [
        '${flutterIndent}assets:',
        for (final path in assetsPaths) '$assetIndent- $path',
      ]);
      return updatedLines.join('\n');
    }

    var insertAfter = assetsIndex + 1;
    for (var i = assetsIndex + 1; i < updatedLines.length; i++) {
      final line = updatedLines[i];
      if (line.isNotEmpty && !line.startsWith(' ')) break;
      if (!line.trimLeft().startsWith('-')) {
        insertAfter = i;
        continue;
      }
      insertAfter = i + 1;
    }

    final existing = updatedLines
        .where((line) => line.trimLeft().startsWith('- '))
        .map((line) => line.trim().substring(2))
        .toSet();
    final toAdd =
        assetsPaths.where((path) => !existing.contains(path)).toList();
    if (toAdd.isEmpty) return updatedLines.join('\n');

    updatedLines.insertAll(
      insertAfter,
      [for (final path in toAdd) '$assetIndent- $path'],
    );
    return updatedLines.join('\n');
  }
}

class _Dependency {
  _Dependency(this.name, this.version);
  _Dependency.sdk(String name) : this(name, 'sdk:flutter');

  final String name;
  final String version;
}
