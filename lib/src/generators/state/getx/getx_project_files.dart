import '../../../state_management.dart';
import '../../../templates/core/localization_templates.dart';
import '../common_project_files.dart';

Map<String, String> buildGetxProjectFiles() {
  final files = buildCommonProjectFiles(StateManagement.getx);

  files.addAll({
    'lib/core/localization/getx_localization.dart':
        LocalizationTemplates.getxLocalization(),
    'assets/langs/.gitkeep': '',
  });

  return files;
}
