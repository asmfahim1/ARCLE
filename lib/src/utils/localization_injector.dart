import 'dart:convert';
import 'dart:io';

import '../state_management.dart';
import 'string_helpers.dart';

class LocalizationInjector {
  static void inject(
    Directory base,
    String featureName,
    StateManagement state,
  ) {
    if (state == StateManagement.getx) {
      _injectGetx(base, featureName);
      return;
    }

    _injectJson(base, 'assets/langs/en.json', featureName);
    _injectJson(base, 'assets/langs/bn.json', featureName);
  }

  static void _injectJson(
    Directory base,
    String relativePath,
    String featureName,
  ) {
    final file =
        File('${base.path}${Platform.pathSeparator}$relativePath');
    if (!file.existsSync()) {
      return;
    }

    final content = file.readAsStringSync();
    final Map<String, dynamic> jsonMap = jsonDecode(content);

    final snake = StringHelpers.snakeCase(featureName);
    final className = StringHelpers.pascalCase(featureName);
    final key = '${snake}_title';
    if (jsonMap.containsKey(key)) return;

    jsonMap[key] = className;
    final encoder = const JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(jsonMap));
  }

  static void _injectGetx(Directory base, String featureName) {
    final file = File(
      '${base.path}${Platform.pathSeparator}lib/core/localization/getx_localization.dart',
    );
    if (!file.existsSync()) {
      return;
    }

    final content = file.readAsStringSync();
    final snake = StringHelpers.snakeCase(featureName);
    final className = StringHelpers.pascalCase(featureName);
    final key = '${snake}_title';

    if (content.contains("'$key'")) return;

    const enMarker = '// arcle:keys_en';
    const bnMarker = '// arcle:keys_bn';
    if (!content.contains(enMarker) || !content.contains(bnMarker)) return;

    final enLine = "          '$key': '$className',\n";
    final bnLine = "          '$key': '$className',\n";

    final withEn = content.replaceFirst(enMarker, '$enLine          $enMarker');
    final withBn = withEn.replaceFirst(bnMarker, '$bnLine          $bnMarker');
    file.writeAsStringSync(withBn);
  }
}
