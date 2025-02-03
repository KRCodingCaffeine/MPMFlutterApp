import 'dart:convert';

import 'package:mpm/model/CheckUser/CheckUserData.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyUserToken = "user_token";
  static const String _sessionKey = 'session_data';

  /// Save session data
  static Future<void> saveSessionToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserToken, token);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Retrieve user token
  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserToken);
  }

  /// Clear session
  static Future<void> clearSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserToken);

    await prefs.remove(_sessionKey);
  }
  static Future<void> saveSessionUserData(CheckUserData2 sessionData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String sessionJson = jsonEncode(sessionData.toJson());
    await prefs.setString(_sessionKey, sessionJson);
  }
  static Future<CheckUserData2?> getSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null) {
      Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
      return CheckUserData2.fromJson(sessionMap);
    }
    else{
      print("fggfghfgh");
    }
    return null;
  }
}