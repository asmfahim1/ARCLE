import '../../state_management.dart';

class ServicesTemplates {
  static String sessionManager(StateManagement state) {
    if (state == StateManagement.bloc) {
      return _blocSessionManager();
    }
    return _simpleSessionManager();
  }

  static String prefManager(StateManagement state) {
    if (state == StateManagement.bloc) {
      return '''
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Type-safe preference manager with encryption support placeholder.
/// 
/// Usage:
/// ```dart
/// // Save
/// prefManager.saveString(PrefKeys.userName, 'John');
/// 
/// // Retrieve
/// final name = prefManager.getString(PrefKeys.userName);
/// ```
@injectable
class PrefManager {
  final SharedPreferences _prefs;

  PrefManager(this._prefs);

  // String operations
  void saveString(String key, String? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, value);
    }
  }
  
  String? getString(String key) => _prefs.getString(key);
  
  String getStringValue(String key, {String defaultValue = ''}) => 
      _prefs.getString(key) ?? defaultValue;

  // Int operations
  void saveInt(String key, int? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setInt(key, value);
    }
  }
  
  int? getInt(String key) => _prefs.getInt(key);
  
  int getIntValue(String key, {int defaultValue = 0}) => 
      _prefs.getInt(key) ?? defaultValue;

  // Bool operations
  void saveBool(String key, bool value) => _prefs.setBool(key, value);
  
  bool? getBool(String key) => _prefs.getBool(key);
  
  bool getBoolValue(String key, {bool defaultValue = false}) => 
      _prefs.getBool(key) ?? defaultValue;

  // Double operations
  void saveDouble(String key, double? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setDouble(key, value);
    }
  }
  
  double? getDouble(String key) => _prefs.getDouble(key);
  
  double getDoubleValue(String key, {double defaultValue = 0.0}) => 
      _prefs.getDouble(key) ?? defaultValue;

  // List<String> operations
  void saveStringList(String key, List<String>? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setStringList(key, value);
    }
  }
  
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  
  // JSON object operations
  void saveJson(String key, Map<String, dynamic>? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, jsonEncode(value));
    }
  }
  
  Map<String, dynamic>? getJson(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Key management
  Future<void> remove(String key) async => _prefs.remove(key);
  
  bool containsKey(String key) => _prefs.containsKey(key);
  
  Set<String> get keys => _prefs.getKeys();
  
  Future<void> clear() async => _prefs.clear();
}

/// Centralized preference keys to avoid typos
class PrefKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String fcmToken = 'fcm_token';
  static const String lastSyncTime = 'last_sync_time';
}
''';
    }

    return '''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Type-safe preference manager with async operations.
/// 
/// Usage:
/// ```dart
/// final prefManager = PrefManager();
/// await prefManager.saveString(PrefKeys.userName, 'John');
/// final name = await prefManager.getString(PrefKeys.userName);
/// ```
class PrefManager {
  SharedPreferences? _prefs;
  
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // String operations
  Future<void> saveString(String key, String? value) async {
    if (value == null) {
      await (await prefs).remove(key);
    } else {
      await (await prefs).setString(key, value);
    }
  }
  
  Future<String?> getString(String key) async => (await prefs).getString(key);
  
  Future<String> getStringValue(String key, {String defaultValue = ''}) async => 
      (await prefs).getString(key) ?? defaultValue;

  // Int operations
  Future<void> saveInt(String key, int? value) async {
    if (value == null) {
      await (await prefs).remove(key);
    } else {
      await (await prefs).setInt(key, value);
    }
  }
  
  Future<int?> getInt(String key) async => (await prefs).getInt(key);
  
  Future<int> getIntValue(String key, {int defaultValue = 0}) async => 
      (await prefs).getInt(key) ?? defaultValue;

  // Bool operations
  Future<void> saveBool(String key, bool value) async => 
      (await prefs).setBool(key, value);
  
  Future<bool?> getBool(String key) async => (await prefs).getBool(key);
  
  Future<bool> getBoolValue(String key, {bool defaultValue = false}) async => 
      (await prefs).getBool(key) ?? defaultValue;

  // Double operations
  Future<void> saveDouble(String key, double? value) async {
    if (value == null) {
      await (await prefs).remove(key);
    } else {
      await (await prefs).setDouble(key, value);
    }
  }
  
  Future<double?> getDouble(String key) async => (await prefs).getDouble(key);
  
  Future<double> getDoubleValue(String key, {double defaultValue = 0.0}) async => 
      (await prefs).getDouble(key) ?? defaultValue;

  // List<String> operations
  Future<void> saveStringList(String key, List<String>? value) async {
    if (value == null) {
      await (await prefs).remove(key);
    } else {
      await (await prefs).setStringList(key, value);
    }
  }
  
  Future<List<String>?> getStringList(String key) async => 
      (await prefs).getStringList(key);
  
  // JSON object operations
  Future<void> saveJson(String key, Map<String, dynamic>? value) async {
    if (value == null) {
      await (await prefs).remove(key);
    } else {
      await (await prefs).setString(key, jsonEncode(value));
    }
  }
  
  Future<Map<String, dynamic>?> getJson(String key) async {
    final str = (await prefs).getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Key management
  Future<void> remove(String key) async => (await prefs).remove(key);
  
  Future<bool> containsKey(String key) async => (await prefs).containsKey(key);
  
  Future<Set<String>> get keys async => (await prefs).getKeys();
  
  Future<void> clear() async => (await prefs).clear();
}

/// Centralized preference keys to avoid typos
class PrefKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstLaunch = 'is_first_launch';
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String fcmToken = 'fcm_token';
  static const String lastSyncTime = 'last_sync_time';
}
''';
  }

