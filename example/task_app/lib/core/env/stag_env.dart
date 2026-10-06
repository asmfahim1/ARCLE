import 'env.dart';

class StagEnv implements Env {
  @override
  String get name => 'stag';

  @override
  String get apiBaseUrl => 'https://jsonplaceholder.typicode.com';
}
