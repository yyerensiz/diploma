// front_client/lib/services/service_orders.dart
import 'dart:convert';
import 'package:front_client/models/model_order.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String _baseUrl = 'http://192.168.0.230:5000/api';

  Future<Order> createOrder(String token, Order order) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(order.toJson()),
    );
    if (response.statusCode == 201) {
      return Order.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create order');
  }

  Future<List<Order>> fetchClientOrders(String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/orders/client'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final list = (json.decode(res.body)['orders'] as List);
      return list.map((j) => Order.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch client orders');
  }

  Future<void> updateOrderStatus(
      String token, String orderId, String status) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to update order: ${res.body}');
    }
  }
}
