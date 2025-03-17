import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  Future<void> signUp(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firebase_uid': user.uid,
            'email': user.email,
            'full_name': fullNameController.text.trim(),
            'phone': phoneController.text.trim(),
            'role': 'client'
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        } else {
          print("Signup failed: ${response.body}");
        }
      }
    } catch (e) {
      print("Signup error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: fullNameController, decoration: InputDecoration(labelText: 'Full Name')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: () => signUp(context), child: Text('Sign Up'))
          ],
        ),
      ),
    );
  }
}
