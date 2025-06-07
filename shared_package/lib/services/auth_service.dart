// shared_package/lib/auth/auth_service.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class AuthService {
  Future<String?> fetchUserRole(User user) async {
    final token = await user.getIdToken();
    final resp = await http.get(
      Uri.parse(URL_AUTH_ME),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['user']?['role'] as String?;
    }
    return null;
  }
  Future<void> registerUser({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final body = {
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'fcm_token': fcmToken,
      'role': role,
    };
    final resp = await http.post(
      Uri.parse(URL_REGISTER),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Ошибка регистрации: ${resp.body}');
    }
  }
}
