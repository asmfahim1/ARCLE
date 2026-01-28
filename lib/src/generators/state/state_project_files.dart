import '../../state_management.dart';
import 'bloc/bloc_project_files.dart';
import 'getx/getx_project_files.dart';
import 'riverpod/riverpod_project_files.dart';

Map<String, String> buildProjectFiles(StateManagement state) {
  switch (state) {
    case StateManagement.bloc:
      return buildBlocProjectFiles();
    case StateManagement.getx:
      return buildGetxProjectFiles();
    case StateManagement.riverpod:
      return buildRiverpodProjectFiles();
  }
}
