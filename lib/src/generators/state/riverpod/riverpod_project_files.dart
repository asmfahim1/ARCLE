import '../../../state_management.dart';
import '../../../templates/core/di_templates.dart';
import '../../../templates/core/localization_templates.dart';
import '../common_project_files.dart';

/// Builds all Riverpod-specific project files in addition to common files.
///
/// This includes:
/// - Core providers configuration
/// - Localization files
/// - Riverpod-specific DI setup
Map<String, String> buildRiverpodProjectFiles() {
  final files = buildCommonProjectFiles(StateManagement.riverpod);

  files.addAll({
    // Localization JSON files
    'assets/langs/en.json': LocalizationTemplates.enJson(),
    'assets/langs/bn.json': LocalizationTemplates.bnJson(),

    // Core DI providers
    'lib/core/di/providers.dart': DiTemplates.riverpodProviders(),

    // Riverpod-specific utilities
    'lib/core/utils/provider_logger.dart': _providerLogger(),
  });

  return files;
}

/// Provider observer for logging provider lifecycle events in debug mode.
String _providerLogger() => '''
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger.dart';

/// Observer that logs provider lifecycle events for debugging.
/// 
/// Usage:
/// ```dart
/// ProviderScope(
///   observers: [if (kDebugMode) ProviderLogger()],
///   child: const App(),
/// )
/// ```
class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
        'Provider added: \${provider.name ?? provider.runtimeType}',
      );
    }
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
        'Provider updated: \${provider.name ?? provider.runtimeType}',
      );
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    if (kDebugMode) {
      AppLogger.debug(
        'Provider disposed: \${provider.name ?? provider.runtimeType}',
      );
    }
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Provider failed: \${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
''';
