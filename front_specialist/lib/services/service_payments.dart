// front_client/lib/services/service_payments.dart
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  final _base = 'http://192.168.0.230:5000/api/money';

  Future<double> getBalance() async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final resp = await http.get(
      Uri.parse('$_base/wallet'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) throw Exception('Balance load failed');
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    //print('Response: ${data}');
    // return (data['balance'] as num).toDouble();
    final raw = data['balance'];
    final str = raw?.toString() ?? '0';
    final value = double.tryParse(str) ?? 0.0;

  return value;
  }
  
}
