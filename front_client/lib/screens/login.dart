import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> syncUserWithBackend(User user) async {
    try {
      final token = await user.getIdToken();
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firebase_uid': user.uid,
          'email': user.email,
          'full_name': user.displayName ?? user.email?.split('@')[0] ?? "Unknown",
          'phone': user.phoneNumber ?? "Not provided",
        }),
      );

      print("🔍 Backend Response: ${response.body}");

      final responseBody = jsonDecode(response.body);

      final userData = responseBody is List ? responseBody.first : responseBody;

      if (userData is Map<String, dynamic>) {
        print("✅ User synced: $userData");
        if (mounted) {
          Provider.of<UserProvider>(context, listen: false).setUserData(userData);
        }
      } else {
        print("Unexpected response format: $responseBody");
      }
    } catch (e) {
      print("Sync error: $e");
    }
  }

  Future<void> login(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        print("🟢 User logged in: ${user.email}");
        await syncUserWithBackend(user);

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
      }
    } catch (e) {
      print("Login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Image.asset(
              'files/icon.jpg',
              width: 120,
              height: 120,
            ),
            SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => login(context),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Login',
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
}