  static String _blocSessionManager() => '''
import 'package:injectable/injectable.dart';
import 'pref_manager.dart';

/// Manages user authentication session and tokens.
/// 
/// Features:
/// - Secure token storage
/// - Session state tracking
/// - Token refresh support
/// - User data caching
/// 
/// Usage:
/// ```dart
/// // Login
/// await sessionManager.saveSession(
///   accessToken: token,
///   refreshToken: refresh,
///   userId: user.id,
/// );
/// 
/// // Check auth
/// if (sessionManager.isAuthenticated) { ... }
/// 
/// // Logout
/// await sessionManager.clearSession();
/// ```
@injectable
class SessionManager {
  final PrefManager _prefManager;

  SessionManager(this._prefManager);

  // Token getters
  String? get accessToken => _prefManager.getString(PrefKeys.accessToken);
  String? get refreshToken => _prefManager.getString(PrefKeys.refreshToken);
  
  // Auth state
  bool get isAuthenticated => 
      _prefManager.getBoolValue(PrefKeys.isLoggedIn) && 
      accessToken != null && 
      accessToken!.isNotEmpty;
  
  // User info
  String? get userId => _prefManager.getString(PrefKeys.userId);
  String? get userEmail => _prefManager.getString(PrefKeys.userEmail);
  String? get userName => _prefManager.getString(PrefKeys.userName);

  /// Save complete session after login
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    String? name,
  }) async {
    _prefManager.saveString(PrefKeys.accessToken, accessToken);
    if (refreshToken != null) {
      _prefManager.saveString(PrefKeys.refreshToken, refreshToken);
    }
    if (userId != null) {
      _prefManager.saveString(PrefKeys.userId, userId);
    }
    if (email != null) {
      _prefManager.saveString(PrefKeys.userEmail, email);
    }
    if (name != null) {
      _prefManager.saveString(PrefKeys.userName, name);
    }
    _prefManager.saveBool(PrefKeys.isLoggedIn, true);
  }

  /// Get access token (for DioClient)
  Future<String?> getToken() async => accessToken;
  
  /// Get refresh token (for token refresh)
  Future<String?> getRefreshToken() async => refreshToken;

  /// Update tokens after refresh
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _prefManager.saveString(PrefKeys.accessToken, accessToken);
    if (refreshToken != null) {
      _prefManager.saveString(PrefKeys.refreshToken, refreshToken);
    }
  }

  /// Clear only auth tokens (soft logout)
  Future<void> clearToken() async {
    _prefManager.saveString(PrefKeys.accessToken, null);
    _prefManager.saveString(PrefKeys.refreshToken, null);
    _prefManager.saveBool(PrefKeys.isLoggedIn, false);
  }

  /// Clear entire session (full logout)
  Future<void> clearSession() async {
    await clearToken();
    _prefManager.saveString(PrefKeys.userId, null);
    _prefManager.saveString(PrefKeys.userEmail, null);
    _prefManager.saveString(PrefKeys.userName, null);
  }

  /// Full logout with preference clear
  Future<void> logout() async {
    // Keep certain prefs (theme, language)
    final themeMode = _prefManager.getString(PrefKeys.themeMode);
    final langCode = _prefManager.getString(PrefKeys.languageCode);
    
    await _prefManager.clear();
    
    // Restore non-auth prefs
    if (themeMode != null) {
      _prefManager.saveString(PrefKeys.themeMode, themeMode);
    }
    if (langCode != null) {
      _prefManager.saveString(PrefKeys.languageCode, langCode);
    }
  }
}
''';

