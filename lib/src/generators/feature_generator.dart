import 'dart:io';

import '../state_management.dart';
import '../templates/feature_templates.dart';
import '../ui/cli_ui.dart';
import '../utils/endpoint_injector.dart';
import '../utils/file_writer.dart';
import '../utils/localization_injector.dart';
import 'bloc_providers_updater.dart';
import 'route_updater.dart';

class FeatureGenerator {
  FeatureGenerator({
    required this.ui,
    required this.state,
    required this.force,
  });

  final CliUi ui;
  final StateManagement state;
  final bool force;

  void createFeature(Directory base, String featureName) {
    final safeName = _toSnake(featureName);
    ui.step('GENERATE', 'Creating feature structure...');
    final writer = FileWriter(
      force: force,
      onWrite: (path) => ui.itemCreated(path),
      onSkip: (path) => ui.itemSkipped(path),
    );

    final files = FeatureTemplates.files(state, safeName);
    ui.raw('');
    for (final entry in files.entries) {
      writer.write(base, entry.key, entry.value);
    }

    RouteUpdater(stdout: ui.log, stderr: ui.logError)
        .addFeatureRoute(base, safeName, state);

    if (state == StateManagement.bloc) {
      BlocProvidersUpdater(stdout: ui.log, stderr: ui.logError)
          .addFeatureBlocProvider(base, safeName);
    }

    EndpointInjector.inject(base, safeName);
    LocalizationInjector.inject(base, safeName, state);
    ui.raw('');
    ui.success('✨ Feature "$safeName" created with all layers!');
    ui.info('Includes: data/domain/presentation + routing + DI wiring');
  }

  String _toSnake(String input) {
    final normalized = input
        .trim()
        .replaceAll(RegExp(r'[\s\-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return normalized.toLowerCase();
  }
}
