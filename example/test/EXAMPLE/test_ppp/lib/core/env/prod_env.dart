import 'env.dart';

class ProdEnv implements Env {
  @override
  String get name => 'prod';

  @override
  String get apiBaseUrl => 'https://prod/jsonplaceholder.typicode.com';
}
