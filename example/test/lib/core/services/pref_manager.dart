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
