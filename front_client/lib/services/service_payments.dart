// front_client/lib/services/service_payments.dart
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import '../models/model_subsidy.dart';

class PaymentService {
  Future<double> getBalance() async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final resp = await http.get(
      Uri.parse(URL_WALLET),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load balance: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return double.tryParse(data['balance'].toString()) ?? 0.0;
  }

  Future<Subsidy?> getSubsidy() async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final resp = await http.get(
      Uri.parse(URL_SUBSIDIES),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load subsidies: ${resp.statusCode}');
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final list = body['subsidies'] as List<dynamic>;
    if (list.isEmpty) return null;
    return Subsidy.fromJson(Map<String, dynamic>.from(list.first));
  }

  Future<void> applySubsidy(File document) async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(URL_APPLY_SUBSIDY),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('document', document.path));
    final response = await request.send();
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to apply subsidy: ${response.statusCode}');
    }
  }
  Future<double> replenishWallet({
    required String cardNumber,
    required String expDate,
    required String cvv,
    required double amount,
  }) async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final body = jsonEncode({
      'card_number': cardNumber,
      'exp_date': expDate,
      'cvv': cvv,
      'amount': amount,
    });

    final resp = await http.post(
      Uri.parse(URL_REPLENISH),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (resp.statusCode != 200) {
      String msg;
      try {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        msg = data['error'] ?? 'Unknown error (${resp.statusCode})';
      } catch (_) {
        msg = 'Unknown error (${resp.statusCode})';
      }
      throw Exception('Failed to replenish: $msg');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return double.tryParse(data['wallet_balance'].toString()) ?? 0.0;
  }
}