  static String _simpleSessionManager() => '''
import 'pref_manager.dart';

/// Manages user authentication session and tokens.
/// 
/// Features:
/// - Secure token storage
/// - Session state tracking
/// - Token refresh support
/// - User data caching
class SessionManager {
  final PrefManager _prefManager;

  SessionManager(this._prefManager);

  // Token getters
  Future<String?> get accessToken => _prefManager.getString(PrefKeys.accessToken);
  Future<String?> get refreshToken => _prefManager.getString(PrefKeys.refreshToken);
  
  // Auth state
  Future<bool> get isAuthenticated async {
    final loggedIn = await _prefManager.getBoolValue(PrefKeys.isLoggedIn);
    final token = await accessToken;
    return loggedIn && token != null && token.isNotEmpty;
  }
  
  // User info
  Future<String?> get userId => _prefManager.getString(PrefKeys.userId);
  Future<String?> get userEmail => _prefManager.getString(PrefKeys.userEmail);
  Future<String?> get userName => _prefManager.getString(PrefKeys.userName);

  /// Save complete session after login
  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    String? name,
  }) async {
    await _prefManager.saveString(PrefKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await _prefManager.saveString(PrefKeys.refreshToken, refreshToken);
    }
    if (userId != null) {
      await _prefManager.saveString(PrefKeys.userId, userId);
    }
    if (email != null) {
      await _prefManager.saveString(PrefKeys.userEmail, email);
    }
    if (name != null) {
      await _prefManager.saveString(PrefKeys.userName, name);
    }
    await _prefManager.saveBool(PrefKeys.isLoggedIn, true);
  }

  /// Get access token (for DioClient)
  Future<String?> getToken() async => accessToken;
  
  /// Get refresh token (for token refresh)
  Future<String?> getRefreshToken() async => refreshToken;

  /// Update tokens after refresh
  Future<void> updateTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _prefManager.saveString(PrefKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await _prefManager.saveString(PrefKeys.refreshToken, refreshToken);
    }
  }

  /// Clear only auth tokens (soft logout)
  Future<void> clearToken() async {
    await _prefManager.saveString(PrefKeys.accessToken, null);
    await _prefManager.saveString(PrefKeys.refreshToken, null);
    await _prefManager.saveBool(PrefKeys.isLoggedIn, false);
  }

  /// Clear entire session (full logout)
  Future<void> clearSession() async {
    await clearToken();
    await _prefManager.saveString(PrefKeys.userId, null);
    await _prefManager.saveString(PrefKeys.userEmail, null);
    await _prefManager.saveString(PrefKeys.userName, null);
  }

  /// Full logout with preference clear
  Future<void> logout() async {
    // Keep certain prefs (theme, language)
    final themeMode = await _prefManager.getString(PrefKeys.themeMode);
    final langCode = await _prefManager.getString(PrefKeys.languageCode);
    
    await _prefManager.clear();
    
    // Restore non-auth prefs
    if (themeMode != null) {
      await _prefManager.saveString(PrefKeys.themeMode, themeMode);
    }
    if (langCode != null) {
      await _prefManager.saveString(PrefKeys.languageCode, langCode);
    }
  }
}
''';

