import 'dart:io';

import '../state_management.dart';

class RouteUpdater {
  RouteUpdater({required this.stdout, required this.stderr});

  final void Function(String message) stdout;
  final void Function(String message) stderr;

  void addFeatureRoute(Directory base, String featureName, StateManagement state) {
    if (state == StateManagement.getx) {
      _addGetxRoute(base, featureName);
      return;
    }
    _addAppRouteConstant(base, featureName);
    _addAppRouterRoute(base, featureName);
  }

  void _addAppRouteConstant(Directory base, String featureName) {
    final routesFile = File(
      '${base.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
      '${Platform.pathSeparator}route_handler${Platform.pathSeparator}app_routes.dart',
    );
    if (!routesFile.existsSync()) {
      return;
    }

    final content = routesFile.readAsStringSync();
    const marker = '// arcle:feature_routes';
    if (!content.contains(marker)) return;

    final name = _camelCase(_pascalCase(featureName));
    final line = "  static const $name = '/$featureName';";
    if (content.contains(line)) return;

    final updated = content.replaceFirst(marker, '$line\n  $marker');
    routesFile.writeAsStringSync(updated);
    stdout('Updated: lib/core/route_handler/app_routes.dart');
  }

  void _addAppRouterRoute(Directory base, String featureName) {
    final routerFile = File(
      '${base.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
      '${Platform.pathSeparator}route_handler${Platform.pathSeparator}app_router.dart',
    );

    if (!routerFile.existsSync()) {
      stderr('app_router.dart not found; skipping router update.');
      return;
    }

    var content = routerFile.readAsStringSync();
    const importMarker = '// arcle:feature_imports';
    const caseMarker = '// arcle:feature_cases';
    if (!content.contains(importMarker) || !content.contains(caseMarker)) {
      stderr('app_router.dart markers not found; skipping router update.');
      return;
    }

    final className = _pascalCase(featureName);
    final routeName = _camelCase(className);
    final importLine =
        "import '../../features/$featureName/presentation/pages/${featureName}_screen.dart';";
    final caseLines = '''
      case AppRoutes.$routeName:
        return MaterialPageRoute(builder: (_) => const ${className}Screen());''';

    if (!content.contains(importLine)) {
      content = content.replaceFirst(
        importMarker,
        '$importMarker\n$importLine',
      );
    }

    if (!content.contains(caseLines)) {
      content = content.replaceFirst(
        caseMarker,
        '$caseLines\n      $caseMarker',
      );
    }

    routerFile.writeAsStringSync(content);
    stdout('Updated: lib/core/route_handler/app_router.dart');
  }

  void _addGetxRoute(Directory base, String featureName) {
    final routesFile = File(
      '${base.path}${Platform.pathSeparator}lib${Platform.pathSeparator}core'
      '${Platform.pathSeparator}route_handler${Platform.pathSeparator}getx_routes.dart',
    );

    if (!routesFile.existsSync()) {
      stderr('getx_routes.dart not found; skipping route update.');
      return;
    }

    final className = _pascalCase(featureName);
    final importLine =
        "import '../../features/$featureName/presentation/pages/${featureName}_screen.dart';";
    final bindingImport =
        "import '../../features/$featureName/presentation/bindings/${featureName}_binding.dart';";
    final entryLine =
        "  GetPage(name: '/$featureName', page: () => ${className}Screen(), binding: ${className}Binding()),";

    var content = routesFile.readAsStringSync();

    if (!content.contains(importLine)) {
      content = content.replaceFirst(
        '// arcle:getx_imports',
        '// arcle:getx_imports\n$importLine\n$bindingImport',
      );
    }

    if (!content.contains(entryLine)) {
      content = content.replaceFirst(
        '// arcle:getx_pages',
        '// arcle:getx_pages\n$entryLine',
      );
    }

    routesFile.writeAsStringSync(content);
    stdout('Updated: lib/core/route_handler/getx_routes.dart');
  }

  String _pascalCase(String input) {
    final parts = input.split(RegExp(r'[\\/_\\-\\s]+'));
    return parts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1);
    }).join();
  }

  String _camelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }
}
