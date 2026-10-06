import 'package:intl/intl.dart';

/// Shared date and time formatter for app-wide UX formatting.
///
/// Backend APIs usually return date values as strings. This helper accepts:
/// - ISO8601 string dates
/// - [DateTime]
/// - Unix timestamps in seconds or milliseconds
///
/// Usage:
/// ```dart
/// final createdAt = formatter.date('2026-03-20T15:30:00Z');
/// final localTime = formatter.time('2026-03-20T15:30:00Z');
/// final custom = formatter.format('2026-03-20T15:30:00Z', pattern: 'dd MMM yyyy, hh:mm a');
/// final ago = formatter.timeAgo('2026-03-20T15:30:00Z');
/// ```
class DateFormatter {
  const DateFormatter();

  /// Global ready-to-use instance for convenience.
  static const DateFormatter instance = DateFormatter();

  /// Converts supported input into local [DateTime].
  DateTime? toLocalDateTime(dynamic input) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  /// Converts supported input into UTC [DateTime].
  DateTime? toUtcDateTime(dynamic input) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  /// Formats input into a custom pattern.
  String format(
    dynamic input, {
    String pattern = 'dd MMM yyyy',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    final date = _resolve(input, toLocal: toLocal);
    if (date == null) return fallback;
    return DateFormat(pattern, locale).format(date);
  }

  /// Example: 20 Mar 2026
  String date(
    dynamic input, {
    String pattern = 'dd MMM yyyy',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: pattern,
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: 03:45 PM
  String time(
    dynamic input, {
    String pattern = 'hh:mm a',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: pattern,
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: 20 Mar 2026, 03:45 PM
  String dateTime(
    dynamic input, {
    String pattern = 'dd MMM yyyy, hh:mm a',
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: pattern,
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: Mar 20, 2026
  String shortDate(
    dynamic input, {
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: 'MMM dd, yyyy',
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: Friday, 20 Mar 2026
  String fullDate(
    dynamic input, {
    bool toLocal = true,
    String fallback = '',
    String? locale,
  }) {
    return format(
      input,
      pattern: 'EEEE, dd MMM yyyy',
      toLocal: toLocal,
      fallback: fallback,
      locale: locale,
    );
  }

  /// Example: Today, Yesterday, or a date fallback.
  String uxDate(
    dynamic input, {
    String fallback = '',
    String? locale,
  }) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return fallback;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == -1) return 'Yesterday';
    if (difference == 1) return 'Tomorrow';
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  /// Example: 2m ago, 5h ago, 3d ago
  String timeAgo(dynamic input, {String fallback = ''}) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return fallback;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return inFuture(date, fallback: fallback);
    }
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

  /// Example: In 5m, In 2h, In 3d
  String inFuture(dynamic input, {String fallback = ''}) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return fallback;

    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return timeAgo(date, fallback: fallback);
    }
    if (difference.inSeconds < 60) return 'In a moment';
    if (difference.inMinutes < 60) return 'In ${difference.inMinutes}m';
    if (difference.inHours < 24) return 'In ${difference.inHours}h';
    if (difference.inDays < 7) return 'In ${difference.inDays}d';
    return 'In ${DateFormat('dd MMM yyyy').format(date)}';
  }

  bool isToday(dynamic input) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return false;
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }

  bool isPast(dynamic input) {
    final date = _resolve(input, toLocal: true);
    if (date == null) return false;
    return date.isBefore(DateTime.now());
  }

  int? differenceInDays(dynamic from, dynamic to) {
    final start = _resolve(from, toLocal: true);
    final end = _resolve(to, toLocal: true);
    if (start == null || end == null) return null;
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return normalizedEnd.difference(normalizedStart).inDays;
  }

  DateTime? _resolve(dynamic input, {required bool toLocal}) {
    final parsed = _parse(input);
    if (parsed == null) return null;
    if (toLocal) {
      return parsed.isUtc ? parsed.toLocal() : parsed;
    }
    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  DateTime? _parse(dynamic input) {
    if (input == null) return null;

    if (input is DateTime) {
      return input;
    }

    if (input is int) {
      return _fromTimestamp(input);
    }

    if (input is String) {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return null;

      final timestamp = int.tryParse(trimmed);
      if (timestamp != null) {
        return _fromTimestamp(timestamp);
      }

      return DateTime.tryParse(trimmed);
    }

    return null;
  }

  DateTime _fromTimestamp(int timestamp) {
    final isMilliseconds = timestamp.abs() > 9999999999;
    return DateTime.fromMillisecondsSinceEpoch(
      isMilliseconds ? timestamp : timestamp * 1000,
      isUtc: true,
    );
  }
}

const formatter = DateFormatter.instance;
