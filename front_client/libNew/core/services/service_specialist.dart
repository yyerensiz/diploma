//front_client\lib\core\services\service_specialist.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/model_specialist.dart';
import '../config.dart';

class SpecialistService {
  Future<List<Specialist>> fetchSpecialists() async {
    final uri = Uri.parse(URL_SPECIALISTS);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final parsed = jsonDecode(response.body);
      if (parsed is List) {
        return parsed
            .map((e) => Specialist.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Unexpected response format');
    }
    throw Exception('Failed to fetch specialists (${response.statusCode})');
  }
}
