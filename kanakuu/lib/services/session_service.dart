// lib/services/session_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _userIdKey = 'userId';
  static const String _sessionExpiryKey = 'session_expiry';
  static const int _sessionDurationDays = 30;

  /// Save user session with 30-day expiry
  Future<void> saveUserSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(Duration(days: _sessionDurationDays));
    
    await prefs.setString(_userIdKey, userId);
    await prefs.setInt(_sessionExpiryKey, expiryTime.millisecondsSinceEpoch);
    
    print('Session saved for user: $userId, expires: $expiryTime');
  }

  /// Get user session if valid
  Future<String?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(_userIdKey) || !prefs.containsKey(_sessionExpiryKey)) {
      return null;
    }
    
    final expiryTimestamp = prefs.getInt(_sessionExpiryKey);
    if (expiryTimestamp == null) {
      return null;
    }
    
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    final now = DateTime.now();
    
    // Check if session has expired
    if (now.isAfter(expiryTime)) {
      await clearSession(); // Clean up expired session
      print('Session expired, cleared automatically');
      return null;
    }
    
    final userId = prefs.getString(_userIdKey);
    print('Valid session found for user: $userId');
    return userId;
  }

  /// Check if user is logged in with valid session
  Future<bool> isLoggedIn() async {
    final userId = await getUserSession();
    return userId != null;
  }

  /// Extend current session by another 30 days
  Future<void> extendSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey(_userIdKey)) {
      final newExpiryTime = DateTime.now().add(Duration(days: _sessionDurationDays));
      await prefs.setInt(_sessionExpiryKey, newExpiryTime.millisecondsSinceEpoch);
      print('Session extended until: $newExpiryTime');
    }
  }

  /// Get session expiry date
  Future<DateTime?> getSessionExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_sessionExpiryKey);
    
    if (expiryTimestamp == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
  }

  /// Get remaining days in session
  Future<int> getRemainingDays() async {
    final expiry = await getSessionExpiry();
    if (expiry == null) return 0;
    
    final now = DateTime.now();
    if (now.isAfter(expiry)) return 0;
    
    return expiry.difference(now).inDays;
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_sessionExpiryKey);
    print('Session cleared');
  }

  /// Check if session will expire soon (within 3 days)
  Future<bool> isSessionExpiringSoon() async {
    final remainingDays = await getRemainingDays();
    return remainingDays <= 3 && remainingDays > 0;
  }
}