// front_client/lib/auth/signup.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> syncUserWithBackend(User user) async {
  try {
    final token = await user.getIdToken();
    final fcmToken = await FirebaseMessaging.instance.getToken(); // ← NEW

    final response = await http.post(
      Uri.parse('http://192.168.0.230:5000/api/auth/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'firebase_uid': user.uid,
        'email': user.email,
        'full_name': fullNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'fcm_token': fcmToken,
        'role': 'client', 
      }),
    );

    print("Backend sync response: ${response.body}");

    final responseBody = jsonDecode(response.body);
    Map<String, dynamic> userData;
    if (responseBody is List && responseBody.isNotEmpty) {
      userData = Map<String, dynamic>.from(responseBody.first);
    } else if (responseBody is Map<String, dynamic>) {
      userData = Map<String, dynamic>.from(responseBody);
    } else {
      throw Exception("Unexpected backend response: $responseBody");
    }

    Provider.of<UserProvider>(context, listen: false).setUserData(userData);
  } catch (e) {
    print("❌ Sync error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ошибка синхронизации: ${e.toString()}"), backgroundColor: Colors.red),
    );
  }
}

  Future<void> signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user != null) {
        await syncUserWithBackend(user);

        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ошибка регистрации.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Email уже используется.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Signup error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка регистрации: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(children: [
                const Text('Регистрация', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder()),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Введите ФИО' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон', border: OutlineInputBorder()),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Введите номер телефона' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => (value?.isEmpty ?? true) ? 'Введите email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                  validator: (value) => (value?.length ?? 0) < 6 ? 'Минимум 6 символов' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => signUp(context),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isLoading
                          ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          : const Text('Зарегистрироваться', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen())),
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
