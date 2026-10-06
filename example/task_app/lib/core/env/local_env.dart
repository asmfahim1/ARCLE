import 'env.dart';

class LocalEnv implements Env {
  @override
  String get name => 'local';

  @override
  String get apiBaseUrl => 'https://local/jsonplaceholder.typicode.com';
}
