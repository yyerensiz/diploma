import 'package:flutter/material.dart';
import 'package:front_client/screens/page_search_specialist.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/children_provider.dart';
import 'dart:convert';
import 'page_search_specialist.dart';
class SpecialistProfilePage extends StatefulWidget {
  final Specialist specialist;
  final bool isOrderFlow;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final List<String>? selectedChildren;
  final String? orderDescription;
  final String? serviceType;


  const SpecialistProfilePage({
    required this.specialist,
    this.isOrderFlow = false,
    this.selectedDate,
    this.selectedTime,
    this.selectedChildren,
    this.orderDescription,
    this.serviceType,
  });

  @override
  State<SpecialistProfilePage> createState() => _SpecialistProfilePageState();
}

class _SpecialistProfilePageState extends State<SpecialistProfilePage> {
  Future<bool> createOrder() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();
      final scheduledDateTime = DateTime(
        widget.selectedDate!.year,
        widget.selectedDate!.month,
        widget.selectedDate!.day,
        widget.selectedTime!.hour,
        widget.selectedTime!.minute,
      );
      final requestBody = {
        'specialist_id': widget.specialist.id,
        'description': widget.orderDescription,
        'status': 'pending',
        'scheduled_for': scheduledDateTime.toIso8601String(),
        'children_ids': widget.selectedChildren,
        if (widget.serviceType != null) 'service_type': widget.serviceType,
      };

      print('Sending order: ${jsonEncode(requestBody)}'); // ✅ Log the payload

      final response = await http.post(
        Uri.parse('http://192.168.0.230:5000/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'specialist_id': widget.specialist.id,
          'description': widget.orderDescription,
          'status': 'pending',
          'scheduled_for': scheduledDateTime.toIso8601String(),
          'children_ids': widget.selectedChildren,
          if (widget.serviceType != null) 'service_type': widget.serviceType,
        }),
      );
      

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating order: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль специалиста'),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(widget.specialist.imageUrl),
                  ),
                  SizedBox(height: 16),
                  Text(widget.specialist.name, style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 4),
                      Text(widget.specialist.rating.toString(), style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('О специалисте', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  Text(widget.specialist.description),
                  SizedBox(height: 24),
                  Text('Отзывы', style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ReviewCard(
                        authorName: 'Клиент ${index + 1}',
                        rating: 4.5,
                        date: '10 марта 2024',
                        text: 'Очень хороший специалист, пунктуальный и ответственный. Дети в восторге!',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: widget.isOrderFlow
                ? () async {
                    final success = await createOrder();

                    if (!mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Заказ успешно создан')),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка при создании заказа')),
                      );
                    }
                  }
                : null,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Заказать услугу', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ),
    );
  }
}


class ReviewCard extends StatelessWidget {
  final String authorName;
  final double rating;
  final String date;
  final String text;

  const ReviewCard({
    required this.authorName,
    required this.rating,
    required this.date,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  authorName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(rating.toString()),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}
