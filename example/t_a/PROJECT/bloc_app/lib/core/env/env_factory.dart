import 'env.dart';
import 'local_env.dart';
import 'prod_env.dart';
import 'stag_env.dart';

class EnvFactory {
  // Swap this at build time or by flavor.
  static Env current() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'stag');

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
