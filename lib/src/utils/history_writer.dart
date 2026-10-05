import 'dart:io';

import '../templates/project_docs_templates.dart';

/// Shared logic for appending work-tracking rows to `docs/HISTORY.md`
/// (root) and `lib/features/<feature>/docs/HISTORY.md` (per feature).
///
/// Used by both `arcle history add` and the feature generator, so a
/// feature scaffold and an AI agent's later work both show up the
/// same way.
class HistoryWriter {
  const HistoryWriter._();

  static bool appendRoot(
    Directory targetDir, {
    required String summary,
    String agent = 'arcle',
    String feature = '-',
    DateTime? at,
  }) {
    final file = File(
      '${targetDir.path}${Platform.pathSeparator}docs${Platform.pathSeparator}HISTORY.md',
    );
    if (!file.existsSync()) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(ProjectDocsTemplates.rootHistory('my_app'));
    }
    _insertRow(file, '| ${_today(at)} | $agent | $feature | $summary |');
    return true;
  }

  static bool appendFeature(
    Directory targetDir, {
    required String feature,
    required String summary,
    String agent = 'arcle',
    DateTime? at,
    bool createIfMissing = false,
  }) {
    final relative = 'lib/features/$feature/docs/${feature}_history.md';
    final file = File(
      '${targetDir.path}${Platform.pathSeparator}${relative.replaceAll('/', Platform.pathSeparator)}',
    );
    if (!file.existsSync()) {
      if (!createIfMissing) return false;
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(ProjectDocsTemplates.featureHistory(feature));
    }
    _insertRow(file, '| ${_today(at)} | $agent | $summary |');
    return true;
  }

  static void _insertRow(File file, String row) {
    final lines = file.readAsStringSync().split('\n');
    final headerIndex = lines.indexWhere(
      (line) => line.trim().startsWith('| ---'),
    );
    if (headerIndex == -1) {
      lines.add(row);
    } else {
      lines.insert(headerIndex + 1, row);
    }
    file.writeAsStringSync(lines.join('\n'));
  }

  static String _today(DateTime? at) {
    final now = at ?? DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
