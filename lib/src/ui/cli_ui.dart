import '../state_management.dart';
import '../utils/console.dart';

class CliUi {
  CliUi(this.console);

  final Console console;

  void showWelcome() {
    _banner(
      title: ' 🚀 ARCLE - Flutter Clean Architecture CLI',
      subtitle: 'Build scalable, production-ready apps with ease.',
      compact: true,
    );
    console.line('');
  }

  void showFirstRunGreeting() {
    _banner(
      title: ' 🚀 ARCLE - Flutter Clean Architecture CLI',
      subtitle: 'Your companion for clean, scalable Flutter apps.',
      compact: false,
    );
    console.line('');
    console.line(console.color(
        '  👋 Welcome! Looks like this is your first time using Arcle.',
        ConsoleColor.green));
    console.line('');
    console.line(console.bold('  💡 Quick Start:'));
    console.line(
        '     ${console.color('→', ConsoleColor.cyan)} arcle create my_app    Create a new Flutter project');
    console.line(
        '     ${console.color('→', ConsoleColor.cyan)} arcle feature login    Add a feature module');
    console.line(
        '     ${console.color('→', ConsoleColor.cyan)} arcle --help           See all commands');
    console.line('');
  }

  void showStateMenu() {
    console.line(
        console.bold('🎯 Select your preferred state management solution:'));
    console.line('');
    for (final item in StateManagement.values) {
      final number = console.color(
        item.option.toString().padLeft(2, ' '),
        ConsoleColor.cyan,
      );
      final icon = _stateIcon(item);
      final name = item.label.padRight(8);
      if(item.option != 2) {
        console.line('  $number. $icon $name │ ${_description(item)} abc');
      } else {
        console.line('  $number. $icon  $name │ ${_description(item)} def');
      }
    }
    console.line('');
    console.line(console.color(
        '  💡 Tip: Use --state 1|2|3 to skip this prompt in CI/CD',
        ConsoleColor.yellow));
    console.line('');
  }

  String _stateIcon(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return '🧱';
      case StateManagement.getx:
        return '⚡';
      case StateManagement.riverpod:
        return '🌊';
    }
  }

  void section(String title) {
    console.line('');
    console.line(console.bold('━━━ $title ━━━'));
  }

  void step(String label, String message) {
    console.line('  ${_tag(label, ConsoleColor.cyan)} $message');
  }

  void info(String message) {
    console.line('  ${console.color('ℹ', ConsoleColor.magenta)}  $message');
  }

  void success(String message) {
    console.line('  ${console.color('✓', ConsoleColor.green)}  $message');
  }

  void warn(String message) {
    console.line('  ${console.color('⚠', ConsoleColor.yellow)}  $message');
  }

  void error(String message) {
    console.error('  ${console.color('✗', ConsoleColor.red)}  $message');
  }

  void progress(String label, int percent,
      {String message = '', int width = 24}) {
    final clamped = percent.clamp(0, 100);
    final filled = ((clamped / 100) * width).round();
    final bar =
        '[${console.color('█' * filled, ConsoleColor.green)}${'░' * (width - filled)}]';
    final suffix = message.trim().isEmpty ? '' : ' → ${message.trim()}';
    final icon = clamped >= 100 ? '✓' : '◐';
    console.write(
        '\r  ${_tag(label, ConsoleColor.cyan)} $bar $clamped% $icon$suffix');
    if (clamped >= 100) {
      console.write('\n');
    }
  }

  void raw(String message) {
    console.line(message);
  }

  void itemCreated(String path) {
    console.line('    ${console.color('+', ConsoleColor.green)} $path');
  }

  void itemUpdated(String path) {
    console.line('    ${console.color('~', ConsoleColor.cyan)} $path');
  }

  void itemSkipped(String path) {
    console.line(
        '    ${console.color('○', ConsoleColor.yellow)} $path ${console.color('(exists)', ConsoleColor.yellow)}');
  }

  void nextSteps(List<String> steps, {String? projectPath}) {
    console.line('');
    console.line(console.bold('🎯 What\'s Next?'));
    console.line('');
    for (var i = 0; i < steps.length; i++) {
      console.line(
          '   ${console.color('${i + 1})', ConsoleColor.cyan)} ${steps[i]}');
    }
    console.line('');
    if (projectPath != null) {
      console.line(console.color(
          '   📖 Check documentation/ for architecture overview',
          ConsoleColor.yellow));
      console.line('');
    }
  }

  void log(String message) {
    if (message.startsWith('Created: ')) {
      itemCreated(message.substring('Created: '.length));
      return;
    }
    if (message.startsWith('Updated: ')) {
      itemUpdated(message.substring('Updated: '.length));
      return;
    }
    if (message.startsWith('Skipped (exists): ')) {
      itemSkipped(message.substring('Skipped (exists): '.length));
      return;
    }
    if (message.toLowerCase().contains('skipping')) {
      warn(message);
      return;
    }
    raw(message);
  }

  void logError(String message) {
    if (message.toLowerCase().contains('skipping') ||
        message.startsWith('Skipped')) {
      warn(message);
      return;
    }
    error(message);
  }

  String _description(StateManagement state) {
    switch (state) {
      case StateManagement.bloc:
        return 'Event-driven, highly testable, enterprise-ready';
      case StateManagement.getx:
        return 'Lightweight, reactive, zero configuration';
      case StateManagement.riverpod:
        return 'Type-safe, no context needed, highly flexible';
    }
  }

  void _banner({
    required String title,
    String? subtitle,
    required bool compact,
  }) {
    final border = console.color('║', ConsoleColor.cyan);
    console.line('');
    console.line(console.color(
        '  ╔══════════════════════════════════════════════════════════╗',
        ConsoleColor.cyan));
    console.line('  $border  ${console.bold(title.padRight(55))} $border');
    if (subtitle != null && subtitle.trim().isNotEmpty) {
      console.line('  $border  ${subtitle.padRight(56)}$border');
    }
    console.line(console.color(
        '  ╚══════════════════════════════════════════════════════════╝',
        ConsoleColor.cyan));
  }

  String _tag(String label, ConsoleColor color) {
    return console.color('[$label]', color);
  }
}
