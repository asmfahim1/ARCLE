import 'dart:io';

class FileWriter {
  FileWriter({
    required this.force,
    required this.onWrite,
    required this.onSkip,
  });

  final bool force;
  final void Function(String path) onWrite;
  final void Function(String path) onSkip;

  void write(Directory base, String relativePath, String contents) {
    final normalized = relativePath.replaceAll('/', Platform.pathSeparator);
    final file = File('${base.path}${Platform.pathSeparator}$normalized');
    if (file.existsSync() && !force) {
      onSkip(relativePath);
      return;
    }
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
    onWrite(relativePath);
  }
}
