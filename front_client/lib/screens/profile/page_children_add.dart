import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class PageChildrenAdd extends StatefulWidget {
  @override
  _PageChildrenAddState createState() => _PageChildrenAddState();
}

class _PageChildrenAddState extends State<PageChildrenAdd> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Добавить ребенка'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Имя ребенка'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя ребенка';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(labelText: 'Дата рождения'),
                readOnly: true,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 365 * 5)),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    locale: const Locale("ru", "RU"),
                  );
                  if (picked != null) {
                    String formattedDate = "${picked.year}-${_pad(picked.month)}-${_pad(picked.day)}";
                    setState(() {
                      _birthDateController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите дату рождения';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Дополнительная информация'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите дополнительную информацию';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final birthDate = _birthDateController.text;
                    final bio = _bioController.text;

                    // Get the current user UID from FirebaseAuth
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Пользователь не авторизован')),
                      );
                      return;
                    }
                    final token = await user.getIdToken();

                    final uid = user.uid;

                    print('Sending to backend...');
                    print('Name: $name');
                    print('Birth Date: $birthDate');
                    print('Bio: $bio');
                    print('User UID: $uid');


                    final url = Uri.parse('http://192.168.0.230:5000/api/children'); // Update with your backend address


                    try {
                      final response = await http.post(
                        url,
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer $token",
                        },
                        
                        body: jsonEncode({
                          "firebase_uid": uid,  // Send Firebase UID
                          "name": name,
                          "date_of_birth": birthDate,
                          "bio": bio,
                        }),
                      );

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        print('Child added successfully');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ребенок добавлен успешно')),
                        );
                        Navigator.pop(context);  // Go back to previous screen
                      } else {
                        print('Failed to add child: ${response.body}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ошибка при добавлении')),
                        );
                      }
                    } catch (e) {
                      print('Error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка подключения к серверу')),
                      );
                    }
                  }
                },
                child: Text('Добавить ребенка'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
