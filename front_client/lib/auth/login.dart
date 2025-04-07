import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_client/auth/signup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/navbar.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> syncUserWithBackend(User user) async {
  try {
    final token = await user.getIdToken();

    print("User Info: ${user.uid}, ${user.email}, ${user.displayName}, ${user.phoneNumber}");

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

    print("Backend response: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print("Sync response parsed: $responseBody");
      print("Returned userData: ${responseBody.runtimeType}");

      if (responseBody is List) {
        print("Unexpected list received instead of a Map.");
        return null;
      }

      return responseBody;
    } else {
      print("Failed to sync: ${response.statusCode} ${response.body}");
    }
  } catch (e) {
    print("Sync error: $e");
  }

  return null;
}



  Future<void> _signIn() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    User? user = userCredential.user;
    if (user != null) {
      final userData = await syncUserWithBackend(user);

      if (userData != null && mounted) {
        Provider.of<UserProvider>(context, listen: false).setUserData(userData);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()));
      } else {
        debugPrint("Failed to retrieve user data from backend.");
      }
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage = "Ошибка входа.";
    if (e.code == 'user-not-found') {
      errorMessage = "Пользователь не найден.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Неверный пароль.";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
    );
  } catch (e) {
    debugPrint("Login error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ошибка входа: ${e.toString()}"), backgroundColor: Colors.red),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CareNest',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Помощь родителям',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Введите email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Введите пароль' : null,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Войти',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SignupScreen()));
                  }, 
                  child: const Text('Создать аккаунт'),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen()));
                  },
                  child: const Text('Забыли пароль?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
