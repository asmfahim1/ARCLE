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
  });

  return files;
}
