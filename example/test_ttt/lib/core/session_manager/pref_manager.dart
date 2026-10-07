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
