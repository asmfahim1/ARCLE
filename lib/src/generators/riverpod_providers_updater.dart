import 'dart:io';

import '../utils/string_helpers.dart';

/// Updates the core providers.dart file when a new Riverpod feature is created.
///
/// Adds feature-specific provider imports and exports so that all providers
/// can be accessed from a central location.
class RiverpodProvidersUpdater {
  RiverpodProvidersUpdater({required this.stdout, required this.stderr});

  final void Function(String message) stdout;
  final void Function(String message) stderr;

  void addFeatureProviders(Directory base, String featureName) {
    final providersFile = File(
      '${base.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
      '${Platform.pathSeparator}di${Platform.pathSeparator}providers.dart',
    );

    if (!providersFile.existsSync()) {
      stderr('providers.dart not found; skipping Riverpod provider update.');
      return;
    }

    var content = providersFile.readAsStringSync();
    const importMarker = '// arcle:feature_imports';
    const exportMarker = '// arcle:feature_exports';

    if (!content.contains(importMarker)) {
      stderr(
          'providers.dart markers not found; skipping Riverpod provider update.');
      return;
    }

    final snake = StringHelpers.snakeCase(featureName);

    // Add import for the feature providers
    final providerImport =
        "export '../../features/$snake/presentation/providers/${snake}_providers.dart';";

    if (!content.contains(providerImport)) {
      if (content.contains(exportMarker)) {
        content = content.replaceFirst(
          exportMarker,
          '$providerImport\n$exportMarker',
        );
      } else {
        content = content.replaceFirst(
          importMarker,
          "$importMarker\n$providerImport",
        );
      }
    }

    providersFile.writeAsStringSync(content);
    stdout('Updated: lib/core/di/providers.dart');
  }
}
