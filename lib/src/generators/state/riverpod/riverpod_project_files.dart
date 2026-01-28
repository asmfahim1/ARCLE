import '../../../state_management.dart';
import '../../../templates/core/di_templates.dart';
import '../../../templates/core/localization_templates.dart';
import '../common_project_files.dart';

Map<String, String> buildRiverpodProjectFiles() {
  final files = buildCommonProjectFiles(StateManagement.riverpod);

  files.addAll({
    'assets/langs/en.json': LocalizationTemplates.enJson(),
    'assets/langs/bn.json': LocalizationTemplates.bnJson(),
    'lib/core/di/providers.dart': DiTemplates.riverpodProviders(),
  });

  return files;
}