  static String permissionService(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
$injectableImport

$injectableAnno
class PermissionService {
  bool get _isWeb => kIsWeb;
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;
  bool get _isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  bool get supportsNotifications => !_isWeb && (_isAndroid || _isIOS || _isMacOS);
  bool get supportsStoragePermission => !_isWeb && _isAndroid;
  bool get supportsPhotosPermission => !_isWeb && (_isIOS || _isMacOS);

  // Camera permissions
  Future<bool> hasCamera() async {
    if (_isWeb) return false;
    return Permission.camera.isGranted;
  }
  
  Future<bool> requestCamera() async {
    if (_isWeb) return false;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Notification permissions
  Future<bool> hasNotifications() async {
    if (!supportsNotifications) return false;
    return Permission.notification.isGranted;
  }
  
  Future<bool> requestNotifications() async {
    if (!supportsNotifications) return false;
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  // Storage permissions
  Future<bool> hasStorage() async {
    if (supportsStoragePermission) {
      return Permission.storage.isGranted;
    }
    if (supportsPhotosPermission) {
      return hasPhotos();
    }
    return false;
  }
  
  Future<bool> requestStorage() async {
    if (supportsPhotosPermission) {
      return requestPhotos();
    }
    if (!supportsStoragePermission) return false;

    final status = await Permission.storage.request();
    if (status.isPermanentlyDenied) {
      return false;
    }
    return status.isGranted;
  }

  // Location permissions
  Future<bool> hasLocation() async {
    if (_isWeb) return false;
    return Permission.locationWhenInUse.isGranted;
  }
  
  Future<bool> requestLocation() async {
    if (_isWeb) return false;
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  // Microphone permissions
  Future<bool> hasMicrophone() async {
    if (_isWeb) return false;
    return Permission.microphone.isGranted;
  }
  
  Future<bool> requestMicrophone() async {
    if (_isWeb) return false;
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  // Photos/Gallery permissions
  Future<bool> hasPhotos() async {
    if (!supportsPhotosPermission) return false;
    return Permission.photos.isGranted;
  }
  
  Future<bool> requestPhotos() async {
    if (!supportsPhotosPermission) return false;
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // Request multiple permissions at once
  Future<Map<Permission, bool>> requestMultiple(List<Permission> permissions) async {
    if (_isWeb) {
      return {
        for (final permission in permissions) permission: false,
      };
    }
    final statuses = await permissions.request();
    return statuses.map((key, value) => MapEntry(key, value.isGranted));
  }

  // Open app settings (when permission permanently denied)
  Future<bool> openSettings() => openAppSettings();
  
  // Permission status check
  Future<PermissionStatus> checkStatus(Permission permission) => permission.status;
}
''';
  }

  static String notificationService(StateManagement state) {
    final injectableImport = state == StateManagement.bloc
        ? "import 'package:injectable/injectable.dart';\n"
        : '';
    final injectableAnno =
        state == StateManagement.bloc ? '@lazySingleton\n' : '';
    return '''
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
$injectableImport
/// Comprehensive notification service for local and scheduled notifications.
/// 
/// Usage:
/// ```dart
/// await notificationService.init();
/// await notificationService.show(title: 'Hello', body: 'World');
/// await notificationService.scheduleAt(title: 'Reminder', body: 'Time!', scheduledAt: time);
/// ```
$injectableAnno
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  
  bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  void Function(String? payload)? _onNotificationTapped;
  
  static const String defaultChannel = 'default';
  static const String reminderChannel = 'reminders';
  
  int _notificationIdCounter = 0;
  int get _nextId => ++_notificationIdCounter;

  Future<void> init({void Function(String? payload)? onNotificationTapped}) async {
    _onNotificationTapped = onNotificationTapped;
    if (!isSupportedPlatform) return;

    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );
    
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
    if (!isSupportedPlatform) return;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel == defaultChannel ? 'General Notifications' : 'Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
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
    if (!isSupportedPlatform) return;

    final tzTime = tz.TZDateTime.from(scheduledAt, tz.local);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(reminderChannel, 'Reminders'),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
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
    if (!isSupportedPlatform) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    const details = NotificationDetails(
      android: AndroidNotificationDetails(reminderChannel, 'Reminders'),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
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

  Future<void> cancel(int id) async {
    if (!isSupportedPlatform) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!isSupportedPlatform) return;
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPending() async {
    if (!isSupportedPlatform) return [];
    return _plugin.pendingNotificationRequests();
  }
}
''';
  }
}
