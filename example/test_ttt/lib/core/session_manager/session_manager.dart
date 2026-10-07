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
