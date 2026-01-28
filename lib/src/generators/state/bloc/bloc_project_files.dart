import '../../../state_management.dart';
import '../../../templates/core/bloc_providers_templates.dart';
import '../../../templates/core/di_templates.dart';
import '../../../templates/core/localization_templates.dart';
import '../common_project_files.dart';

Map<String, String> buildBlocProjectFiles() {
  final files = buildCommonProjectFiles(StateManagement.bloc);

  files.addAll({
    'assets/langs/en.json': LocalizationTemplates.enJson(),
    'assets/langs/bn.json': LocalizationTemplates.bnJson(),
    'lib/core/di/injection.dart': DiTemplates.blocInjection(),
    'lib/core/di/injectable_module.dart': DiTemplates.blocInjectableModule(),
    'lib/core/di/injection.config.dart': DiTemplates.blocInjectionConfig(),
    'lib/core/di/bloc_providers.dart': BlocProvidersTemplates.appBlocProviders(),
  });

  return files;
}
