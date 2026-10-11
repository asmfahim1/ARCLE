import '../../state_management.dart';
import 'bloc/bloc_project_files.dart';
import 'getx/getx_project_files.dart';
import 'riverpod/riverpod_project_files.dart';

Map<String, String> buildProjectFiles(
  StateManagement state, {
  String projectName = 'my_app',
  NetworkClient network = NetworkClient.dio,
}) {
  switch (state) {
    case StateManagement.bloc:
      return buildBlocProjectFiles(projectName: projectName, network: network);
    case StateManagement.getx:
      return buildGetxProjectFiles(projectName: projectName, network: network);
    case StateManagement.riverpod:
      return buildRiverpodProjectFiles(
        projectName: projectName,
        network: network,
      );
  }
}
