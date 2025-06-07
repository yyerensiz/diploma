//front_client\lib\core\services\auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../models/model_user.dart';
import '../config.dart';

class AuthService {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<UserProfile> fetchMe(String token) async {
    final resp = await http.get(
      Uri.parse(URL_AUTH_ME),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body)['user'];
      return UserProfile.fromJson(json);
    }
    throw Exception('Failed to load profile');
  }

  /// New: fetchUserRole(...) sends the Firebase‐ID token to `/api/auth/me` and returns `data['user']['role']`
  static Future<String?> fetchUserRole(User user) async {
    final idToken = await user.getIdToken();
    final resp = await http.get(
      Uri.parse(URL_AUTH_ME),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['user']?['role'] as String?;
    }
    return null;
  }

  static Future<String> getFirebaseUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }
}
