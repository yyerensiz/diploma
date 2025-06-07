//front_client\lib\core\services\service_order.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/model_order.dart';

class OrderService {
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
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      return Order.fromJson(body);
    }
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
      return list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to fetch client orders (${resp.statusCode})');
  }

  Future<void> updateOrderStatus(String token, int orderId, String status) async {
    final uri = Uri.parse('$URL_UPDATE_ORDER/$orderId');
    final resp = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status': status}),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to update order status (${resp.statusCode})');
    }
  }
}
