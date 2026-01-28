import 'dart:io';

class Console {
  Console({bool? enableColor}) : _enableColor = enableColor ?? stdout.supportsAnsiEscapes;

  final bool _enableColor;

  void line(String message) => stdout.writeln(message);
  void error(String message) => stderr.writeln(message);
  void write(String message) => stdout.write(message);
  void flush() => stdout.flush();

  String? prompt(String message) {
    stdout.write(message);
    return stdin.readLineSync();
  }

  String color(String message, ConsoleColor color) {
    if (!_enableColor) return message;
    return '${color.code}$message${ConsoleColor.reset.code}';
  }

  String bold(String message) {
    if (!_enableColor) return message;
    return '${ConsoleColor.bold.code}$message${ConsoleColor.reset.code}';
  }
}

enum ConsoleColor {
  reset('\x1B[0m'),
  bold('\x1B[1m'),
  red('\x1B[31m'),
  cyan('\x1B[36m'),
  green('\x1B[32m'),
  yellow('\x1B[33m'),
  magenta('\x1B[35m');

  const ConsoleColor(this.code);
  final String code;
}
