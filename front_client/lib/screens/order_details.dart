import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDetailsScreen extends StatelessWidget {
  final String serviceType; 
  final TextEditingController descriptionController = TextEditingController();

  OrderDetailsScreen({required this.serviceType}); 

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'serviceType': serviceType, 
        'description': descriptionController.text.trim(),
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Order created successfully for $serviceType!");
    } else {
      print("❌ Failed to create order: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Details - $serviceType')),
      body: Column(
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Describe service'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: createOrder,
            child: Text('Create Order for $serviceType'),
          ),
        ],
      ),
    );
  }
}
