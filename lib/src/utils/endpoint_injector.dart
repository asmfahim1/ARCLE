import 'dart:io';

import 'string_helpers.dart';

class EndpointInjector {
  static void inject(Directory base, String featureName) {
    final file = File(
      '${base.path}${Platform.pathSeparator}lib/core/utils/endpoints.dart',
    );
    if (!file.existsSync()) {
      return;
    }

    final content = file.readAsStringSync();
    const marker = '// arcle:feature_endpoints';
    if (!content.contains(marker)) return;

    final snake = StringHelpers.snakeCase(featureName);
    final camel = StringHelpers.camelCase(featureName);

    if (content.contains('${camel}List')) return;

    final block = '''
  // ----- $snake endpoints -----
  static const ${camel}List = '/$snake';
  static const ${camel}Detail = '/$snake/{id}';
  // ----- end $snake -----
''';

    final updated = content.replaceFirst(marker, '$block  $marker');
    file.writeAsStringSync(updated);
  }
}
