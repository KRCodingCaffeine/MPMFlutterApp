import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mpm/repository/login_respository.dart';
import 'package:mpm/utils/Session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceTokenService {
  static final DeviceTokenService _instance = DeviceTokenService._internal();
  factory DeviceTokenService() => _instance;
  DeviceTokenService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LoginRepo _loginRepo = LoginRepo();
  
  static const String _lastTokenKey = "last_device_token";
  String? _currentToken;

  /// Initialize device token service
  Future<void> initialize() async {
    try {
      // Get current token
      _currentToken = await _messaging.getToken().timeout(const Duration(seconds: 8));
      debugPrint("🔥 Initial FCM Token: $_currentToken");

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_handleTokenRefresh);

      // Update token if user is logged in
      await _updateTokenIfNeeded();
    } catch (e) {
      debugPrint("❌ Error initializing device token service: $e");
    }
  }

  /// Handle token refresh
  Future<void> _handleTokenRefresh(String newToken) async {
    debugPrint("🔄 FCM Token refreshed: $newToken");
    _currentToken = newToken;
    await _updateTokenIfNeeded();
  }

  /// Update token if needed
  Future<void> _updateTokenIfNeeded() async {
    try {
      final userData = await SessionManager.getSession();
      if (userData?.memberId == null || _currentToken == null) {
        debugPrint("⚠️ Cannot update token: User not logged in or token is null");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastToken = prefs.getString(_lastTokenKey);

      // Only update if token has changed
      if (lastToken != _currentToken) {
        debugPrint("📤 Updating device token for member: ${userData!.memberId}");
        await _updateTokenOnServer(userData.memberId!, _currentToken!);
        await prefs.setString(_lastTokenKey, _currentToken!);
      } else {
        debugPrint("✅ Device token is up to date");
      }
    } catch (e) {
      debugPrint("❌ Error updating token: $e");
    }
  }

  /// Update token on server
  Future<void> _updateTokenOnServer(String memberId, String token) async {
    try {
      final requestBody = {
        "member_id": memberId,
        "device_token": token,
      };

      final response = await _loginRepo.userToken(requestBody);
      debugPrint("📡 Token update response: $response");
    } catch (e) {
      debugPrint("❌ Error updating token on server: $e");
    }
  }

  /// Force update token (for login/logout scenarios)
  Future<void> forceUpdateToken() async {
    try {
      _currentToken = await _messaging.getToken();
      await _updateTokenIfNeeded();
    } catch (e) {
      debugPrint("❌ Error force updating token: $e");
    }
  }

  /// Clear stored token (for logout)
  Future<void> clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastTokenKey);
      _currentToken = null;
      debugPrint("🗑️ Cleared stored device token");
    } catch (e) {
      debugPrint("❌ Error clearing stored token: $e");
    }
  }

  /// Get current token
  String? get currentToken => _currentToken;

  /// Check if token needs update
  Future<bool> needsUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastToken = prefs.getString(_lastTokenKey);
      return lastToken != _currentToken;
    } catch (e) {
      debugPrint("❌ Error checking token update status: $e");
      return true; // Assume needs update on error
    }
  }
}
