//front_client\lib\core\services\service_payment.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/model_subsidy.dart';

class PaymentService {
  Future<double> getBalanceWithToken(String token) async {
    final resp = await http.get(
      Uri.parse(URL_WALLET),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load balance (${resp.statusCode})');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return double.tryParse(data['balance'].toString()) ?? 0.0;
  }

  Future<Subsidy?> getSubsidyWithToken(String token) async {
    final resp = await http.get(
      Uri.parse(URL_SUBSIDIES),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load subsidies (${resp.statusCode})');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = body['subsidies'] as List<dynamic>;
    if (list.isEmpty) return null;
    return Subsidy.fromJson(Map<String, dynamic>.from(list.first));
  }

  Future<void> applySubsidyWithToken(String token, File document) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(URL_APPLY_SUBSIDY),
    )..headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('document', document.path));
    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to apply subsidy (${response.statusCode})');
    }
  }
}
