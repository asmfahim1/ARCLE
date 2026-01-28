class EnvTemplates {
  static String envBase() => '''
abstract class Env {
  String get name;
  String get apiBaseUrl;
}
''';

  static String envProd() => '''
import 'env.dart';

class ProdEnv implements Env {
  @override
  String get name => 'prod';

  @override
  String get apiBaseUrl => 'https://api.example.com';
}
''';

  static String envStag() => '''
import 'env.dart';

class StagEnv implements Env {
  @override
  String get name => 'stag';

  @override
  String get apiBaseUrl => 'https://staging-api.example.com';
}
''';

  static String envLocal() => '''
import 'env.dart';

class LocalEnv implements Env {
  @override
  String get name => 'local';

  @override
  String get apiBaseUrl => 'https://jsonplaceholder.typicode.com';
}
''';

  static String envFactory() => '''
import 'env.dart';
import 'local_env.dart';
import 'prod_env.dart';
import 'stag_env.dart';

class EnvFactory {
  // Swap this at build time or by flavor.
  static Env current() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'local');

    switch (flavor) {
      case 'prod':
        return ProdEnv();
      case 'stag':
        return StagEnv();
      default:
        return LocalEnv();
    }
  }

  // Compatibility helper for older templates.
  static Env getEnv() => current();
}
''';
}
