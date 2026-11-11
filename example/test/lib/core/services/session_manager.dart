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
