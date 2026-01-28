import 'dart:io';

import '../ui/cli_ui.dart';

class FirstRunTracker {
  FirstRunTracker(this.ui);

  final CliUi ui;

  void greetOnce() {
    final file = File(_markerPath());
    if (file.existsSync()) return;

    file.parent.createSync(recursive: true);
    file.writeAsStringSync(DateTime.now().toIso8601String());
    ui.showFirstRunGreeting();
  }

  String _markerPath() {
    final env = Platform.environment;
    final appData = env['APPDATA'];
    if (appData != null && appData.trim().isNotEmpty) {
      return '$appData${Platform.pathSeparator}arcle${Platform.pathSeparator}first_run';
    }
    final home = env['HOME'] ?? env['USERPROFILE'];
    final base = (home != null && home.trim().isNotEmpty)
        ? home
        : Directory.current.path;
    return '$base${Platform.pathSeparator}.arcle${Platform.pathSeparator}first_run';
  }
}
