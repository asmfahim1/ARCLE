import '../../../state_management.dart';
import '../../../templates/core/localization_templates.dart';
import '../common_project_files.dart';

Map<String, String> buildGetxProjectFiles({
  String projectName = 'my_app',
  NetworkClient network = NetworkClient.dio,
}) {
  final files = buildCommonProjectFiles(
    StateManagement.getx,
    projectName: projectName,
    network: network,
  );

  files.addAll({
    'lib/core/localization/getx_localization.dart':
        LocalizationTemplates.getxLocalization(),
    'assets/langs/.gitkeep': '',
  });

  return files;
}
