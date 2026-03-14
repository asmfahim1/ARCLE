import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:injectable/injectable.dart';

/// Comprehensive notification service for local and scheduled notifications.
/// 
/// Usage:
/// ```dart
/// await notificationService.init();
/// await notificationService.show(title: 'Hello', body: 'World');
/// await notificationService.scheduleAt(title: 'Reminder', body: 'Time!', scheduledAt: time);
/// ```
@lazySingleton

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  
  void Function(String? payload)? _onNotificationTapped;
  
  static const String defaultChannel = 'default';
  static const String reminderChannel = 'reminders';
  
  int _notificationIdCounter = 0;
  int get _nextId => ++_notificationIdCounter;

  Future<void> init({void Function(String? payload)? onNotificationTapped}) async {
    _onNotificationTapped = onNotificationTapped;
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    
    await _createChannels();
  }
  
  Future<void> _createChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          defaultChannel,
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          reminderChannel,
          'Reminders',
          description: 'Scheduled reminders',
          importance: Importance.high,
        ),
      );
    }
  }
  
  void _onNotificationResponse(NotificationResponse response) {
    _onNotificationTapped?.call(response.payload);
  }

  Future<void> show({
    int? id,
    required String title,
    required String body,
    String? payload,
    String channel = defaultChannel,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel == defaultChannel ? 'General Notifications' : 'Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(id ?? _nextId, title, body, details, payload: payload);
  }
  
  Future<void> showWithData({
    int? id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await show(id: id, title: title, body: body, payload: jsonEncode(data));
  }

  Future<void> scheduleAt({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledAt, tz.local);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(reminderChannel, 'Reminders'),
      iOS: DarwinNotificationDetails(),
    );
    
    await _plugin.zonedSchedule(
      id ?? _nextId,
      title,
      body,
      tzTime,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleDaily({
    int? id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    const details = NotificationDetails(
      android: AndroidNotificationDetails(reminderChannel, 'Reminders'),
      iOS: DarwinNotificationDetails(),
    );
    
    await _plugin.zonedSchedule(
      id ?? _nextId,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
  Future<List<PendingNotificationRequest>> getPending() => _plugin.pendingNotificationRequests();
}
