//front_specialist\lib\services\service_order.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_carenest/config.dart';
import '../models/model_order.dart';

class OrderService {
  final String baseUrl = URL_ORDERS_BASE;

  Future<List<Order>> fetchSpecialistOrders(int specialistId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');
  final token = await user.getIdToken();

  final response = await http.get(
    Uri.parse('$baseUrl/specialist/$specialistId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  print('👀 orders JSON: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Failed to load orders: ${response.body}');
  }

  final List<dynamic> data = jsonDecode(response.body)['orders'];

  if (data.isNotEmpty) {
    print('👀 children for first order: ${data[0]['children']}');
  }

  return data
      .map((j) => Order.fromJson(j as Map<String, dynamic>))
      .toList();
}


  Future<void> updateOrderStatus(int orderId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final token = await user.getIdToken();

    final response = await http.put(
      Uri.parse('$URL_UPDATE_ORDER/$orderId'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order: ${response.body}');
    }
  }
}
