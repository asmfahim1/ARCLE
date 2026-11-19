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
  String get apiBaseUrl => const String.fromEnvironment(
        'PROD_API_BASE_URL',
        defaultValue: 'https://jsonplaceholder.typicode.com',
      );
}
''';

  static String envStag() => '''
import 'env.dart';

class StagEnv implements Env {
  @override
  String get name => 'stag';

  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'STAG_API_BASE_URL',
        defaultValue: 'https://jsonplaceholder.typicode.com',
      );
}
''';

  static String envLocal() => '''
import 'env.dart';

class LocalEnv implements Env {
  @override
  String get name => 'local';

  @override
  String get apiBaseUrl => const String.fromEnvironment(
        'LOCAL_API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000',
      );
}
''';

  static String envFactory() => '''
import 'env.dart';
import 'local_env.dart';
import 'prod_env.dart';
import 'stag_env.dart';

class EnvFactory {
  // Swap this at build time or by flavor via --dart-define=FLAVOR=prod|stag|local
  static Env current() {
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'stag');

    switch (flavor) {
      case 'prod':
        return ProdEnv();
      case 'stag':
        return StagEnv();
      case 'local':
        return LocalEnv();
      default:
        return StagEnv();
    }
  }

  // Compatibility helper for older templates.
  static Env getEnv() => current();
}
''';

  static String envFile() => '''
# ─────────────────────────────────────────────────────────────────────────────
# ARCLE Application Environment Configuration
# DO NOT COMMIT THIS FILE TO VERSION CONTROL
# ─────────────────────────────────────────────────────────────────────────────

# Active Flavor: prod | stag | local
FLAVOR=stag

# ── Production Environment ──────────────────────────────────────────────────
PROD_API_BASE_URL=https://jsonplaceholder.typicode.com
PROD_API_KEY=your_production_api_key_here

# ── Staging Environment ─────────────────────────────────────────────────────
STAG_API_BASE_URL=https://jsonplaceholder.typicode.com
STAG_API_KEY=your_staging_api_key_here

# ── Local Development Environment ───────────────────────────────────────────
LOCAL_API_BASE_URL=http://10.0.2.2:3000
LOCAL_API_KEY=your_local_dev_key_here
''';

  static String envExampleFile() => '''
# ─────────────────────────────────────────────────────────────────────────────
# ARCLE Environment Template
# Copy this file to .env and fill in your actual credentials.
# ─────────────────────────────────────────────────────────────────────────────

FLAVOR=stag

# Production Environment
PROD_API_BASE_URL=https://api.example.com
PROD_API_KEY=your_production_api_key

# Staging Environment
STAG_API_BASE_URL=https://staging.api.example.com
STAG_API_KEY=your_staging_api_key

# Local Environment
LOCAL_API_BASE_URL=http://10.0.2.2:3000
LOCAL_API_KEY=your_local_key
''';
}
