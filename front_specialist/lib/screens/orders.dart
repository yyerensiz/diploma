import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse('http://localhost:5000/api/orders'));

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(response.body);
      });
    } else {
      print('Failed to load orders');
    }
  }

  Future<void> acceptOrder(int orderId) async {
    final response = await http.put(
      Uri.parse('http://localhost:5000/api/orders/$orderId/accept'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'specialist_id': '12345'}), // Replace with actual specialist ID
    );

    if (response.statusCode == 200) {
      print('Order accepted');
      fetchOrders(); // Refresh list
    } else {
      print('Failed to accept order');
    }
  }

  Future<void> rejectOrder(int orderId) async {
    final response = await http.put(
      Uri.parse('http://localhost:5000/api/orders/$orderId/reject'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Order rejected');
      fetchOrders(); // Refresh list
    } else {
      print('Failed to reject order');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            child: ListTile(
              title: Text(order['service_type']),
              subtitle: Text(order['description']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => acceptOrder(order['id']),
                    child: Text('Accept'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => rejectOrder(order['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Reject'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
