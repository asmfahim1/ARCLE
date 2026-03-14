import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Professional-grade logger with structured output and log levels.
/// 
/// Features:
/// - Color-coded output in debug mode
/// - Structured log format with timestamps
/// - Stack trace support for errors
/// - Production-safe (no console output in release)
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in', tag: 'AUTH');
/// AppLogger.error('API failed', error: e, stackTrace: stack);
/// ```
class AppLogger {
  static const String _defaultTag = 'APP';
  
  static bool _enableLogging = kDebugMode;
  
  /// Enable or disable logging globally
  static void setEnabled(bool enabled) => _enableLogging = enabled;
  
  /// Log informational messages
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }
  
  /// Log debug messages (development only)
  static void debug(String message, {String? tag, Object? data}) {
    _log(LogLevel.debug, message, tag: tag, data: data);
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag, Object? data}) {
    _log(LogLevel.warning, message, tag: tag, data: data);
  }
  
  /// Log error messages with optional exception and stack trace
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }
  
  /// Log API requests/responses
  static void network(String message, {String? tag, Object? data}) {
    _log(LogLevel.network, message, tag: tag ?? 'NETWORK', data: data);
  }
  
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    if (!_enableLogging) return;
    
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final logTag = tag ?? _defaultTag;
    final prefix = '${level.emoji} [$timestamp] [$logTag]';
    
    final buffer = StringBuffer();
    buffer.writeln('$prefix $message');
    
    if (data != null) {
      buffer.writeln('  └─ Data: $data');
    }
    
    if (error != null) {
      buffer.writeln('  └─ Error: $error');
    }
    
    if (stackTrace != null) {
      buffer.writeln('  └─ StackTrace:');
      final frames = stackTrace.toString().split('\n').take(5);
      for (final frame in frames) {
        buffer.writeln('       $frame');
      }
    }
    
    developer.log(
      buffer.toString(),
      name: logTag,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
    
    // Also print to console in debug mode for visibility
    if (kDebugMode) {
      // ignore: avoid_print
      print('${level.color}${buffer.toString()}\x1B[0m');
    }
  }
}

enum LogLevel {
  debug(500, '💬', '\x1B[37m'),   // White
  info(800, 'ℹ️', '\x1B[34m'),    // Blue
  warning(900, '⚠️', '\x1B[33m'), // Yellow
  error(1000, '❌', '\x1B[31m'),        // Red
  network(700, '🌐', '\x1B[36m'); // Cyan

  const LogLevel(this.value, this.emoji, this.color);
  final int value;
  final String emoji;
  final String color;
}
