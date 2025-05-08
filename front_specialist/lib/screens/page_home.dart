import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List orders = [];
  bool _isLoading = true;

  Future<void> fetchOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      final response = await http.get(
        Uri.parse('http://192.168.0.230:5000/api/orders/specialist-orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }
  Future<void> updateOrderStatus(int orderId, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final token = await user.getIdToken();

    final url = Uri.parse('http://192.168.0.230:5000/api/orders/$orderId/$status');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      fetchOrders(); // Refresh list
    } else {
      print("Failed to $status order: ${response.body}");
    }
  }



  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Мои заказы')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text('Нет доступных заказов'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(order['service_type']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Описание: ${order['description']}'),
                            Text('Статус: ${order['status']}'),
                            Text('Дата: ${DateTime.parse(order['scheduled_for']).toLocal()}'),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => updateOrderStatus(order['id'], 'accept'),
                                  child: Text('Принять'),
                                ),
                                TextButton(
                                  onPressed: () => updateOrderStatus(order['id'], 'reject'),
                                  child: Text('Отклонить'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
