import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../utils/logger.dart';

/// Token Storage Service Provider
final tokenStorageServiceProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

/// Token Storage Service
/// Handles JWT token storage and retrieval using SharedPreferences
class TokenStorageService {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    AppLogger.d('TokenStorageService initialized');
  }

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  /// Save JWT Token
  Future<void> saveToken(String token) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(StorageKeys.authToken, token);
      AppLogger.i('✅ Token saved successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving token', e, stack);
    }
  }

  /// Get JWT Token
  Future<String?> getToken() async {
    try {
      final prefs = await _preferences;
      final token = prefs.getString(StorageKeys.authToken);
      if (token != null) {
        AppLogger.d('✅ Token retrieved');
      } else {
        AppLogger.d('ℹ️ No token found');
      }
      return token;
    } catch (e, stack) {
      AppLogger.e('❌ Error getting token', e, stack);
      return null;
    }
  }

  /// Delete JWT Token
  Future<void> deleteToken() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(StorageKeys.authToken);
      AppLogger.i('✅ Token deleted successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error deleting token', e, stack);
    }
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save User Data as JSON
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await _preferences;
      // Convert to JSON string properly
      final jsonString = jsonEncode(userData);
      await prefs.setString(StorageKeys.userData, jsonString);
      AppLogger.i('✅ User data saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving user data', e, stack);
    }
  }

  /// Get User Data from storage
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await _preferences;
      final userDataString = prefs.getString(StorageKeys.userData);
      if (userDataString != null && userDataString.isNotEmpty) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e, stack) {
      AppLogger.e('❌ Error getting user data', e, stack);
      return null;
    }
  }

  /// Clear all auth data
  Future<void> clearAuthData() async {
    try {
      await deleteToken();
      final prefs = await _preferences;
      await prefs.remove(StorageKeys.userData);
      AppLogger.i('✅ All auth data cleared');
    } catch (e, stack) {
      AppLogger.e('❌ Error clearing auth data', e, stack);
    }
  }

  /// Save Refresh Token (if using refresh token strategy)
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(StorageKeys.refreshToken, refreshToken);
      AppLogger.i('✅ Refresh token saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving refresh token', e, stack);
    }
  }

  /// Get Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await _preferences;
      return prefs.getString(StorageKeys.refreshToken);
    } catch (e, stack) {
      AppLogger.e('❌ Error getting refresh token', e, stack);
      return null;
    }
  }
}
