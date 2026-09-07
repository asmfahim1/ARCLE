import 'dart:io';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../ui/cli_ui.dart';
import '../utils/console.dart';

class OrganizeCommand {
  OrganizeCommand(this.console);

  final Console console;

  static ArgParser parser() {
    final imports =
        ArgParser()
          ..addOption(
            'path',
            abbr: 'p',
            help: 'Directory of an ARCLE Flutter project',
            defaultsTo: Directory.current.path,
          )
          ..addFlag(
            'check',
            help: 'Show files that would change without writing them',
            negatable: false,
          );

    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
      ..addCommand('imports', imports);
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }
    if (cmd.command?.name != 'imports') {
      ui.error('Missing organize target.');
      console.line(_usage());
      return ExitCode.usage.code;
    }

    final imports = cmd.command!;
    final project = Directory(imports['path'] as String);
    if (!project.existsSync()) {
      ui.error('Directory not found: ${project.path}');
      return ExitCode.usage.code;
    }

    final packageName = _packageName(project);
    if (packageName == null) {
      ui.error('pubspec.yaml with a valid package name was not found.');
      return ExitCode.usage.code;
    }

    final checkOnly = imports['check'] == true;
    final files = _dartFiles(project);
    var changed = 0;
    ui.section(checkOnly ? 'Checking Imports' : 'Organizing Imports');
    ui.step('PROJECT ', project.path);
    ui.step('PACKAGE ', packageName);

    for (final file in files) {
      final original = file.readAsStringSync();
      final updated = _organizeFile(original, file, project, packageName);
      if (updated == original) continue;
      changed++;
      final relative = _relativePath(project, file);
      if (checkOnly) {
        ui.warn('Would update $relative');
      } else {
        file.writeAsStringSync(updated);
        ui.itemUpdated(relative);
      }
    }

    if (changed == 0) {
      ui.success(
        checkOnly
            ? 'Imports are already organized.'
            : 'Imports are already organized.',
      );
    } else if (checkOnly) {
      ui.info('$changed file(s) need import organization.');
    } else {
      ui.success('Organized imports in $changed file(s).');
    }
    return ExitCode.success.code;
  }

  List<File> _dartFiles(Directory project) {
    final files = <File>[];
    for (final entity in project.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.contains('/.dart_tool/') ||
          normalized.contains('/build/') ||
          normalized.contains('/.git/')) {
        continue;
      }
      files.add(entity);
    }
    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  String? _packageName(Directory project) {
    final pubspec = File(_join(project.path, 'pubspec.yaml'));
    if (!pubspec.existsSync()) return null;
    final match = RegExp(
      r'^name:\s*([^\s#]+)',
      multiLine: true,
    ).firstMatch(pubspec.readAsStringSync());
    return match?.group(1);
  }

  String _organizeFile(
    String content,
    File file,
    Directory project,
    String packageName,
  ) {
    final lines = content.split('\n');
    final imports = <_ImportLine>[];
    var first = -1;
    var last = -1;
    var index = 0;
    var sawImport = false;
    while (index < lines.length) {
      final match = RegExp(
        r'''^\s*import\s+(['"])([^'"]+)\1(.*);\s*$''',
      ).firstMatch(lines[index]);
      if (match != null) {
        sawImport = true;
        first = first == -1 ? index : first;
        last = index;
        final uri = _toPackageImport(
          match.group(2)!,
          file,
          project,
          packageName,
        );
        imports.add(_ImportLine('import \'$uri\'${match.group(3)};'));
      } else if (sawImport && lines[index].trim().isNotEmpty) {
        break;
      } else if (sawImport) {
        last = index;
      }
      index++;
    }
    if (first == -1) return content;

    final unique = <String, _ImportLine>{};
    for (final import in imports) {
      unique[import.source] = import;
    }
    final sorted = unique.values.toList()..sort(_compareImports);
    final replacement = <String>[];
    String? previousGroup;
    for (final import in sorted) {
      final group = _importGroup(import.source);
      if (previousGroup != null && group != previousGroup) replacement.add('');
      replacement.add(import.source);
      previousGroup = group;
    }
    lines.replaceRange(first, last + 1, replacement);
    return lines.join('\n');
  }

  String _toPackageImport(
    String uri,
    File file,
    Directory project,
    String packageName,
  ) {
    if (uri.startsWith('dart:') || uri.startsWith('package:')) {
      return _repairPackageImport(uri, project, packageName);
    }
    final resolved =
        File(
          Uri.file(
            '${file.parent.path}${Platform.pathSeparator}',
          ).resolve(uri).toFilePath(),
        ).absolute.path;
    final libRoot = Directory(_join(project.path, 'lib')).absolute.path;
    final normalizedResolved = resolved.replaceAll('\\', '/');
    final normalizedLib = libRoot
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'/$'), '');
    if (normalizedResolved == normalizedLib ||
        !normalizedResolved.startsWith('$normalizedLib/')) {
      return uri;
    }
    final relative = normalizedResolved.substring(normalizedLib.length + 1);
    return 'package:$packageName/${relative.replaceAll('\\', '/')}';
  }

  String _repairPackageImport(
    String uri,
    Directory project,
    String packageName,
  ) {
    final prefix = 'package:$packageName/';
    if (!uri.startsWith(prefix)) return uri;
    final packagePath = uri.substring(prefix.length);
    final expected = File(_join(project.path, 'lib/$packagePath'));
    if (expected.existsSync()) return uri;

    final matches = <String>[];
    final suffix = '/$packagePath';
    for (final entity in Directory(
      _join(project.path, 'lib'),
    ).listSync(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.endsWith(suffix)) {
        final marker = normalized.indexOf('/lib/');
        if (marker >= 0) matches.add(normalized.substring(marker + 5));
      }
    }
    if (matches.length != 1) return uri;
    return 'package:$packageName/${matches.single}';
  }

  int _compareImports(_ImportLine a, _ImportLine b) {
    final groupCompare = _importGroup(
      a.source,
    ).compareTo(_importGroup(b.source));
    if (groupCompare != 0) return groupCompare;
    return a.source.compareTo(b.source);
  }

  String _importGroup(String source) {
    if (source.startsWith("import 'dart:")) return '0';
    if (source.startsWith("import 'package:")) return '1';
    return '2';
  }

  String _relativePath(Directory project, File file) {
    final base = project.absolute.path.replaceAll('\\', '/');
    final path = file.absolute.path.replaceAll('\\', '/');
    return path.startsWith('$base/')
        ? path.substring(base.length + 1)
        : file.path;
  }

  String _join(String base, String relative) {
    return '$base${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}';
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle organize imports [options]',
      '',
      'Convert project-relative lib imports to package imports and organize them.',
      '',
      'Options:',
      parser().commands['imports']!.usage,
    ].join('\n');
  }
}

class _ImportLine {
  const _ImportLine(this.source);

  final String source;
}
