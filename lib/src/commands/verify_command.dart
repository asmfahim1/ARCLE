import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:io/io.dart';

import '../state_management.dart';
import '../ui/cli_ui.dart';
import '../utils/arcle_config.dart';
import '../utils/console.dart';
import '../utils/state_picker.dart';

class VerifyCommand {
  VerifyCommand(this.console);

  final Console console;

  static ArgParser parser() {
    return ArgParser()
      ..addFlag('help', abbr: 'h', negatable: false)
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
        'skip-analyze',
        help: 'Skip flutter analyze',
        negatable: false,
      )
      ..addFlag(
        'skip-test',
        help: 'Skip flutter test',
        negatable: false,
      )
      ..addFlag(
        'skip-codegen',
        help: 'Skip build_runner check for BLoC projects',
        negatable: false,
      )
      ..addFlag(
        'include-boilerplate-tests',
        help: 'Include ARCLE-generated widget boilerplate tests during flutter test',
        negatable: false,
      )
      ..addFlag(
        'check-16kb',
        help: 'Build a release APK and run static 16 KB page-size checks',
        negatable: false,
      )
      ..addFlag(
        'check-features',
        help: 'Check that each feature module has all required ARCLE layers',
        negatable: false,
      )
      ..addFlag(
        'check-assets',
        help: 'Check that all asset paths declared in pubspec.yaml exist on disk',
        negatable: false,
      )
      ..addFlag(
        'check-l10n',
        help: 'Check that each feature has a localization key in the translation files',
        negatable: false,
      )
      ..addFlag(
        'full',
        help: 'Run all checks including --check-features, --check-assets and --check-l10n',
        negatable: false,
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Prompt for any missing values',
        defaultsTo: true,
      );
  }

  Future<int> run(ArgResults cmd) async {
    final ui = CliUi(console);
    if (cmd['help'] == true) {
      console.line(_usage());
      return ExitCode.success.code;
    }

    final targetDir = Directory(cmd['path'] as String);
    final config = ArcleConfig.readFrom(targetDir);
    final stateInput = cmd['state'] as String?;
    final interactive = cmd['interactive'] as bool;

    StateManagement? state;
    if (stateInput != null && stateInput.trim().isNotEmpty) {
      state = StatePicker(console).resolve(stateInput, interactive: false);
    } else if (config?.state != null) {
      state = config!.state;
      ui.info(
        'Detected state management from ${ArcleConfig.filename}: ${state.label}.',
      );
    } else {
      state = StatePicker(console).resolve(null, interactive: interactive);
    }

    ui.section('Project Verify');
    ui.step('PATH    ', targetDir.path);
    if (state != null) {
      ui.step('STATE   ', state.label);
    }

    var failed = false;

    if (cmd['skip-analyze'] != true) {
      failed = !await _runStep(
        ui,
        'ANALYZE ',
        'flutter',
        const ['analyze'],
        targetDir,
      ) ||
          failed;
    }

    if (cmd['skip-test'] != true) {
      final testArgs = _resolveTestArgs(
        targetDir,
        includeBoilerplateTests: cmd['include-boilerplate-tests'] == true,
      );
      if (testArgs == null) {
        ui.warn('No non-boilerplate tests selected; skipping flutter test.');
      } else {
        failed = !await _runStep(
          ui,
          'TEST    ',
          'flutter',
          testArgs,
          targetDir,
        ) ||
            failed;
      }
    }

    if (state == StateManagement.bloc && cmd['skip-codegen'] != true) {
      failed = !await _runStep(
        ui,
        'CODEGEN ',
        'dart',
        const ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
        targetDir,
      ) ||
          failed;
    }

    if (cmd['check-16kb'] == true) {
      failed = !await _run16KbCheck(ui, targetDir) || failed;
    }

    final fullCheck = cmd['full'] == true;

    if ((cmd['check-features'] == true || fullCheck) && state != null) {
      failed = !_runFeatureCheck(ui, targetDir, state) || failed;
    }

    if (cmd['check-assets'] == true || fullCheck) {
      failed = !_runAssetCheck(ui, targetDir) || failed;
    }

    if ((cmd['check-l10n'] == true || fullCheck) && state != null) {
      failed = !_runL10nCheck(ui, targetDir, state) || failed;
    }

    if (failed) {
      ui.error('Verification failed.');
      return ExitCode.software.code;
    }

    ui.success('Verification passed.');
    return ExitCode.success.code;
  }

  Future<bool> _run16KbCheck(CliUi ui, Directory targetDir) async {
    ui.step('16KB    ', 'flutter build apk --release');
    final buildResult = await _runProcess(
      'flutter',
      const ['build', 'apk', '--release'],
      targetDir,
    );
    if (buildResult.exitCode != 0) {
      _printFailureOutput(ui, buildResult);
      ui.error('16 KB check failed because release APK build failed.');
      return false;
    }

    final apkFile = _findReleaseApk(targetDir);
    if (apkFile == null) {
      ui.error('16 KB check failed: release APK was not found.');
      return false;
    }

    ui.step('16KBAPK ', apkFile.path);

    final report = _analyzeApk16Kb(apkFile);
    for (final line in report.details) {
      ui.raw(line);
    }

    switch (report.status) {
      case _SixteenKbStatus.pass:
        ui.success('16 KB static checks passed.');
        return true;
      case _SixteenKbStatus.fail:
        ui.error('16 KB static checks failed.');
        return false;
      case _SixteenKbStatus.unknown:
        ui.warn('16 KB static checks are inconclusive.');
        return false;
    }
  }

  Future<bool> _runStep(
    CliUi ui,
    String label,
    String executable,
    List<String> args,
    Directory targetDir,
  ) async {
    ui.step(label, '$executable ${args.join(' ')}');
    try {
      final result = await _runProcess(executable, args, targetDir);
      if (result.exitCode != 0) {
        _printFailureOutput(ui, result);
        ui.error('$executable ${args.first} failed.');
        return false;
      }
      ui.success('$executable ${args.first} passed.');
      return true;
    } catch (error) {
      ui.error('Failed to run $executable: $error');
      return false;
    }
  }

  Future<ProcessResult> _runProcess(
    String executable,
    List<String> args,
    Directory targetDir,
  ) {
    return Process.run(
      executable,
      args,
      workingDirectory: targetDir.path,
      runInShell: true,
    );
  }

  void _printFailureOutput(CliUi ui, ProcessResult result) {
    final stdout = result.stdout.toString().trim();
    final stderr = result.stderr.toString().trim();
    if (stdout.isNotEmpty) {
      ui.raw(stdout);
    }
    if (stderr.isNotEmpty) {
      ui.raw(stderr);
    }
  }

  File? _findReleaseApk(Directory targetDir) {
    final candidates = [
      _join(targetDir.path, 'build/app/outputs/flutter-apk/app-release.apk'),
      _join(targetDir.path, 'build/app/outputs/apk/release/app-release.apk'),
    ];
    for (final path in candidates) {
      final file = File(path);
      if (file.existsSync()) return file;
    }
    return null;
  }

  List<String>? _resolveTestArgs(
    Directory targetDir, {
    required bool includeBoilerplateTests,
  }) {
    final testDir = Directory(_join(targetDir.path, 'test'));
    if (!testDir.existsSync()) {
      return null;
    }

    final allTests = testDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_test.dart'))
        .map((file) => _relativePath(targetDir.path, file.path))
        .toList()
      ..sort();

    if (allTests.isEmpty) {
      return null;
    }

    if (includeBoilerplateTests) {
      return ['test', ...allTests];
    }

    final selectedTests = allTests
        .where((path) => !_generatedBoilerplateTests.contains(path))
        .toList();

    if (selectedTests.isEmpty) {
      return null;
    }

    return ['test', ...selectedTests];
  }

  String _relativePath(String basePath, String fullPath) {
    final normalizedBase = basePath.replaceAll('\\', '/');
    final normalizedFull = fullPath.replaceAll('\\', '/');
    final baseWithSlash = normalizedBase.endsWith('/')
        ? normalizedBase
        : '$normalizedBase/';
    if (normalizedFull.startsWith(baseWithSlash)) {
      return normalizedFull.substring(baseWithSlash.length);
    }
    return normalizedFull;
  }

  _SixteenKbReport _analyzeApk16Kb(File apkFile) {
    try {
      final bytes = apkFile.readAsBytesSync();
      final entries = _readZipEntries(bytes);
      final nativeEntries = entries
          .where((entry) =>
              entry.fileName.startsWith('lib/') &&
              entry.fileName.endsWith('.so'))
          .toList()
        ..sort((a, b) => a.fileName.compareTo(b.fileName));

      if (nativeEntries.isEmpty) {
        return _SixteenKbReport(
          _SixteenKbStatus.unknown,
          const ['No native .so libraries were found in the release APK.'],
        );
      }

      final details = <String>[
        'Static 16 KB checks inspect APK entry alignment and ELF PT_LOAD alignment.',
      ];
      var hasFailure = false;
      var hasUnknown = false;

      for (final entry in nativeEntries) {
        final issues = <String>[];
        if (entry.dataOffset % 16384 != 0) {
          issues.add('APK entry data offset ${entry.dataOffset} is not 16 KB aligned');
        }

        if (entry.compressionMethod != 0) {
          issues.add(
            'APK entry uses ZIP compression method ${entry.compressionMethod}; expected stored/uncompressed for mmap-friendly loading',
          );
        }

        List<int> libraryBytes;
        try {
          libraryBytes = _extractZipEntry(bytes, entry);
        } catch (error) {
          hasUnknown = true;
          details.add('UNKNOWN ${entry.fileName}: could not read library bytes ($error)');
          continue;
        }

        final elfResult = _analyzeElf16Kb(libraryBytes);
        if (elfResult.error != null) {
          hasUnknown = true;
          details.add('UNKNOWN ${entry.fileName}: ${elfResult.error}');
          continue;
        }

        issues.addAll(elfResult.issues);
        if (issues.isEmpty) {
          details.add('PASS ${entry.fileName}');
        } else {
          hasFailure = true;
          details.add('FAIL ${entry.fileName}: ${issues.join('; ')}');
        }
      }

      if (hasFailure) {
        return _SixteenKbReport(_SixteenKbStatus.fail, details);
      }
      if (hasUnknown) {
        return _SixteenKbReport(_SixteenKbStatus.unknown, details);
      }
      return _SixteenKbReport(_SixteenKbStatus.pass, details);
    } catch (error) {
      return _SixteenKbReport(
        _SixteenKbStatus.unknown,
        ['Could not inspect APK for 16 KB compatibility: $error'],
      );
    }
  }

  List<_ZipEntry> _readZipEntries(List<int> bytes) {
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final eocdOffset = _findEndOfCentralDirectory(bytes);
    if (eocdOffset < 0) {
      throw const FormatException('ZIP end of central directory not found');
    }

    final totalEntries = data.getUint16(eocdOffset + 10, Endian.little);
    final centralDirectoryOffset =
        data.getUint32(eocdOffset + 16, Endian.little);

    final entries = <_ZipEntry>[];
    var offset = centralDirectoryOffset;
    for (var i = 0; i < totalEntries; i++) {
      final signature = data.getUint32(offset, Endian.little);
      if (signature != 0x02014b50) {
        throw FormatException(
            'Invalid ZIP central directory signature at offset $offset');
      }

      final compressionMethod = data.getUint16(offset + 10, Endian.little);
      final compressedSize = data.getUint32(offset + 20, Endian.little);
      final uncompressedSize = data.getUint32(offset + 24, Endian.little);
      final fileNameLength = data.getUint16(offset + 28, Endian.little);
      final extraFieldLength = data.getUint16(offset + 30, Endian.little);
      final fileCommentLength = data.getUint16(offset + 32, Endian.little);
      final localHeaderOffset = data.getUint32(offset + 42, Endian.little);
      final fileNameBytes =
          bytes.sublist(offset + 46, offset + 46 + fileNameLength);
      final fileName = String.fromCharCodes(fileNameBytes);
      final dataOffset = _zipEntryDataOffset(data, localHeaderOffset);

      entries.add(_ZipEntry(
        fileName: fileName,
        compressionMethod: compressionMethod,
        compressedSize: compressedSize,
        uncompressedSize: uncompressedSize,
        localHeaderOffset: localHeaderOffset,
        dataOffset: dataOffset,
      ));

      offset += 46 + fileNameLength + extraFieldLength + fileCommentLength;
    }

    return entries;
  }

  int _findEndOfCentralDirectory(List<int> bytes) {
    final minOffset = bytes.length >= 22 ? bytes.length - 22 : 0;
    final lowerBound = bytes.length > 0x10000 + 22 ? bytes.length - 0x10000 - 22 : 0;
    for (var offset = minOffset; offset >= lowerBound; offset--) {
      if (bytes[offset] == 0x50 &&
          bytes[offset + 1] == 0x4b &&
          bytes[offset + 2] == 0x05 &&
          bytes[offset + 3] == 0x06) {
        return offset;
      }
    }
    return -1;
  }

  int _zipEntryDataOffset(ByteData data, int localHeaderOffset) {
    final signature = data.getUint32(localHeaderOffset, Endian.little);
    if (signature != 0x04034b50) {
      throw FormatException(
          'Invalid ZIP local header signature at offset $localHeaderOffset');
    }
    final fileNameLength =
        data.getUint16(localHeaderOffset + 26, Endian.little);
    final extraFieldLength =
        data.getUint16(localHeaderOffset + 28, Endian.little);
    return localHeaderOffset + 30 + fileNameLength + extraFieldLength;
  }

  List<int> _extractZipEntry(List<int> archiveBytes, _ZipEntry entry) {
    final compressedBytes = archiveBytes.sublist(
      entry.dataOffset,
      entry.dataOffset + entry.compressedSize,
    );

    switch (entry.compressionMethod) {
      case 0:
        return compressedBytes;
      case 8:
        final decoded = ZLibDecoder(raw: true).convert(compressedBytes);
        if (decoded.length != entry.uncompressedSize) {
          throw FormatException(
            'Unexpected uncompressed size for ${entry.fileName}: '
            'expected ${entry.uncompressedSize}, got ${decoded.length}',
          );
        }
        return decoded;
      default:
        throw UnsupportedError(
          'Unsupported ZIP compression method ${entry.compressionMethod}',
        );
    }
  }

  _ElfCheckResult _analyzeElf16Kb(List<int> bytes) {
    if (bytes.length < 16 ||
        bytes[0] != 0x7f ||
        bytes[1] != 0x45 ||
        bytes[2] != 0x4c ||
        bytes[3] != 0x46) {
      return const _ElfCheckResult(error: 'file is not a valid ELF library');
    }

    final elfClass = bytes[4];
    final elfData = bytes[5];
    final endian = switch (elfData) {
      1 => Endian.little,
      2 => Endian.big,
      _ => null,
    };
    if (endian == null) {
      return const _ElfCheckResult(error: 'ELF endianness is unsupported');
    }

    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final issues = <String>[];

    late final int phoff;
    late final int phentsize;
    late final int phnum;

    if (elfClass == 1) {
      if (bytes.length < 52) {
        return const _ElfCheckResult(error: 'ELF32 header is truncated');
      }
      phoff = data.getUint32(28, endian);
      phentsize = data.getUint16(42, endian);
      phnum = data.getUint16(44, endian);
    } else if (elfClass == 2) {
      if (bytes.length < 64) {
        return const _ElfCheckResult(error: 'ELF64 header is truncated');
      }
      final phoff64 = data.getUint64(32, endian);
      if (phoff64 > bytes.length) {
        return const _ElfCheckResult(error: 'ELF64 program header offset is invalid');
      }
      phoff = phoff64.toInt();
      phentsize = data.getUint16(54, endian);
      phnum = data.getUint16(56, endian);
    } else {
      return _ElfCheckResult(error: 'unsupported ELF class $elfClass');
    }

    if (phnum == 0) {
      return const _ElfCheckResult(error: 'ELF file has no program headers');
    }

    for (var i = 0; i < phnum; i++) {
      final entryOffset = phoff + (i * phentsize);
      if (entryOffset + phentsize > bytes.length) {
        return _ElfCheckResult(
          error: 'program header $i extends beyond the ELF file',
        );
      }

      late final int type;
      late final int offset;
      late final int vaddr;
      late final int align;

      if (elfClass == 1) {
        type = data.getUint32(entryOffset, endian);
        offset = data.getUint32(entryOffset + 4, endian);
        vaddr = data.getUint32(entryOffset + 8, endian);
        align = data.getUint32(entryOffset + 28, endian);
      } else {
        type = data.getUint32(entryOffset, endian);
        final offset64 = data.getUint64(entryOffset + 8, endian);
        final vaddr64 = data.getUint64(entryOffset + 16, endian);
        final align64 = data.getUint64(entryOffset + 48, endian);
        if (offset64 > bytes.length || vaddr64 > 0x7fffffffffffffff) {
          return _ElfCheckResult(
            error: 'program header $i contains values that are too large to inspect',
          );
        }
        offset = offset64.toInt();
        vaddr = vaddr64.toInt();
        align = align64 > 0x7fffffffffffffff ? 0 : align64.toInt();
      }

      if (type != 1) continue;

      if (align < 16384) {
        issues.add('PT_LOAD[$i] has p_align=$align, expected at least 16384');
      }
      if (align > 0 && (offset % 16384) != (vaddr % 16384)) {
        issues.add(
          'PT_LOAD[$i] has mismatched p_offset/p_vaddr modulo 16384 (${offset % 16384} vs ${vaddr % 16384})',
        );
      }
    }

    return _ElfCheckResult(issues: issues);
  }

  // ─── Feature structure check ───────────────────────────────────────────────

  bool _runFeatureCheck(
    CliUi ui,
    Directory targetDir,
    StateManagement state,
  ) {
    ui.step('FEATURES', 'Checking feature module completeness...');
    final featuresDir = Directory(_join(targetDir.path, 'lib/features'));
    if (!featuresDir.existsSync()) {
      ui.warn('lib/features not found — skipping feature check.');
      return true;
    }

    final features = featuresDir
        .listSync()
        .whereType<Directory>()
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    if (features.isEmpty) {
      ui.info('No feature modules found.');
      return true;
    }

    var allPassed = true;
    for (final featureDir in features) {
      final name = featureDir.uri.pathSegments
          .where((s) => s.isNotEmpty)
          .last;
      final missing = _missingFeatureFiles(featureDir, name, state);
      if (missing.isEmpty) {
        ui.success('feature/$name — complete');
      } else {
        allPassed = false;
        ui.warn('feature/$name — missing ${missing.length} file(s):');
        for (final m in missing) {
          ui.raw('       • $m');
        }
      }
    }

    if (allPassed) {
      ui.success('All feature modules are complete.');
    } else {
      ui.error('Some feature modules have missing files.');
    }
    return allPassed;
  }

  List<String> _missingFeatureFiles(
    Directory featureDir,
    String name,
    StateManagement state,
  ) {
    final required = <String>[
      'data/model/${name}_model.dart',
      'data/source/${name}_remote_source.dart',
      'data/repository/${name}_repository_impl.dart',
      'domain/entity/${name}_entity.dart',
      'domain/repository/${name}_repository.dart',
      'domain/usecase/${name}_usecase.dart',
      'presentation/pages/${name}_screen.dart',
    ];

    switch (state) {
      case StateManagement.bloc:
        required.addAll([
          'presentation/bloc/${name}_bloc.dart',
          'presentation/bloc/${name}_event.dart',
          'presentation/bloc/${name}_state.dart',
        ]);
        break;
      case StateManagement.getx:
        required.addAll([
          'presentation/controller/${name}_controller.dart',
          'presentation/bindings/${name}_binding.dart',
        ]);
        break;
      case StateManagement.riverpod:
        required.addAll([
          'presentation/providers/${name}_providers.dart',
          'presentation/state/${name}_state.dart',
        ]);
        break;
    }

    return required.where((rel) {
      final norm = rel.replaceAll('/', Platform.pathSeparator);
      final full = '${featureDir.path}${Platform.pathSeparator}$norm';
      return !File(full).existsSync();
    }).toList();
  }

  // ─── Asset existence check ─────────────────────────────────────────────────

  bool _runAssetCheck(CliUi ui, Directory targetDir) {
    ui.step('ASSETS  ', 'Checking pubspec.yaml asset paths...');
    final pubspecFile = File(_join(targetDir.path, 'pubspec.yaml'));
    if (!pubspecFile.existsSync()) {
      ui.warn('pubspec.yaml not found — skipping asset check.');
      return true;
    }

    final assetPaths = _parseAssetPaths(pubspecFile.readAsStringSync());
    if (assetPaths.isEmpty) {
      ui.info('No asset paths declared in pubspec.yaml.');
      return true;
    }

    var allPassed = true;
    for (final assetPath in assetPaths) {
      final norm = assetPath.replaceAll('/', Platform.pathSeparator);
      final full = '${targetDir.path}${Platform.pathSeparator}$norm';
      final type = FileSystemEntity.typeSync(full);
      if (type == FileSystemEntityType.notFound) {
        allPassed = false;
        ui.warn('Missing asset path: $assetPath');
      }
    }

    if (allPassed) {
      ui.success('All declared asset paths exist (${assetPaths.length} checked).');
    } else {
      ui.error('Some declared asset paths are missing.');
    }
    return allPassed;
  }

  List<String> _parseAssetPaths(String pubspecContent) {
    final paths = <String>[];
    final lines = pubspecContent.split('\n');
    var inFlutter = false;
    var inAssets = false;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed == 'flutter:' && !line.startsWith(' ')) {
        inFlutter = true;
        inAssets = false;
        continue;
      }
      if (inFlutter) {
        if (line.isNotEmpty && !line.startsWith(' ')) {
          inFlutter = false;
          inAssets = false;
          continue;
        }
        if (trimmed == 'assets:') {
          inAssets = true;
          continue;
        }
        if (inAssets) {
          if (trimmed.isNotEmpty && !trimmed.startsWith('-') &&
              !trimmed.startsWith('#')) {
            inAssets = false;
            continue;
          }
          if (trimmed.startsWith('- ')) {
            paths.add(trimmed.substring(2).trim());
          }
        }
      }
    }

    return paths;
  }

  // ─── Localization key check ────────────────────────────────────────────────

  bool _runL10nCheck(
    CliUi ui,
    Directory targetDir,
    StateManagement state,
  ) {
    ui.step('L10N    ', 'Checking localization key coverage...');
    final featuresDir = Directory(_join(targetDir.path, 'lib/features'));
    if (!featuresDir.existsSync()) {
      ui.warn('lib/features not found — skipping l10n check.');
      return true;
    }

    final features = featuresDir
        .listSync()
        .whereType<Directory>()
        .map((d) => d.uri.pathSegments.where((s) => s.isNotEmpty).last)
        .toList()
      ..sort();

    if (features.isEmpty) {
      ui.info('No feature modules found.');
      return true;
    }

    if (state == StateManagement.getx) {
      return _checkGetxL10nKeys(ui, targetDir, features);
    }
    return _checkJsonL10nKeys(ui, targetDir, features);
  }

  bool _checkJsonL10nKeys(
    CliUi ui,
    Directory targetDir,
    List<String> features,
  ) {
    final enFile = File(_join(targetDir.path, 'assets/langs/en.json'));
    if (!enFile.existsSync()) {
      ui.warn('assets/langs/en.json not found — run "arcle localization add".');
      return false;
    }

    Map<String, dynamic> enMap;
    try {
      enMap = json.decode(enFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      ui.error('Could not parse assets/langs/en.json.');
      return false;
    }

    var allPassed = true;
    for (final feature in features) {
      final key = '${feature}_title';
      if (enMap.containsKey(key)) {
        ui.success('$feature — key "$key" found');
      } else {
        allPassed = false;
        ui.warn('$feature — missing key "$key" in en.json');
      }
    }

    if (allPassed) {
      ui.success('All feature localization keys are present.');
    } else {
      ui.error('Some features are missing localization keys.');
    }
    return allPassed;
  }

  bool _checkGetxL10nKeys(
    CliUi ui,
    Directory targetDir,
    List<String> features,
  ) {
    final getxFile = File(
      _join(targetDir.path, 'lib/core/localization/getx_localization.dart'),
    );
    if (!getxFile.existsSync()) {
      ui.warn(
        'lib/core/localization/getx_localization.dart not found — run "arcle localization add".',
      );
      return false;
    }

    final content = getxFile.readAsStringSync();
    var allPassed = true;
    for (final feature in features) {
      final key = '${feature}_title';
      if (content.contains("'$key'")) {
        ui.success('$feature — key "$key" found');
      } else {
        allPassed = false;
        ui.warn('$feature — missing key "$key" in getx_localization.dart');
      }
    }

    if (allPassed) {
      ui.success('All feature localization keys are present.');
    } else {
      ui.error('Some features are missing localization keys.');
    }
    return allPassed;
  }

  // ─────────────────────────────────────────────────────────────────────────

  String _join(String base, String relative) {
    final normalized = relative.replaceAll('/', Platform.pathSeparator);
    return '$base${Platform.pathSeparator}$normalized';
  }

  String _usage() {
    return [
      'Usage:',
      '  arcle verify [options]',
      '',
      'Options:',
      parser().usage,
      '',
      'Examples:',
      '  arcle verify                        # analyze + test',
      '  arcle verify --check-features       # check feature layer completeness',
      '  arcle verify --check-assets         # check pubspec asset paths exist',
      '  arcle verify --check-l10n           # check feature localization keys',
      '  arcle verify --full                 # run all checks',
    ].join('\n');
  }
}

const Set<String> _generatedBoilerplateTests = {
  'test/widget_test.dart',
  'test/features/auth/login_screen_test.dart',
  'test/features/settings/settings_screen_test.dart',
};

enum _SixteenKbStatus { pass, fail, unknown }

class _SixteenKbReport {
  const _SixteenKbReport(this.status, this.details);

  final _SixteenKbStatus status;
  final List<String> details;
}

class _ZipEntry {
  const _ZipEntry({
    required this.fileName,
    required this.compressionMethod,
    required this.compressedSize,
    required this.uncompressedSize,
    required this.localHeaderOffset,
    required this.dataOffset,
  });

  final String fileName;
  final int compressionMethod;
  final int compressedSize;
  final int uncompressedSize;
  final int localHeaderOffset;
  final int dataOffset;
}

class _ElfCheckResult {
  const _ElfCheckResult({this.issues = const [], this.error});

  final List<String> issues;
  final String? error;
}
