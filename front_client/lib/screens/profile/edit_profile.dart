import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/model_user.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _imageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _addressController = TextEditingController(text: widget.user.address ?? '');
    _imageController = TextEditingController(text: widget.user.profileImageUrl ?? '');
  }


  Future<void> _saveProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  final token = await user?.getIdToken();

  final updatedProfile = {
    "full_name": _nameController.text,
    "phone": _phoneController.text,
    "address": _addressController.text,
    "profileImageUrl": _imageController.text,
  };
  final userId = user?.uid;
  final response = await http.put(
    Uri.parse('http://192.168.0.230:5000/api/users/$userId'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(updatedProfile),
  );

  if (response.statusCode == 200) {
    Navigator.pop(context, true);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ошибка при обновлении профиля')),
    );
  }
}


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактировать профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'ФИО'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              readOnly: true, // Обычно email не редактируется
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Адрес'),
            ),
            TextField(
              controller: _imageController,
              decoration: InputDecoration(labelText: 'URL фотографии профиля'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Сохранить изменения'),
            ),
          ],
        ),
      ),
    );
  }
}
