import 'dart:io';

class BlocProvidersUpdater {
  BlocProvidersUpdater({required this.stdout, required this.stderr});

  final void Function(String message) stdout;
  final void Function(String message) stderr;

  void addFeatureBlocProvider(Directory base, String featureName) {
    final providersFile = File(
      '${base.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
      '${Platform.pathSeparator}di${Platform.pathSeparator}bloc_providers.dart',
    );

    if (!providersFile.existsSync()) {
      stderr('bloc_providers.dart not found; skipping bloc provider update.');
      return;
    }

    var content = providersFile.readAsStringSync();
    const importMarker = '// arcle:feature_imports';
    const providerMarker = '// arcle:feature_providers';
    if (!content.contains(importMarker) || !content.contains(providerMarker)) {
      stderr('bloc_providers.dart markers not found; skipping bloc provider update.');
      return;
    }

    final className = _pascalCase(featureName);
    const injectionImport = "import 'injection.dart';";
    final blocImport =
        "import '../../features/$featureName/presentation/bloc/${featureName}_bloc.dart';";
    final usecaseImport =
        "import '../../features/$featureName/domain/usecase/get_${featureName}_data_usecase.dart';";

    final missingImports = <String>[];
    if (!content.contains(injectionImport)) {
      missingImports.add(injectionImport);
    }
    if (!content.contains(blocImport)) {
      missingImports.add(blocImport);
    }
    if (!content.contains(usecaseImport)) {
      missingImports.add(usecaseImport);
    }

    if (missingImports.isNotEmpty) {
      content = content.replaceFirst(
        importMarker,
        '$importMarker\n${missingImports.join('\n')}',
      );
    }

    final providerLine =
        "    BlocProvider<${className}Bloc>(create: (_) => ${className}Bloc(getIt<Get${className}DataUseCase>())),";
    if (!content.contains(providerLine)) {
      content = content.replaceFirst(
        providerMarker,
        '$providerLine\n    $providerMarker',
      );
    }

    providersFile.writeAsStringSync(content);
    stdout('Updated: lib/core/di/bloc_providers.dart');
  }

  String _pascalCase(String input) {
    final parts = input.split(RegExp(r'[\\/_\\-\\s]+'));
    return parts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1);
    }).join();
  }
}
