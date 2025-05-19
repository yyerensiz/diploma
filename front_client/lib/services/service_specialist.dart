// Service for fetching specialists
import 'dart:convert';

import 'package:front_client/models/model_specialist.dart';
import 'package:http/http.dart' as http;

class SpecialistService {
  final String _baseUrl = 'http://192.168.0.230:5000/api';

  Future<List<Specialist>> fetchSpecialists() async {
  try {
    final response = await http.get(Uri.parse('$_baseUrl/specialists'));
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return _parseSpecialists(response.body);
    } else {
      throw Exception('Failed to fetch specialists with status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching specialists: $e');
    throw Exception('Failed to fetch specialists: $e');
  }
}

  List<Specialist> _parseSpecialists(String responseBody) {
    final dynamic parsed = jsonDecode(responseBody);
    if (parsed is List) {
      return parsed.map((item) => Specialist.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Response body is not a List');
    }
  }
}