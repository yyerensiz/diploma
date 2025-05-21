// front_client/lib/services/service_payments.dart
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/model_subsidy.dart';

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

  // Future<Subsidy?> getSubsidy() async {
  //   final token = await FirebaseAuth.instance.currentUser!.getIdToken();
  //   final resp = await http.get(
  //     Uri.parse('$_base/subsidies'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //   if (resp.statusCode != 200) throw Exception('Subsidy load failed');
  //   final list = (jsonDecode(resp.body)['subsidies'] as List?) ?? [];
  //   if (list.isEmpty) return null;
  //   print('Response: ${list}');
  //   return Subsidy.fromJson(list.first as Map<String, dynamic>);
  // }
  Future<Subsidy?> getSubsidy() async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final resp = await http.get(
      Uri.parse('$_base/subsidies'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load subsidy: ${resp.statusCode}');
    }

    final jsonBody = jsonDecode(resp.body);
    if (jsonBody is! Map<String, dynamic> || !jsonBody.containsKey('subsidies')) {
      throw Exception('Unexpected subsidy response: $jsonBody');
    }

    final List<dynamic> list = jsonBody['subsidies'] as List<dynamic>;
    if (list.isEmpty) return null;

    // Make sure we have a strictly typed map
    final Map<String, dynamic> first =
        Map<String, dynamic>.from(list.first as Map);
    print('Response: ${first}');
    return Subsidy.fromJson(first);
  }

  Future<void> applySubsidy(File doc) async {
    final token = await FirebaseAuth.instance.currentUser!.getIdToken();
    var req = http.MultipartRequest('POST', Uri.parse('$_base/subsidies/apply'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('document', doc.path));
    final res = await req.send();
    if (res.statusCode != 201) throw Exception('Failed to apply subsidy');
  }
}
