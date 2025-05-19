import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/model_order.dart';

class OrderService {
  final String baseUrl = 'http://192.168.0.230:5000/api/orders';

  Future<List<OrderModel>> fetchSpecialistOrders(int specialistId) async {
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

  // grab the array under "orders"
  final List<dynamic> data = jsonDecode(response.body)['orders'];

  if (data.isNotEmpty) {
    print('👀 children for first order: ${data[0]['children']}');
  }

  return data
      .map((j) => OrderModel.fromJson(j as Map<String, dynamic>))
      .toList();
}


  Future<void> updateOrderStatus(int orderId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    final token = await user.getIdToken();

    final response = await http.put(
      Uri.parse('$baseUrl/$orderId'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update order: ${response.body}');
    }
  }
}
