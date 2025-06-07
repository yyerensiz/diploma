//front_client\lib\services\auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front_client/models/model_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }
  
  static Future<String> getFirebaseUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<UserProfile> fetchMe(String token) async {
    final resp = await http.get(
      Uri.parse(URL_AUTH_ME),
      headers: { 'Authorization': 'Bearer $token' },
    );
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body)['user'];
      return UserProfile.fromJson(json);
    }
    throw Exception('Failed to load profile');
  }
  
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }
}
