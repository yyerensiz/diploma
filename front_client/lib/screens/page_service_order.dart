import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/children_provider.dart';
import 'dart:convert';

class ServiceDetailsPage extends StatefulWidget {
  final String serviceName;

  const ServiceDetailsPage({required this.serviceName});

  @override
  _ServiceDetailsPageState createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<String> selectedChildren = [];
  final TextEditingController descriptionController = TextEditingController();
  bool _isLoading = false;

  Future<void> createOrder() async {
    if (selectedDate == null || selectedTime == null || selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select date, time and at least one child')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login first')),
        );
        return;
      }

      final DateTime orderDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'service_type': widget.serviceName,
          'description': descriptionController.text,
          'status': 'pending',
          'scheduled_for': orderDateTime.toIso8601String(),
          'children_ids': selectedChildren,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order created successfully')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating order: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childrenProvider = Provider.of<ChildrenProvider>(context);
    final children = childrenProvider.children;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date and Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today),
                    label: Text(selectedDate != null
                        ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
                        : 'Select date'),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.access_time),
                    label: Text(selectedTime != null
                        ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select time'),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Select Children',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Column(
              children: children.map((child) {
                return CheckboxListTile(
                  title: Text('${child['name']} (${child['age']})'),
                  value: selectedChildren.contains(child['id']),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedChildren.add(child['id']);
                      } else {
                        selectedChildren.remove(child['id']);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Text(
              'Description for Specialist',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe your requirements...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : createOrder,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Create Order',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }
} 