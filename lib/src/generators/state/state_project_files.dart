import '../../state_management.dart';
import 'bloc/bloc_project_files.dart';
import 'getx/getx_project_files.dart';
import 'riverpod/riverpod_project_files.dart';

Map<String, String> buildProjectFiles(
  StateManagement state, {
  String projectName = 'my_app',
}) {
  switch (state) {
    case StateManagement.bloc:
      return buildBlocProjectFiles(projectName: projectName);
    case StateManagement.getx:
      return buildGetxProjectFiles(projectName: projectName);
    case StateManagement.riverpod:
      return buildRiverpodProjectFiles(projectName: projectName);
  }
}
