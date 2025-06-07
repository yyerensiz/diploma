// front_client/lib/services/specialist_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:front_client/models/model_specialist.dart';
import 'package:shared_carenest/config.dart';

class SpecialistService {
  Future<List<Specialist>> fetchSpecialists() async {
    final uri = Uri.parse(URL_SPECIALISTS);
    try {
      final response = await http.get(uri);
      print(response.body);
      if (response.statusCode == 200) {
        return _parseSpecialists(response.body);
      } else {
        throw Exception(
            'Failed to fetch specialists (HTTP ${response.statusCode})');
      }
    } catch (error, stack) {
      debugPrint('Error in fetchSpecialists: $error\n$stack');
      throw Exception('Unable to fetch specialists: $error');
    }
  }

  List<Specialist> _parseSpecialists(String responseBody) {
    final parsed = jsonDecode(responseBody);
    if (parsed is List) {
      return parsed
          .map((e) => Specialist.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected response format (not a List)');
  }
}
