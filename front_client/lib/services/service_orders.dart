// front_client/lib/services/service_orders.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_carenest/config.dart';
import '../models/model_order.dart';

class OrderService {
  // / POST /api/orders
  Future<Order> createOrder(String token, Order order) async {
    final uri = Uri.parse(URL_CREATE_ORDER);
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(order.toJson()),
    );

    if (resp.statusCode == 201) {
      final body = jsonDecode(resp.body);
      return Order.fromJson(body as Map<String, dynamic>);
    }

    debugPrint(
      'createOrder failed [${resp.statusCode}]: ${resp.body}',
    );
    throw Exception('Failed to create order (${resp.statusCode})');
  }

  Future<List<Order>> fetchClientOrders(String token) async {
    final uri = Uri.parse(URL_CLIENT_ORDERS);
    final resp = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final list = data['orders'] as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    debugPrint(
      'fetchClientOrders failed [${resp.statusCode}]: ${resp.body}',
    );
    throw Exception('Failed to fetch client orders (${resp.statusCode})');
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
