import 'dart:io';

/// Arrow-key interactive selector. Falls back to a numbered list when stdin is not a TTY.
class InteractiveMenu {
  static int? select(List<String> items, {String? prompt}) {
    if (items.isEmpty) return null;
    if (!stdin.hasTerminal) return _fallback(items, prompt: prompt);
    return _interactive(items, prompt: prompt);
  }

  static int? _interactive(List<String> items, {String? prompt}) {
    var selected = 0;

    if (prompt != null) stdout.writeln('  $prompt');
    stdout.writeln('  Use ↑↓ arrows and Enter to confirm:');
    stdout.writeln('');

    stdout.write('\x1b[?25l');
    _draw(items, selected);

    stdin.echoMode = false;
    stdin.lineMode = false;
    try {
      while (true) {
        final b = stdin.readByteSync();
        if (b == 27) {
          final b2 = stdin.readByteSync();
          if (b2 == 91) {
            final b3 = stdin.readByteSync();
            if (b3 == 65) {
              selected = (selected - 1 + items.length) % items.length;
              _redraw(items, selected);
            } else if (b3 == 66) {
              selected = (selected + 1) % items.length;
              _redraw(items, selected);
            }
          }
        } else if (b == 0xE0) {
          final b2 = stdin.readByteSync();
          if (b2 == 0x48) {
            selected = (selected - 1 + items.length) % items.length;
            _redraw(items, selected);
          } else if (b2 == 0x50) {
            selected = (selected + 1) % items.length;
            _redraw(items, selected);
          }
        } else if (b == 13 || b == 10) {
          stdout.writeln();
          return selected;
        } else if (b == 3) {
          stdout.writeln();
          return null;
        }
      }
    } finally {
      stdin.echoMode = true;
      stdin.lineMode = true;
      stdout.write('\x1b[?25h');
    }
  }

  static void _draw(List<String> items, int selected) {
    for (var i = 0; i < items.length; i++) {
      if (i == selected) {
        stdout.writeln('\x1b[32m  > ${items[i]}\x1b[0m');
      } else {
        stdout.writeln('    ${items[i]}');
      }
    }
  }

  static void _redraw(List<String> items, int selected) {
    stdout.write('\x1b[${items.length}A');
    _draw(items, selected);
  }

  static int? _fallback(List<String> items, {String? prompt}) {
    if (prompt != null) stdout.writeln('  $prompt');
    stdout.writeln('');
    for (var i = 0; i < items.length; i++) {
      stdout.writeln('  ${i + 1}. ${items[i]}');
    }
    stdout.writeln('');
    stdout.write('  Enter your choice (1-${items.length}): ');
    final input = stdin.readLineSync()?.trim();
    if (input == null || input.isEmpty) return null;
    final n = int.tryParse(input);
    if (n != null && n >= 1 && n <= items.length) return n - 1;
    return null;
  }
}
