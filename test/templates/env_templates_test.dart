import 'package:arcle/src/templates/core/env_templates.dart';
import 'package:test/test.dart';

void main() {
  group('EnvTemplates', () {
    test('envFile generates complete multi-environment configuration', () {
      final content = EnvTemplates.envFile();
      expect(content, contains('FLAVOR=stag'));
      expect(
        content,
        contains('PROD_API_BASE_URL=https://jsonplaceholder.typicode.com'),
      );
      expect(content, contains('PROD_API_KEY=your_production_api_key_here'));
      expect(
        content,
        contains('STAG_API_BASE_URL=https://jsonplaceholder.typicode.com'),
      );
      expect(content, contains('STAG_API_KEY=your_staging_api_key_here'));
      expect(content, contains('LOCAL_API_BASE_URL=http://10.0.2.2:3000'));
      expect(content, contains('LOCAL_API_KEY=your_local_dev_key_here'));
    });

    test(
      'envExampleFile generates template configuration with placeholder keys',
      () {
        final content = EnvTemplates.envExampleFile();
        expect(content, contains('FLAVOR=stag'));
        expect(content, contains('PROD_API_BASE_URL=https://api.example.com'));
        expect(
          content,
          contains('STAG_API_BASE_URL=https://staging.api.example.com'),
        );
        expect(content, contains('LOCAL_API_BASE_URL=http://10.0.2.2:3000'));
      },
    );

    test('prodEnv reads PROD_API_BASE_URL from environment', () {
      final code = EnvTemplates.envProd();
      expect(
        code,
        contains("String.fromEnvironment(\n        'PROD_API_BASE_URL'"),
      );
      expect(
        code,
        contains("defaultValue: 'https://jsonplaceholder.typicode.com'"),
      );
    });

    test('stagEnv reads STAG_API_BASE_URL from environment', () {
      final code = EnvTemplates.envStag();
      expect(
        code,
        contains("String.fromEnvironment(\n        'STAG_API_BASE_URL'"),
      );
      expect(
        code,
        contains("defaultValue: 'https://jsonplaceholder.typicode.com'"),
      );
    });

    test('localEnv reads LOCAL_API_BASE_URL from environment', () {
      final code = EnvTemplates.envLocal();
      expect(
        code,
        contains("String.fromEnvironment(\n        'LOCAL_API_BASE_URL'"),
      );
      expect(code, contains("defaultValue: 'http://10.0.2.2:3000'"));
    });

    test('envFactory resolves FLAVOR and handles prod, stag, and local', () {
      final code = EnvTemplates.envFactory();
      expect(
        code,
        contains(
          "const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'stag');",
        ),
      );
      expect(code, contains("case 'prod':\n        return ProdEnv();"));
      expect(code, contains("case 'stag':\n        return StagEnv();"));
      expect(code, contains("case 'local':\n        return LocalEnv();"));
    });
  });
}
