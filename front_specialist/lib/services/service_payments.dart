// front_client/lib/services/service_payments.dart
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';

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
