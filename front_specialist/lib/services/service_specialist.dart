import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/model_specialist.dart';
import 'package:shared_carenest/config.dart';

class SpecialistService {
  static const String baseUrl = URL_SPECIALISTS;

  static Future<Specialist?> fetchProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('SpecialistService.fetchProfile → status ${response.statusCode}');
    print('SpecialistService.fetchProfile → body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      try {
        return Specialist.fromJson(Map<String, dynamic>.from(data));
      } catch (e, st) {
        print('Error parsing SpecialistProfile: $e\n$st');
        rethrow;
      }
    } else {
      throw Exception('Failed to load specialist profile: ${response.body}');
    }
  }

  static Future<void> updateProfile(Specialist updatedProfile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await user.getIdToken();

    final body = json.encode({
      'full_name': updatedProfile.fullName,
      'bio': updatedProfile.bio,
      'pfp_url': updatedProfile.pfpUrl,
      'hourly_rate': updatedProfile.hourlyRate,
      'available_times': updatedProfile.availableTimes,
      'phone': updatedProfile.phone,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }
  static Future<void> uploadVerificationDocs(XFile idDoc, XFile certDoc) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final token = await user.getIdToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/verify'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('id_document', idDoc.path))
      ..files.add(await http.MultipartFile.fromPath('certificate', certDoc.path));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Ошибка отправки документов. Код: ${response.statusCode}');
    }
  }
}
