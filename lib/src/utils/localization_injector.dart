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

    // Inject into every JSON file found under assets/langs/
    final langsDir = Directory('${base.path}${Platform.pathSeparator}assets${Platform.pathSeparator}langs');
    if (!langsDir.existsSync()) return;

    for (final entity in langsDir.listSync()) {
      if (entity is File && entity.path.endsWith('.json')) {
        _injectJsonFile(entity, featureName);
      }
    }
  }

  static void _injectJsonFile(File file, String featureName) {
    if (!file.existsSync()) return;

    final content = file.readAsStringSync();
    late Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return;
    }

    final snake = StringHelpers.snakeCase(featureName);
    final className = StringHelpers.pascalCase(featureName);
    final key = '${snake}_title';
    if (jsonMap.containsKey(key)) return;

    jsonMap[key] = className;
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonMap));
  }

  static void _injectGetx(Directory base, String featureName) {
    final file = File(
      '${base.path}${Platform.pathSeparator}lib/core/localization/getx_localization.dart',
    );
    if (!file.existsSync()) return;

    final content = file.readAsStringSync();
    final snake = StringHelpers.snakeCase(featureName);
    final className = StringHelpers.pascalCase(featureName);
    final key = '${snake}_title';

    if (content.contains("'$key'")) return;

    // Inject into every // arcle:keys_<lang> marker in the file
    final markerPattern = RegExp(r'// arcle:keys_(\w+)');
    var updated = content;
    for (final match in markerPattern.allMatches(content)) {
      final marker = match.group(0)!;
      final line = "          '$key': '$className',\n";
      updated = updated.replaceFirst(marker, '$line          $marker');
    }

    if (updated != content) {
      file.writeAsStringSync(updated);
    }
  }
}
