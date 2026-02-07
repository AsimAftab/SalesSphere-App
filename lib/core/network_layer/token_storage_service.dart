import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../providers/shared_prefs_provider.dart';
import '../utils/logger.dart';

part 'token_storage_service.g.dart';

/// Token Storage Service Provider
/// This provider is automatically generated and uses SharedPreferences
@Riverpod(keepAlive: true)
TokenStorageService tokenStorageService(Ref ref) {
  final sharedPrefs = ref.watch(sharedPrefsProvider);
  return TokenStorageService(sharedPrefs);
}

/// Token Storage Service
/// Handles JWT token storage and retrieval using SharedPreferences
class TokenStorageService {
  final SharedPreferences _prefs;

  /// Constructor that accepts SharedPreferences instance
  TokenStorageService(this._prefs) {
    AppLogger.d('TokenStorageService initialized with SharedPreferences');
  }

  /// Save Access Token
  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(StorageKeys.accessToken, token);
      AppLogger.i('✅ Access token saved successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving access token', e, stack);
    }
  }

  /// Get Access Token (synchronous)
  String? getToken() {
    try {
      final token = _prefs.getString(StorageKeys.accessToken);
      if (token != null) {
        AppLogger.d('✅ Access token retrieved');
      } else {
        AppLogger.d('ℹ️ No access token found');
      }
      return token;
    } catch (e, stack) {
      AppLogger.e('❌ Error getting access token', e, stack);
      return null;
    }
  }

  /// Delete Access Token
  Future<void> deleteToken() async {
    try {
      await _prefs.remove(StorageKeys.accessToken);
      AppLogger.i('✅ Access token deleted successfully');
    } catch (e, stack) {
      AppLogger.e('❌ Error deleting access token', e, stack);
    }
  }

  /// Check if token exists (synchronous)
  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save User Data as JSON
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      // Convert to JSON string properly
      final jsonString = jsonEncode(userData);
      await _prefs.setString(StorageKeys.userData, jsonString);
      AppLogger.i('✅ User data saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving user data', e, stack);
    }
  }

  /// Get User Data from storage (synchronous)
  Map<String, dynamic>? getUserData() {
    try {
      final userDataString = _prefs.getString(StorageKeys.userData);
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
      await _prefs.remove(StorageKeys.accessToken);
      await _prefs.remove(StorageKeys.refreshToken);
      await _prefs.remove(StorageKeys.userData);
      await _prefs.remove(StorageKeys.userPermissions);
      await _prefs.remove(StorageKeys.userSubscription);
      await _prefs.remove('session_expires_at');
      AppLogger.i('✅ All auth data cleared');
    } catch (e, stack) {
      AppLogger.e('❌ Error clearing auth data', e, stack);
    }
  }

  /// Save Refresh Token (if using refresh token strategy)
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _prefs.setString(StorageKeys.refreshToken, refreshToken);
      AppLogger.i('✅ Refresh token saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving refresh token', e, stack);
    }
  }

  /// Get Refresh Token (synchronous)
  String? getRefreshToken() {
    try {
      return _prefs.getString(StorageKeys.refreshToken);
    } catch (e, stack) {
      AppLogger.e('❌ Error getting refresh token', e, stack);
      return null;
    }
  }

  /// Save Session Expiry Date
  Future<void> saveSessionExpiresAt(String expiryDate) async {
    try {
      await _prefs.setString('session_expires_at', expiryDate);
      AppLogger.i('✅ Session expiry date saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving session expiry date', e, stack);
    }
  }

  /// Get Session Expiry Date (synchronous)
  String? getSessionExpiresAt() {
    try {
      return _prefs.getString('session_expires_at');
    } catch (e, stack) {
      AppLogger.e('❌ Error getting session expiry date', e, stack);
      return null;
    }
  }

  /// Check if session has expired (synchronous)
  bool isSessionExpired() {
    try {
      final expiryDateStr = getSessionExpiresAt();
      if (expiryDateStr == null) {
        return false; // No expiry set, assume valid
      }

      final expiryDate = DateTime.parse(expiryDateStr);
      final now = DateTime.now();
      final isExpired = now.isAfter(expiryDate);

      if (isExpired) {
        AppLogger.w('⚠️ Session expired at: $expiryDateStr');
      } else {
        AppLogger.d('✅ Session valid until: $expiryDateStr');
      }

      return isExpired;
    } catch (e, stack) {
      AppLogger.e('❌ Error checking session expiry', e, stack);
      return false;
    }
  }

  /// Save Permissions data
  Future<void> savePermissions(Map<String, dynamic> permissions) async {
    try {
      final jsonString = jsonEncode(permissions);
      await _prefs.setString(StorageKeys.userPermissions, jsonString);
      AppLogger.i('✅ Permissions saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving permissions', e, stack);
    }
  }

  /// Get Permissions from storage (synchronous)
  Map<String, dynamic>? getPermissions() {
    try {
      final permissionsString = _prefs.getString(StorageKeys.userPermissions);
      if (permissionsString != null && permissionsString.isNotEmpty) {
        return jsonDecode(permissionsString) as Map<String, dynamic>;
      }
      return null;
    } catch (e, stack) {
      AppLogger.e('❌ Error getting permissions', e, stack);
      return null;
    }
  }

  /// Save Subscription data
  Future<void> saveSubscription(Map<String, dynamic> subscription) async {
    try {
      final jsonString = jsonEncode(subscription);
      await _prefs.setString(StorageKeys.userSubscription, jsonString);
      AppLogger.i('✅ Subscription saved');
    } catch (e, stack) {
      AppLogger.e('❌ Error saving subscription', e, stack);
    }
  }

  /// Get Subscription from storage (synchronous)
  Map<String, dynamic>? getSubscription() {
    try {
      final subscriptionString = _prefs.getString(StorageKeys.userSubscription);
      if (subscriptionString != null && subscriptionString.isNotEmpty) {
        return jsonDecode(subscriptionString) as Map<String, dynamic>;
      }
      return null;
    } catch (e, stack) {
      AppLogger.e('❌ Error getting subscription', e, stack);
      return null;
    }
  }
}
