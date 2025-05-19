// Service for managing orders
import 'dart:convert';

import 'package:front_client/models/model_order.dart';
import 'package:http/http.dart' as http;

class OrderService {
  final String _baseUrl = 'http://192.168.0.230:5000/api';

  Future<Order> createOrder(String token, Order order) async {
  final body = order.toJson();
  print('Sending order: ${jsonEncode(body)}');  // ← Logging before the request

  final response = await http.post(
    Uri.parse('$_baseUrl/orders'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(body),                      // ← Only this here
  );

  if (response.statusCode == 201) {
    final decoded = json.decode(response.body);
    return Order.fromJson(decoded);
  } else {
    print("Order Creation Error: ${response.body}");
    throw Exception('Failed to create order. Status code: ${response.statusCode}');
  }
}
Future<List<Order>> fetchClientOrders(String token) async {
  final response = await http.get(
    Uri.parse('$_baseUrl/orders/client'), // NO clientId in URL!
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    final List<dynamic> list = decoded['orders'];
    return list.map((e) => Order.fromJson(e)).toList();
  } else {
    throw Exception('Failed to fetch client orders');
  }
}




}